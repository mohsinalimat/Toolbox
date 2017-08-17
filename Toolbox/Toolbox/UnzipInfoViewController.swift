//
//  UnzipInfoViewController.swift
//  Toolbox
//
//  Created by gener on 17/8/11.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class UnzipInfoViewController: BaseViewController {

    @IBOutlet weak var progress: UIProgressView!
    
    @IBOutlet weak var fileNumber: UILabel!
    
    var hasUnzipFilesnumber = 0
    var totalUnzipFilsnumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = kTableviewBackgroundColor
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(unzipSinglefileFinish(_:)), name: NSNotification.Name (rawValue: "kNotification_unzipsinglefile_complete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unzipfileNunber(_:)), name: NSNotification.Name (rawValue: "kNotification_unzipfile_totalnumber"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unzipAllComplete(_:)), name: NSNotification.Name (rawValue: "kNotification_unzip_all_complete"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if totalUnzipFilsnumber == 0{
            HUD.show(withStatus: "文件分析中...")
        }
        
        
        fileNumber.text = "(安装文件: \(hasUnzipFilesnumber)/\(totalUnzipFilsnumber))"
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func unzipfileNunber(_ noti:Notification) {
        print("通知-解压文件数.")
        HUD.dismiss()
        
        let num = noti.userInfo?["filesnumber"] as? Int
        if let num = num{
            totalUnzipFilsnumber = num
            fileNumber.text = "(安装文件: \(hasUnzipFilesnumber)/\(totalUnzipFilsnumber))"
        }
        
    }
    
    
    func unzipSinglefileFinish(_ noti:Notification) {
        hasUnzipFilesnumber = hasUnzipFilesnumber + 1
        fileNumber.text = "(安装文件: \(hasUnzipFilesnumber)/\(totalUnzipFilsnumber))"
        
        print("通知-解压单个文件完成.")
        if hasUnzipFilesnumber == totalUnzipFilsnumber {
//            self.dismiss(animated: false, completion: nil)
//            kUnzipprogress = nil
        }
    }
    

    
    func unzipAllComplete(_ noti:Notification) {
        self.dismiss(animated: false, completion: nil)
        kUnzipprogress = nil
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("deinit....")
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
