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
        statueLable.text = " "
    }

    
    
    func fileCellWith(_ model:DataSourceModel) {
        
        dsLocationLable.text = model.location_url
        
        switch model.update_status {
        case 1:
            statueLable.text = "下载文件: \(DataSourceManager.default.ds_currentDownloadCnt) / \(DataSourceManager.default.ds_totalDownloadCnt)"
            statueIconBtn.setBackgroundImage(UIImage (named: "inprogress_badge"), for: .normal)
            break
        case 2:
            statueLable.text = "已是最新"
            statueIconBtn.setBackgroundImage(UIImage (named: "green_checkmark"), for: .normal)
            break
        default:break
        }
        
    }
    
    func setCellStatus(_ str :String) {
        
        statueLable.text = str
    }
    
    override func prepareForReuse() {
        progressview.progress = 0
        statueLable.text = " "
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
