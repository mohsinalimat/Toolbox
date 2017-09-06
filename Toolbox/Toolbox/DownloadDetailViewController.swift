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
        
        dataArray = ["Test"]
        title = "更新信息"
    }

    override func initSubview() {
        needtitleView = false
        navigationItem.rightBarButtonItems = nil
        
        tableview?.frame = CGRect (x: 0, y: 0, width: Int(kCurrentScreenWidth - 100), height: 60 * 8)
        
        //close
        let closebtn = UIButton (frame: CGRect (x: 0, y: 0, width: 60, height: 40))
//        closebtn.setTitle("返回", for: .normal)
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
    
    
    func closeBtn(){
        
       _ = self.navigationController?.popViewController(animated: false)
//        self.dismiss(animated: false, completion: nil)
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
