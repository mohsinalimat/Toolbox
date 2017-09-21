//
//  AirplaneCell.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class AirplaneCell: UITableViewCell {

    @IBOutlet weak var imgview: UIImageView!
    
    @IBOutlet weak var registryNameLable: UILabel!
    
    @IBOutlet weak var majormodelLable: UILabel!
    
    @IBOutlet weak var cellBtn: UIButton!
    
    var  clickCellBtnAction:((Bool) -> (Void))?
    let nullvalueInfo = [
        "airplaneRegistry":"No Registry",
        "tailNumber":"No Tail"
    ]
    
    let cellSelectBgColor = UIColor (red: 55/255.0, green: 148/255.0, blue: 202/255.0, alpha: 1)
//    let cellSelectBgColor = UIColor.init(patternImage: UIImage (named: "openCell_hl_arro")!)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.borderColor = UIColor (red: 212/255.0, green: 212/255.0, blue: 212/255.0, alpha: 0.8).cgColor
        _init()
    }

    
    func fillCell(model:AirplaneModel,title:String = "airplaneRegistry") {
        let t = model.value(forKey: title)as?String
        registryNameLable.text = t != "" ? t : nullvalueInfo[title]
        majormodelLable.text = model.airplaneMajorModel + "-" + model.airplaneMinorModel
        
    }
    
    
    override func prepareForReuse() {
        cellBtn.isSelected = false
        backgroundColor = UIColor.white

        _init()

    }
    
    func _init() {
        registryNameLable.textColor = kAirplaneCell_head_normal_color
        majormodelLable.textColor = kAirplaneCell_subhead_normal_color
        imgview.image = UIImage (named: "plane_drk_gry")
        cellBtn.isSelected = false
        layer.borderWidth = 0.5
    }
    
    
    func cellSelectedInit(){
        //self.backgroundColor = cellSelectBgColor
        registryNameLable.textColor = kAirplaneCell_head_selected_color
        majormodelLable.textColor = kAirplaneCell_head_selected_color
        
        imgview.image = UIImage (named: "plane_lt_blue")
        cellBtn.isSelected = true
        layer.borderWidth = 0
    }
    

    //cell 展开事件
    @IBAction func cellBtnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        var str = ""
        if sender.isSelected{
            self.backgroundColor = cellSelectBgColor
            str = "plane_drk_gry"
            registryNameLable.textColor = UIColor.white
            layer.borderWidth = 0
        }
        else
        {
            self.backgroundColor = UIColor.white
            str = "plane_lt_blue"
            registryNameLable.textColor = UIColor.black
            layer.borderWidth = 0.5
        }
        
        imgview.image = UIImage (named: str)
        
        if let cellBtnBlock =  clickCellBtnAction{
            cellBtnBlock(sender.isSelected)
        }
    }
    
 
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}


