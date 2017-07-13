//
//  AirplaneSubCell.swift
//  Toolbox
//
//  Created by gener on 17/6/27.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class AirplaneSubCell: UITableViewCell {
    @IBOutlet weak var titleLable_1: UILabel!
    @IBOutlet weak var valueLable_1: UILabel!
    @IBOutlet weak var titleLable_2: UILabel!
    @IBOutlet weak var valueLable_2: UILabel!
    @IBOutlet weak var titleLable_3: UILabel!
    @IBOutlet weak var valueLable_3: UILabel!
    @IBOutlet weak var titleLable_4: UILabel!
    @IBOutlet weak var valueLable_4: UILabel!
    @IBOutlet weak var titleLable_5: UILabel!
    @IBOutlet weak var valueLable_5: UILabel!

    let valueforKey:[String:String]! =
        ["Tail":"tailNumber",//对应的数据库字段
        "Registry":"airplaneRegistry",
        "MSN":"airplaneSerialNumber",
        "Variable":"airplaneId",
        "CEC":"customerEffectivity",
        "Line":"airplaneLineNumber",
        ];

    var keyArray = ["Tail","Registry","MSN","Variable","CEC","Line"]
    

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = UIColor(red: 167/255.0, green: 191/255.0, blue: 206/255.0, alpha: 1)
        
    }

    override func prepareForReuse() {
        keyArray = ["Tail","Registry","MSN","Variable","CEC","Line"]
        let titleLableArr:[UILabel] = [titleLable_1,titleLable_2,titleLable_3,titleLable_4,titleLable_5]
        let valueLableArr:[UILabel] = [valueLable_1,valueLable_2,valueLable_3,valueLable_4,valueLable_5]
        
        for index in 0..<5 {
            let titleL = titleLableArr[index]
            let valueL = valueLableArr[index]
            titleL.text = ""
            valueL.text = ""
        }
    }
    
    func fillCell(model:AirplaneModel,title:String = "Registry") {
        keyArray.remove(at: keyArray.index(of: title)!)
        
        let titleArr:[UILabel] = [titleLable_1,titleLable_2,titleLable_3,titleLable_4,titleLable_5]
        let valueArr:[UILabel] = [valueLable_1,valueLable_2,valueLable_3,valueLable_4,valueLable_5]
        for (index,key) in keyArray.enumerated() {
            let value = valueforKey[key]
            let titleL = titleArr[index]
            let valueL = valueArr[index]
            titleL.text = key + ":"
            valueL.text = model.value(forKey: value!)as?String
            
        }

    }
    
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
