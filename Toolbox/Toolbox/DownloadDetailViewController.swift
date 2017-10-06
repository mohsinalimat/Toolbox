//
//  DownloadDetailViewController.swift
//  Toolbox
//
//  Created by gener on 17/9/6.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class DownloadDetailViewController: BaseViewControllerWithTable {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        dataArray = ["1","1","1","1","1","1","1"]
        
        title = "更新信息"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let rect = view.frame
        tableview?.frame = CGRect (x: 0, y: 100, width: rect.width, height: rect.height - 100)
    }
    
    
    override func initSubview() {
        needtitleView = false
        navigationItem.rightBarButtonItems = nil
        
        let top_v = UIView (frame: CGRect (x: 0, y: 0, width: view.frame.width, height: 100))
        top_v.backgroundColor = UIColor (colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
        
        view.addSubview(top_v)
        
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
    
    deinit{
        print("DownloadDetailViewController")
    }
    
    
    func closeBtn(){
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview?.dequeueReusableCell(withIdentifier: "DownloadDetailCellReuseId", for: indexPath) as! DownloadDetailCell
        cell.fillCell()
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
