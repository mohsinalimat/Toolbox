//
//  DownloadDetailtop.swift
//  Toolbox
//
//  Created by wyg on 2017/10/7.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class DownloadDetailtop: UIView {
    @IBOutlet weak var urlLab: UILabel!

    @IBOutlet weak var statusLab: UILabel!
    
    @IBOutlet weak var progressLab: UIProgressView!
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
 
    override func awakeFromNib() {
        backgroundColor = UIColor.red
        
    }
    
}
