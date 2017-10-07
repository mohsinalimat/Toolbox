//
//  DownloadDetailCell.swift
//  Toolbox
//
//  Created by wyg on 2017/10/7.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class DownloadDetailCell: UITableViewCell {

    @IBOutlet weak var titleLab: UILabel!
   
    @IBOutlet weak var detailLab: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.borderColor  = UIColor.init(colorLiteralRed: 100/255.0, green: 100/255.0, blue: 100/255.0, alpha: 0.15).cgColor

        layer.borderWidth = 0.25
        
    }

    func fillCell(_ dic:[String:Any]) {
        for (key,value) in dic{
            titleLab.text = key
            detailLab.text = "\(value)"

        }
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
