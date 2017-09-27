//
//  DownloadViewController.swift
//  Toolbox
//
//  Created by gener on 17/9/5.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class DownloadViewController: BaseViewControllerWithTable {

    var ttt :Int = 0
    //var progressView : UIProgressView!
    
    let dsm = DataSourceManager.default
    let unzip = UNZIPFile.default
    
    var current_download_cell:DownloadCell!
    var cell_status:UILabel!
    var is_loading :Bool = true
    
    var _timer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "更新列表"
        dsm.addObserver(self, forKeyPath: "ds_downloadprogress", options: .new, context: nil)
        dsm.addObserver(self, forKeyPath: "ds_currentDownloadCnt", options: .new, context: nil)
        dsm.addObserver(self, forKeyPath: "ds_totalDownloadCnt", options: .new, context: nil)
        
        unzip.addObserver(self, forKeyPath: "zip_total_filescnt", options: .new, context: nil)
        unzip.addObserver(self, forKeyPath: "zip_current_filescnt", options: .new, context: nil)
        unzip.addObserver(self, forKeyPath: "zip_unzip_progress", options: .new, context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(unzipAllComplete(_:)), name: NSNotification.Name (rawValue: "kNotification_unzip_all_complete"), object: nil)
        
        _timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        RunLoop.main.add(_timer, forMode: RunLoopMode.commonModes);
        
    }

    func timerAction()  {
       let arr = DataSourceModel.search(with: nil, orderBy: "location_url asc") as! [DataSourceModel]
        dataArray.removeAll()
        dataArray = dataArray + arr
        
        tableview?.reloadData()
    }
    
    
    
    deinit {
        _timer.invalidate()
        _timer = nil
        
        dsm.removeObserver(self, forKeyPath: "ds_downloadprogress")
        dsm.removeObserver(self, forKeyPath: "ds_currentDownloadCnt")
        dsm.removeObserver(self, forKeyPath: "ds_totalDownloadCnt")
        
        unzip.removeObserver(self, forKeyPath: "zip_total_filescnt")
        unzip.removeObserver(self, forKeyPath: "zip_current_filescnt")
        unzip.removeObserver(self, forKeyPath: "zip_unzip_progress")
        NotificationCenter.default.removeObserver(self)
        print("deinit DownloadViewController")
    }
    
    func unzipAllComplete(_ noti:Notification) {
        if DataSourceManager.default.unzipQueueIsEmpty().0 {
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        return
        
        guard let keyPath = keyPath ,let change = change ,let download_cell = current_download_cell  else {
            return
        }
        
        switch keyPath {
        case "ds_downloadprogress","zip_unzip_progress":
            if let change = change[NSKeyValueChangeKey.newKey] as? Float{
                download_cell.progressview.progress = change
            };break
            
       case "ds_totalDownloadCnt","ds_currentDownloadCnt":
            download_cell.statueLable.text = "下载文件: \(dsm.ds_currentDownloadCnt) / \(dsm.ds_totalDownloadCnt)"
            break
        case "zip_total_filescnt","zip_current_filescnt":
            download_cell.statueLable.text = "解压文件: \(unzip.zip_current_filescnt) / \(unzip.zip_total_filescnt)"
            break
        case "ds_serverlocationurl"://数据源改变，刷新列表
            if let change = change[NSKeyValueChangeKey.newKey] as? String{
                
                
            };
            break
            
        default:break
        }
        
    }
    
    
    override func initSubview() {
        tableview?.frame = CGRect (x: 0, y: 0, width: Int(kCurrentScreenWidth - 200), height: 60 * 5)
        tableview?.backgroundColor = UIColor.init(red: 109/255.0, green: 109/255.0, blue: 109/255.0, alpha: 0.6)
        tableview?.backgroundView = nil
        tableview?.separatorStyle = .none
        tableview?.bounces = true
        tableview?.showsVerticalScrollIndicator = false
        needtitleView = false

        dataArray = DataSourceModel.search(with: nil, orderBy: "location_url asc") as! [DataSourceModel]
        tableview?.register(UINib.init(nibName: "DownloadCell", bundle: nil), forCellReuseIdentifier: "DownloadCellReuseIdentifierId")

        //checkupdatebtn
        let checkupdatebtn = UIButton (frame: CGRect (x: 0, y: 0, width: 100, height: 40))
        checkupdatebtn.setBackgroundImage(UIImage (named: "donwload_data_button"), for: .normal)
        checkupdatebtn.setBackgroundImage(UIImage (named: "donwload_data_button"), for: .highlighted)
        checkupdatebtn.setTitle("检测更新", for: .normal)
        checkupdatebtn.setTitleColor(UIColor.white, for: .normal)
        checkupdatebtn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: 1)
        checkupdatebtn.addTarget(self, action: #selector(checkUpdateBtn), for: .touchUpInside)
        checkupdatebtn.tag = 100
        checkupdatebtn.layer.cornerRadius = 10
        checkupdatebtn.layer.masksToBounds = true
        let ritem = UIBarButtonItem (customView: checkupdatebtn)
        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = ritem
    
        //close
        let closebtn = UIButton (frame: CGRect (x: 0, y: 0, width: 60, height: 40))
        closebtn.setTitle("取消", for: .normal)
        closebtn.setTitleColor(UIColor.white, for: .normal)
        closebtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: 1)
        closebtn.addTarget(self, action: #selector(closeBtn), for: .touchUpInside)
        closebtn.tag = 100
        let litem = UIBarButtonItem (customView: closebtn)
        navigationItem.leftBarButtonItem = litem
    }
    

    //MARK:
    func closeBtn(){
        self.dismiss(animated: false, completion: nil)
    }
    
    func checkUpdateBtn() {
        NotificationCenter.default.post(name: NSNotification.Name (rawValue: "knotification_check_ds_update"), object: nil)
        self.dismiss(animated: false, completion: nil)
    }
    
    
    
    //MARK:-
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataArray.count == 0 {
            return getCellForNodata(tableView, info: "No DataSource.")
        }
        
        let cell = tableview?.dequeueReusableCell(withIdentifier: "DownloadCellReuseIdentifierId", for: indexPath) as! DownloadCell
        cell.backgroundColor = UIColor.clear //UIColor.init(red: 109/255.0, green: 109/255.0, blue: 109/255.0, alpha: 1)
        let m = dataArray[indexPath.row] as! DataSourceModel
        cell.fileCellWith(m)
        
        //progressView = cell.progressview
        //cell_status = cell.statueLable
        //current_download_cell = cell
        /*if let m_url = m.location_url ,let s_url = dsm.ds_serverlocationurl {
            if m_url == s_url{
                current_download_cell = cell
            }
        }*/
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DownloadDetailViewController()
        self.navigationController?.pushViewController(vc, animated: false)
        
  
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
