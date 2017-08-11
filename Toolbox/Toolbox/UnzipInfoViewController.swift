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
        
        NotificationCenter.default.addObserver(self, selector: #selector(unzipfileFinish(_:)), name: NSNotification.Name (rawValue: "kNotification_unzipfile_complete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unzipfileNunber(_:)), name: NSNotification.Name (rawValue: "kNotification_unzipfile_filesnumber"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(startParsebook(_:)), name: NSNotification.Name (rawValue: "kNotification_start_parseAndMove"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func startParsebook(_ noti:Notification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01, execute: {
            
        })
    }
    
    func unzipfileFinish(_ noti:Notification) {
        hasUnzipFilesnumber = hasUnzipFilesnumber + 1
        fileNumber.text = "(安装文件: \(hasUnzipFilesnumber)/\(totalUnzipFilsnumber))"
        
        if hasUnzipFilesnumber == totalUnzipFilsnumber {
            self.dismiss(animated: false, completion: nil)
            kUnzipprogress = nil
        }
    }
    
    func unzipfileNunber(_ noti:Notification) {
        let num = noti.userInfo?["filesnumber"] as? Int
        if let num = num{
            totalUnzipFilsnumber = num
            fileNumber.text = "(安装文件: \(hasUnzipFilesnumber)/\(totalUnzipFilsnumber))"
        }
        
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
