//
//  UpdateButton.swift
//  Toolbox
//
//  Created by gener on 17/9/21.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class UpdateButton: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let btn = UIButton()
        btn.frame = frame
        btn.setImage(UIImage (named: "inprogress_update_button"), for: .normal)//23.23
        btn.setImage(UIImage (named: "inprogress_update_button"), for: .highlighted)
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, -5, 0)
        
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        btn.tag = 100
        
        self.addSubview(btn)

        backgroundColor = UIColor.red
        
        //...添加进度条
        
    }
    
    func btnClick() {
        
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    
    
    
    

}
