//
//  BasePickerViewController.swift
//  mcs
//
//  Created by gener on 2018/1/12.
//  Copyright © 2018年 Light. All rights reserved.
//

import UIKit

class BasePickerViewController: BaseViewController {

    var pickerDidSelectedHandler:((String) -> Void)?//选中操作回调
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addNavigationItem();
        
    }

    func stringToDate(_ dateStr:String, formatter:String = "yyyy") -> Date {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = formatter
        
        return dateFormatter.date(from: dateStr)!
    }
    
    func dateToString(_ date:Date, formatter:String = "yyyy") -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = formatter
        
        return dateFormatter.string(from: date)
    }
    
    
    func addNavigationItem()  {
        //checkupdatebtn
        let finishedbtn = UIButton (frame: CGRect (x: 0, y: 0, width: 60, height: 40))
        finishedbtn.setTitle("确定", for: .normal)
        finishedbtn.setTitleColor(UIColor.white, for: .normal)
        finishedbtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: 1)
        finishedbtn.addTarget(self, action: #selector(finishedBtnAction), for: .touchUpInside)
        finishedbtn.tag = 100
        finishedbtn.layer.cornerRadius = 10
        finishedbtn.layer.masksToBounds = true
        let ritem = UIBarButtonItem (customView: finishedbtn)
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
        self.dismiss(animated: true, completion: nil)
    }
    
    func finishedBtnAction() {}
    
    
    
    
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
