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
    
    var current_download_cell:DownloadCell!
    var cell_status:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "更新列表"
        dsm.addObserver(self, forKeyPath: "ds_downloadprogress", options: .new, context: nil)
        dsm.addObserver(self, forKeyPath: "ds_serverupdatestatus", options: .new, context: nil)
    }

    deinit {
        dsm.removeObserver(self, forKeyPath: "ds_downloadprogress")
        dsm.removeObserver(self, forKeyPath: "ds_serverupdatestatus")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath ,let change = change ,let download_cell = current_download_cell  else {
            return
        }
        
        switch keyPath {
        case "ds_downloadprogress":
            if let change = change[NSKeyValueChangeKey.newKey] as? Float{
                //progressView.progress = change
                download_cell.progressview.progress = change
            };break
        case "ds_serverupdatestatus":
            if let change  = change[NSKeyValueChangeKey.newKey] as? Int{
                if change == 1{
                    print("++++++++++++++")
                    download_cell.statueLable.text = "下载文件: \(dsm.ds_currentDownloadCnt) / \(dsm.ds_totalDownloadCnt)"
                }else if change == 2{
                    download_cell.statueLable.text = "解压文件: \(dsm.ds_currentDownloadCnt) / \(dsm.ds_totalDownloadCnt)";
                }
            };break
            
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

        dataArray = DataSourceModel.search(with: nil, orderBy: nil) as! [DataSourceModel]
        tableview?.register(UINib.init(nibName: "DownloadCell", bundle: nil), forCellReuseIdentifier: "DownloadCellReuseIdentifierId")
        
        //checkupdatebtn
        let checkupdatebtn = UIButton (frame: CGRect (x: 0, y: 0, width: 100, height: 30))
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
        
        //DataSourceManager.default.checkupdateFromServer()
    }
    
    
    
    //MARK:-
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataArray.count == 0 {
            return getCellForNodata(tableView, info: "No airplane selected. please select an airplane first.")
        }
        
        let cell = tableview?.dequeueReusableCell(withIdentifier: "DownloadCellReuseIdentifierId", for: indexPath) as! DownloadCell
        cell.backgroundColor = UIColor.clear //UIColor.init(red: 109/255.0, green: 109/255.0, blue: 109/255.0, alpha: 1)
        let m = dataArray[indexPath.row] as! DataSourceModel
        cell.fileCellWith(m)
        
        //progressView = cell.progressview
        cell_status = cell.statueLable
        current_download_cell = cell
        if let m_url = m.location_url ,let s_url = dsm.ds_serverlocationurl {
            if m_url == s_url{
                current_download_cell = cell
            }
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DownloadDetailViewController()
        self.navigationController?.pushViewController(vc, animated: false)
        
//        let rect = CGRect (x: 0, y: 0, width: Int(kCurrentScreenWidth - 100), height: 60 * 8)
//        vc.view.frame = rect
//        vc.modalPresentationStyle = UIModalPresentationStyle.formSheet
//        vc.preferredContentSize = rect.size
        
//        let nav = BaseNavigationController(rootViewController:vc)
//        nav.modalPresentationStyle = .formSheet
//        nav.preferredContentSize = rect.size
//        self.present(vc, animated: false)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
