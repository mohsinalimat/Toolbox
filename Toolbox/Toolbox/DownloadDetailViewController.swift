//
//  DownloadDetailViewController.swift
//  Toolbox
//
//  Created by gener on 17/9/6.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class DownloadDetailViewController: BaseViewControllerWithTable {
    let _topview_height :CGFloat = 80.0;
    var url:String?
    var _urlLable: UILabel!
    var _statusLable:UILabel!
    var _progressview:UIProgressView!
    var _timer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "更新信息"
        _timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let rect = view.frame
        tableview?.frame = CGRect (x: 0, y: _topview_height, width: rect.width, height: rect.height - _topview_height)
        NotificationCenter.default.addObserver(self, selector: #selector(unzipAllComplete(_:)), name: NSNotification.Name (rawValue: "kNotification_unzip_all_complete"), object: nil)
        
        updateStatus()
        
        dataArray = dataArray + getDataSource()
    }
    
    deinit{
        if  nil != _timer {
            _timer = nil
        }
    }
    

    //MARK:
    func objectFromJson(_ jsonstr:String) -> Any? {
        do {
            guard let data = jsonstr.data(using: String.Encoding.utf8, allowLossyConversion: true) else {return nil}
            return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments);
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
    
    func getDataSource() -> [[String:String]] {
        var ds = [[String:String]]()
        
        //status
        let model = DataSourceModel.searchSingle(withWhere: "location_url='\(url!)'", orderBy: nil) as! DataSourceModel
        let d1 = ["Status":model.update_status == 6 ? "Update Success" : ""]
        ds.append(d1)
        
        /////
        let update_time:String? = model.time
        var _last_update:Date?
        if let up_time = update_time {
            _last_update = Date.init(timeIntervalSinceReferenceDate: TimeInterval.init(up_time)!)
        }
        
        var _package:String?
        var _threshold :String = ""
        if let packageinfodic = objectFromJson(model.package_info) as? [String:Any]{
            let customer_code = packageinfodic["customer_code"];
            let orderdata = packageinfodic["order_datetime"]
            _threshold = packageinfodic["threshold"] as! String
            _package = "\(customer_code!)_Order_\(orderdata!)"
        }
        
        //left time
        var left_time:String = "N/A"
        if let last_update = _last_update {
            let sec = Date.init().timeIntervalSince(last_update);
            let th = Double.init(_threshold)!
            let lefthour =  th * 24 - sec / 3600
            let day = lefthour / 24
            let hour = lefthour.truncatingRemainder(dividingBy: 24)
            left_time = "\(Int(day))" + " days," + "\(Int(hour))" + " hours"
        }
        let d2 = ["Time Left Until Update Required":left_time]
        ds.append(d2)
        
        //number
        var num = 0
        if let sync_arr = objectFromJson(model.sync_manifest) as? [[String:String]] {
            num = sync_arr.count;
        }
        let d3 = ["Document Online":"\(num)"]
        ds.append(d3)
        let d4 = ["Document on Device":"\(num)"]
        ds.append(d4)
        
        //last check time
        let lasttimestr = _last_update != nil ? Date.stringFromDate(_last_update!, withFormatter: "yyyy-MM-dd HH:mm") : "N/A"
        let d5 = ["Last Checked":lasttimestr]
        ds.append(d5)
        
        //last data package
        let d6 = ["Last Data Package":_package ?? "N/A"]
        ds.append(d6)
        return ds
    }
    
    
    //MARK:
    func unzipAllComplete(_ noti:Notification) {
        //防止要显示更新列表，多数据源情况下，一个数据源安装完成其他的还在进行中，视图dismiss。
        if DataSourceManager.default.unzipQueueIsEmpty().0 {
            if _timer.isValid{
                _timer.invalidate();
            }
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func timerAction() {
        updateStatus()
    }

    func updateStatus() {
        let model = DataSourceModel.searchSingle(withWhere: "location_url='\(url!)'", orderBy: nil) as! DataSourceModel
        _urlLable.text = model.location_url;
        switch model.update_status {
        case 1:_statusLable.text = "等待中";break
        case 2:_statusLable.text = "下载文件: \(model.current_files) / \(model.total_files)";break
        case 3:_statusLable.text = "准备解压";break
        case 4:_statusLable.text = "解压文件: \(model.current_files) / \(model.total_files)";break
        case 5:_statusLable.text = "解压完成,准备更新";break
        case 6: _statusLable.text = "已是最新";break
        default:break
        }
        
        _progressview.progress = model.ds_file_percent
        if model.update_status != 6 {
            _timer.invalidate()
        }
    }
    
    override func initSubview() {
        needtitleView = false
        navigationItem.rightBarButtonItems = nil

        /*let _v = Bundle.main.loadNibNamed("DownloadDetailtop", owner: self, options: nil)?.first
        let top_v = _v  as! UIView
        top_v.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: _topview_height)
        top_v.backgroundColor = UIColor.red*/
        let top_v = topHeadView(CGRect(x: 0, y: 0, width: view.frame.width, height: _topview_height))
        view.addSubview(top_v)
        
        ///tableview
        tableview?.bounces = false
        tableview?.register(UINib (nibName: "DownloadDetailCell", bundle: nil), forCellReuseIdentifier: "DownloadDetailCellReuseId")
        tableview?.backgroundView = nil
        
        //close
        let closebtn = UIButton (frame: CGRect (x: 10, y: 0, width: 60, height: 40))
        //closebtn.setTitle("返回", for: .normal)
        closebtn.setImage(UIImage (named: "backhighlighted"), for: .normal)
        closebtn.setImage(UIImage (named: "backhighlighted"), for: .highlighted)
        closebtn.setTitleColor(UIColor.white, for: .normal)
        closebtn.imageEdgeInsets = UIEdgeInsetsMake(0, -50, 0, 0)
        closebtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        
        closebtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: 1)
        closebtn.addTarget(self, action: #selector(closeBtn), for: .touchUpInside)
        closebtn.tag = 100
        let litem = UIBarButtonItem (customView: closebtn)
        
        navigationItem.leftBarButtonItems = nil
        navigationItem.leftBarButtonItem = litem
        view.backgroundColor = UIColor.white
    }
    
    
    func topHeadView(_ frame:CGRect) -> UIView {
       let bg = UIView (frame: frame)
       //bg.backgroundColor = UIColor (colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 0.8)
        bg.backgroundColor = UIColor.darkGray
       let url_lab = UILabel (frame: CGRect (x: 10, y: 2, width: frame.width - 10, height: 35))
        url_lab.font = UIFont.boldSystemFont(ofSize: 20)
        url_lab.textColor = UIColor.white
        _urlLable = url_lab
        url_lab.text = ""
        bg.addSubview(url_lab)
       
        let s_lab = UILabel (frame: CGRect (x: 10, y: url_lab.frame.maxY, width: frame.width - 10, height:30))
        s_lab.font = UIFont.systemFont(ofSize: 16)
        s_lab.textColor = UIColor.white
        _statusLable = s_lab
        s_lab.text = ""
        bg.addSubview(s_lab)
        
        let progess = UIProgressView.init(progressViewStyle: .bar)
        progess.frame = CGRect (x: 0, y: s_lab.frame.maxY + 8, width: frame.width, height: 5)
        progess.transform = CGAffineTransform(scaleX: 1.0, y: 2);
        progess.trackTintColor = UIColor.lightGray
        
        progess.progress = 0.2
        _progressview = progess
        bg.addSubview(progess)
        return bg
    }

    func closeBtn(){
        if _timer != nil && _timer.isValid {
            _timer.invalidate();
        }
       self.dismiss(animated: false) { 
            let vc = DownloadViewController.init()
            let rect =  CGRect (x: 0, y: 0, width: Int(kCurrentScreenWidth - 200), height: 60 * 5)
            vc.view.frame = rect////////开始创建view
            
            let nav = BaseNavigationController(rootViewController:vc)
            nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
            nav.preferredContentSize = rect.size
            UIApplication.shared.keyWindow?.rootViewController?.present(nav, animated: false, completion: nil)
        }
    }
    
    //MARK:
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview?.dequeueReusableCell(withIdentifier: "DownloadDetailCellReuseId", for: indexPath) as! DownloadDetailCell
        let dic = dataArray[indexPath.row] as![String:Any]
        
        cell.fillCell(dic)
        cell.detailLab.textColor = indexPath.row == 0 ? UIColor.blue:UIColor.darkGray
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}



