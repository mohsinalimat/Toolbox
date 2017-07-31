//
//  BookmarksCell.swift
//  Toolbox
//
//  Created by gener on 17/7/4.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class BookmarksCell: UITableViewCell {

    @IBOutlet weak var colorLable: UILabel!
    
    @IBOutlet weak var headLable: UILabel!
    
    @IBOutlet weak var contentBg: UIView!
    
    @IBOutlet weak var contentTitleLable: UILabel!
    
    @IBOutlet weak var contentSubTitleLable: UILabel!
    
    @IBOutlet weak var contentSubTitleLable2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        layer.borderColor = UIColor (red: 212/255.0, green: 212/255.0, blue: 212/255.0, alpha: 0.8).cgColor
        layer.borderWidth = 0.5
    }
    
    
    
    func fillCell(model:BookmarkModel) {
        headLable.text = model.pub_doc_abbreviation
        contentTitleLable.text = model.seg_original_tag.uppercased() + " " +  model.seg_toc_code
        contentSubTitleLable.text = model.seg_title
        contentSubTitleLable2.text = model.pub_book_uuid + "·" + model.pub_document_owner  + "·" + model.pub_model

        let docabbr = model.pub_doc_abbreviation
        guard let type = docabbr else {
            return
        }
        colorLable.backgroundColor = kDOCTYPEColor[type]
        
        
    }
    
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
