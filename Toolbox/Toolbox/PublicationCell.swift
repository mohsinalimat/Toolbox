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

    func fillCell(model:PublicationsModel,title:String = "airplaneRegistry") {
        headLable.text = model.display_title
        contentTitleLable.text = model.display_title
        contentSubTitleLable.text = "Rev \(model.revision_number!) · \(model.revision_date!) · \(model.doc_number!)"
        
        let docabbr = model.doc_abbreviation
        guard let type = docabbr else {
            return
        }
        colorLable.backgroundColor = kDOCTYPEColor[type]
        
        
    }
    
    override func prepareForReuse() {
        initStatus()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            headLable.backgroundColor = UIColor (red: 25/255.0, green: 60/255.0, blue: 101/255.0, alpha: 1)
            contentBg.backgroundColor = UIColor.white
            contentTitleLable.textColor = UIColor (red: 42/255.0, green: 78/255.0, blue: 115/255.0, alpha: 1)
            contentSubTitleLable.textColor = UIColor (red: 42/255.0, green: 78/255.0, blue: 115/255.0, alpha: 1)
        }
        else
        {
            initStatus()
        }
        
    }
    
    
    //初始状态
    private func initStatus(){
        headLable.backgroundColor = UIColor (red: 47/255.0, green: 125/255.0, blue: 178/255.0, alpha: 1)
        contentBg.backgroundColor = UIColor (red: 224/255.0, green: 224/255.0, blue: 224/255.0, alpha: 1)
        contentTitleLable.textColor = UIColor.black
        contentSubTitleLable.textColor = UIColor.darkGray
        
    }
}
