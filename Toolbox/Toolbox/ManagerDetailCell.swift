//
//  ManagerDetailCell.swift
//  Toolbox
//
//  Created by gener on 17/6/30.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class ManagerDetailCell: UITableViewCell {

    @IBOutlet weak var modifydateLable: UILabel!
    
    @IBOutlet weak var orderDateLable: UILabel!
    
    @IBOutlet weak var updateDateLable: UILabel!
    
    @IBOutlet weak var packagenameLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
         backgroundColor = UIColor(red: 167/255.0, green: 191/255.0, blue: 206/255.0, alpha: 1)
    }

    
    func fillCell(model:PublicationsModel,title:String = "airplaneRegistry") {
        modifydateLable.text = model.publish_date
        orderDateLable.text = model.publish_date
        updateDateLable.text = model.publish_date
        
        packagenameLable.text = model.publication_id + ".ZIP"
        
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
