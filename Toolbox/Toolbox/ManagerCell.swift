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
        _init()
    }
    
    func fillCell(model:PublicationsModel,title:String = "airplaneRegistry") {
        titleLable.text = model.display_title
        stitleLable.text = model.display_title
        sownerLable.text = model.document_owner
        smodelLable.text = model.model
        sdocLable.text = model.doc_number
        srevLable.text = model.revision_number
        sdateLable.text = model.revision_date
        
        let docabbr = model.doc_abbreviation
        guard let type = docabbr else {
            return
        }
        colorFlagLable.backgroundColor = kDOCTYPEColor[type]
        
        
    }

    func _init() {
        bgView.backgroundColor = UIColor.white
        layer.borderWidth = 0.5
        openButton.isSelected = false
        
        let textColor = UIColor.black
        stitleLable.textColor = textColor
        sownerLable.textColor = textColor
        smodelLable.textColor = textColor
        sdocLable.textColor = textColor
        srevLable.textColor = textColor
        sdateLable.textColor = textColor
 
    }
    
    func cellIsSelected(_ selected : Bool) {
        if selected {
            //bgView.backgroundColor = kAirplaneCell_head_selected_color //UIColor (red: 43/255.0, green: 123/255.0, blue: 181/255.0, alpha: 0.7)
            layer.borderWidth = 0
            openButton.isSelected = true
            
            let textColor = kAirplaneCell_head_selected_color
            stitleLable.textColor = textColor
            sownerLable.textColor = textColor
            smodelLable.textColor = textColor
            sdocLable.textColor = textColor
            srevLable.textColor = textColor
            sdateLable.textColor = textColor
        }
        else
        {
            _init()
        }
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
