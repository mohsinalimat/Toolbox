//
//  constant.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//

import Foundation
import UIKit

//Color
let kBartintColor =  UIColor (red: 54/255.0, green:  54/255.0, blue:  54/255.0, alpha: 1)
let kTableviewHeadViewBgColor = UIColor (red: 84/255.0, green:  150/255.0, blue:  194/255.0, alpha: 1)
let kTableviewBackgroundColor = UIColor.init(colorLiteralRed: 231/255.0, green: 231/255.0, blue: 231/255.0, alpha: 1)

let kCurrentScreenWidth = UIScreen.main.bounds.width
let kCurrentScreenHight = UIScreen.main.bounds.height


//MARK: -
let jumptoNextWithIndex:((Int) -> Void) = {index in
    let root = UIApplication.shared.keyWindow?.rootViewController as! BaseTabbarController
    root.selectedIndex = index
}
		
