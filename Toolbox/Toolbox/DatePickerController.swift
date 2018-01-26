//
//  DatePickerController.swift
//  mcs
//
//  Created by gener on 2018/1/12.
//  Copyright © 2018年 Light. All rights reserved.
//

import UIKit

class DatePickerController: BasePickerViewController {

    @IBOutlet weak var datePicker: UIDatePicker!

    private var _row : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let _titlev = UILabel (frame: CGRect (x: 0, y: 0, width: 100, height: 30))
        _titlev.textColor = UIColor.white
        _titlev.text = "选择手册生效日期"
        navigationItem.titleView = _titlev
        
        // Do any additional setup after loading the view.
        _init()
    }

    
    func _init() {
        
        let now = dateToString(Date())
        let year = Int.init(now)
        
        let min = Date() //stringToDate("\(year!)")
        let max = stringToDate("\(year! + 2)")
        
        datePicker.minimumDate = min
        datePicker.maximumDate = max
        
    }
    

    //MARK:

    override func finishedBtnAction()  {

        if let handler = pickerDidSelectedHandler {
            let str = dateToString(datePicker.date,formatter: "yyyy-MM-dd")
            handler(str);
        }
        
        self.dismiss(animated: true, completion: nil)
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
