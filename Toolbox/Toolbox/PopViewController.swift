//
//  PopViewController.swift
//  Toolbox
//
//  Created by gener on 17/7/3.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class PopViewController: UIViewController {

    @IBOutlet weak var registryLab: UILabel!
    
    @IBOutlet weak var ownerLab: UILabel!
    
    @IBOutlet weak var tailLab: UILabel!
    
    @IBOutlet weak var msnLab: UILabel!
    
    @IBOutlet weak var variableLab: UILabel!
    
    @IBOutlet weak var cecLab: UILabel!
    
    @IBOutlet weak var modelLab: UILabel!
    
    @IBOutlet weak var lineLab: UILabel!
    
    var keyArray = ["Tail","Registry","MSN","Variable","CEC","MODEL","Line"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let lableArr:[UILabel] = [tailLab,msnLab,variableLab,cecLab,modelLab,lineLab];
        
        if let name = kSelectedAirplane?.operatorName,let code = kSelectedAirplane?.ownerCode {
            ownerLab.text = name + "(\(code))"
        }
        else{
            ownerLab.text = ""
        }
        
        display(title: kAIRPLANE_SORTEDOPTION_KEY, lable: registryLab)
        
        var lable_index = 0
        for value in keyArray {
            if value == kAIRPLANE_SORTEDOPTION_KEY {
                continue;
            }
 
            let _lab = lableArr[lable_index]
            lable_index += 1
            display(title: value, lable: _lab)
        }

    }

    func display(title:String,lable:UILabel) {
        let key:String! = kAirplaneKeyValue[title]
        
        if let airplane = kSelectedAirplane {
            let value = airplane.value(forKey: key) as! String
            
            if value != "" {
                lable.text = title + " " +  value
            }else{
                lable.text = "No \(title)"
            }
        }else{
            lable.text = "No \(title)"
        }

        
        
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
