//
//  SegmentCell.swift
//  Toolbox
//
//  Created by gener on 17/7/21.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class SegmentCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var headTitleLable: UILabel!
    @IBOutlet weak var detailLable: UILabel!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var headIndentValue: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        headIndentValue.constant = 80.0
    }

    
    
    func fillCell(model:SegmentModel) {
        headTitleLable.text = (model.original_tag).uppercased() + " \(model.toc_code!)"
        detailLable.text = model.tocdisplayeff
        titleLable.text = model.title
    
    }
    
    override func prepareForReuse() {
//        initStatus()
    }
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
