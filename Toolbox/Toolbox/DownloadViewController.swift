//
//  DownloadViewController.swift
//  Toolbox
//
//  Created by gener on 17/9/5.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class DownloadViewController: UIViewController {

    var popViewDataArray = ["Publications","Document Type","Document #","Document Title","Modified Date"]
    var ttt :Int = 0
    
    var _navigationController:BaseNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initSubviews()
    }

    
    func initSubviews( ) {
        let vc = BaseViewControllerWithTable.init()
        //...先赋值？才会走到 viewDidLoad
        vc.needtitleView = false
        vc.view.frame =  CGRect (x: 0, y: 0, width: Int(kCurrentScreenWidth - 200), height: 60 * 5)
        vc.dataArray = popViewDataArray
        vc.navigationItem.rightBarButtonItems = nil
        title = "Updates"
        
        vc.kTableviewCellRowHeight = 60
        vc.tableview?.backgroundColor = UIColor.lightGray
        vc.tableview?.backgroundView = nil
        vc.tableview?.frame = view.frame
        vc.tableview?.separatorStyle = .singleLine
        vc.tableview?.bounces = true
        vc.tableview?.showsVerticalScrollIndicator = false
        vc.cellSelectedAction = {
            index in
            
        }
        
        //checkupdatebtn
        let checkupdatebtn = UIButton (frame: CGRect (x: 0, y: 0, width: 100, height: 40))
        checkupdatebtn.setBackgroundImage(UIImage (named: "donwload_data_button"), for: .normal)
        checkupdatebtn.setBackgroundImage(UIImage (named: "donwload_data_button"), for: .highlighted)
        checkupdatebtn.setTitle("检测更新", for: .normal)
        checkupdatebtn.setTitleColor(UIColor.white, for: .normal)
        checkupdatebtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: 1)
        checkupdatebtn.addTarget(self, action: #selector(closeBtn), for: .touchUpInside)
        checkupdatebtn.tag = 100
        let ritem = UIBarButtonItem (customView: checkupdatebtn)
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
        
        self.view.addSubview(vc.view)
    }
    
    
    func closeBtn(){
        _navigationController?.dismiss(animated: false, completion: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
