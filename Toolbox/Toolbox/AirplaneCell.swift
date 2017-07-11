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
    
    
    let cellSelectBgColor = UIColor (red: 55/255.0, green: 148/255.0, blue: 202/255.0, alpha: 1)
//    let cellSelectBgColor = UIColor.init(patternImage: UIImage (named: "openCell_hl_arro")!)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.borderColor = UIColor (red: 212/255.0, green: 212/255.0, blue: 212/255.0, alpha: 0.8).cgColor
        layer.borderWidth = 0.5
        
    }

    
    func fillCell(model:AirplaneModel) {
        registryNameLable.text = model.airplaneRegistry != "" ? model.airplaneRegistry : "No Registry"
        majormodelLable.text = model.airplaneMajorModel + "-" + model.airplaneMinorModel
        
    }
    
    
    override func prepareForReuse() {
        cellBtn.isSelected = false
        backgroundColor = UIColor.white
        registryNameLable.textColor = UIColor.black
         imgview.image = UIImage (named: "plane_lt_blue")
    }
    

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
    
  
    
    func cellSelectedInit(){
        self.backgroundColor = cellSelectBgColor
        registryNameLable.textColor = UIColor.white
        imgview.image = UIImage (named: "plane_drk_gry")
        cellBtn.isSelected = true
        layer.borderWidth = 0
    }
    
    
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}


