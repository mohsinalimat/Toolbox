//
//  DownloadCell.swift
//  Toolbox
//
//  Created by gener on 17/9/5.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class DownloadCell: UITableViewCell {

    @IBOutlet weak var dsLocationLable: UILabel!
    
    @IBOutlet weak var statueLable: UILabel!
    
    @IBOutlet weak var statueIconBtn: UIButton!
    
    @IBOutlet weak var progressview: UIProgressView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        progressview.progress = 0
    }

    
    
    func fileCellWith(_ model:DataSourceModel) {
        
        dsLocationLable.text = model.location_url
        
    }
    
    
    override func prepareForReuse() {
        progressview.progress = 0
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
