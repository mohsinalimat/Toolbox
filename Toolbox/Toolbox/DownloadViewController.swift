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
    var progressView : UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "更新列表"

        let dsm = DataSourceManager.default
        dsm.addObserver(self, forKeyPath: "ds_downloadprogress", options: .new, context: nil)
    }

    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let change = change?[NSKeyValueChangeKey.newKey] as? Float {
            progressView.progress = change
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
        DataSourceManager.default.checkupdateFromServer()
    }
    
    
    
    //MARK:-
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview?.dequeueReusableCell(withIdentifier: "DownloadCellReuseIdentifierId", for: indexPath) as! DownloadCell
        //cell.backgroundView = nil
        cell.backgroundColor = UIColor.clear //UIColor.init(red: 109/255.0, green: 109/255.0, blue: 109/255.0, alpha: 1)
        let m = dataArray[indexPath.row] as! DataSourceModel
        cell.fileCellWith(m)
        
        progressView = cell.progressview
        
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
//        
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
