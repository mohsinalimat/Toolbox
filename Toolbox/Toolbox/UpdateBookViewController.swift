//
//  UpdateBookViewController.swift
//  Toolbox
//
//  Created by gener on 17/8/11.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class UpdateBookViewController: BaseViewController {

    @IBOutlet weak var updateNumberLab: UILabel!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    
    var hasProgressnumber = 0
    var totalBookssnumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.black
        
        NotificationCenter.default.addObserver(self, selector: #selector(unzipfileFinish(_:)), name: NSNotification.Name (rawValue: "kNotification_book_update_complete"), object: nil)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activity.startAnimating()
        updateNumberLab.text = "更新文件:\(hasProgressnumber)/\(totalBookssnumber)"
    }
    
    
    func unzipfileFinish(_ noti:Notification) {
        hasProgressnumber = hasProgressnumber + 1
        
        updateNumberLab.text = "更新文件:\(hasProgressnumber)/\(totalBookssnumber)"
        
        if  hasProgressnumber == totalBookssnumber {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                self.activity.stopAnimating()
                
                self.dismiss(animated: false, completion: nil)
                NotificationCenter.default.post(Notification.init(name: NSNotification.Name (rawValue: "kNotification_allbooksupdate_complete")))
                
            })
        }
    }
    
    deinit {
        print("UpdateBookViewController deinit....")
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
