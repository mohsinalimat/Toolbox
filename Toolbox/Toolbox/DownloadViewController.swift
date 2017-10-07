//
//  DownloadViewController.swift
//  Toolbox
//
//  Created by gener on 17/9/5.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class DownloadViewController: BaseViewControllerWithTable {
    var _timer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "更新列表"
        NotificationCenter.default.addObserver(self, selector: #selector(unzipAllComplete(_:)), name: NSNotification.Name (rawValue: "kNotification_unzip_all_complete"), object: nil)
        
        _timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        RunLoop.main.add(_timer, forMode: RunLoopMode.commonModes);
    }

    func unzipAllComplete(_ noti:Notification) {
        //防止要显示更新列表，多数据源情况下，一个数据源安装完成其他的还在进行中，视图dismiss。
        if DataSourceManager.default.unzipQueueIsEmpty().0 {
            _timer.invalidate()
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func timerAction()  {
       let arr = DataSourceModel.search(with: nil, orderBy: "location_url asc") as! [DataSourceModel]
        dataArray.removeAll()
        dataArray = dataArray + arr
        
        tableview?.reloadData()
    }
    
    
    
    deinit {
        _timer = nil
        print("DownloadViewController")
        NotificationCenter.default.removeObserver(self)
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
        _timer.invalidate()
        
        self.dismiss(animated: false, completion: nil)
    }
    
    func checkUpdateBtn() {
        NotificationCenter.default.post(name: NSNotification.Name (rawValue: "knotification_check_ds_update"), object: nil)
        _timer.invalidate()
        self.dismiss(animated: false, completion: nil)
    }

    //MARK:-
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataArray.count == 0 {
            return getCellForNodata(tableView, info: "NO DATASOURCE")
        }
        
        let cell = tableview?.dequeueReusableCell(withIdentifier: "DownloadCellReuseIdentifierId", for: indexPath) as! DownloadCell
        cell.backgroundColor = UIColor.clear //UIColor.init(red: 109/255.0, green: 109/255.0, blue: 109/255.0, alpha: 1)
        let m = dataArray[indexPath.row] as! DataSourceModel
        cell.fileCellWith(m)

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _timer.invalidate()
        let m = dataArray[indexPath.row] as! DataSourceModel
        self.dismiss(animated: false) { 
            let vc = DownloadDetailViewController.init()
            let rect =  CGRect (x: 0, y: 0, width: Int(kCurrentScreenWidth - 50), height: Int(kCurrentScreenHight - 100))
            vc.view.frame = rect////////开始创建view
            vc.url = m.location_url
            
            let nav = BaseNavigationController(rootViewController:vc)
            nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
            nav.preferredContentSize = rect.size
            
            UIApplication.shared.keyWindow?.rootViewController?.present(nav, animated: false, completion: nil)
            //self.present(nav, animated: false)
        }
        
        
        
//        let vc = DownloadDetailViewController()
//        self.navigationController?.pushViewController(vc, animated: false)
        
  
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
