//
//  PublicationCell.swift
//  Toolbox
//
//  Created by gener on 17/6/30.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class PublicationCell: UITableViewCell {

    @IBOutlet weak var colorLable: UILabel!
    
    @IBOutlet weak var headLable: UILabel!
    
    @IBOutlet weak var contentBg: UIView!
    
    @IBOutlet weak var contentTitleLable: UILabel!
    
    @IBOutlet weak var contentSubTitleLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.borderColor = UIColor (red: 212/255.0, green: 212/255.0, blue: 212/255.0, alpha: 0.8).cgColor
        layer.borderWidth = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
