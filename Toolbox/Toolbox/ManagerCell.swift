//
//  ManagerCell.swift
//  Toolbox
//
//  Created by gener on 17/6/30.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class ManagerCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var colorFlagLable: UILabel!
    @IBOutlet weak var titleLable: UILabel!
    
    @IBOutlet weak var stitleLable: UILabel!
    @IBOutlet weak var sownerLable: UILabel!
    @IBOutlet weak var smodelLable: UILabel!
    @IBOutlet weak var sdocLable: UILabel!
    @IBOutlet weak var srevLable: UILabel!
    @IBOutlet weak var sdateLable: UILabel!
    @IBOutlet weak var openButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        layer.borderColor = UIColor (red: 212/255.0, green: 212/255.0, blue: 212/255.0, alpha: 0.8).cgColor
        layer.borderWidth = 0.5
        
        titleLable.backgroundColor = UIColor (red: 43/255.0, green: 123/255.0, blue: 181/255.0, alpha: 0.7)
    }

    override func prepareForReuse() {
     
    }
    
    
    func cellIsSelected(_ selected : Bool) {
        if selected {
            bgView.backgroundColor = UIColor (red: 43/255.0, green: 123/255.0, blue: 181/255.0, alpha: 0.7)
            layer.borderWidth = 0
            openButton.isSelected = true
            
            stitleLable.textColor = UIColor.white
            sownerLable.textColor = UIColor.white
            smodelLable.textColor = UIColor.white
            sdocLable.textColor = UIColor.white
            srevLable.textColor = UIColor.white
            sdateLable.textColor = UIColor.white
        }
        else
        {
            bgView.backgroundColor = UIColor.white
            layer.borderWidth = 0.5
            openButton.isSelected = false
            
            stitleLable.textColor = UIColor.black
            sownerLable.textColor = UIColor.black
            smodelLable.textColor = UIColor.black
            sdocLable.textColor = UIColor.black
            srevLable.textColor = UIColor.black
            sdateLable.textColor = UIColor.black
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
