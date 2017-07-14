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
		
//MARK: - 全局变量
//对应的数据库字段
let kAirplaneInfoMap:[String:String]! = ["Tail":"tailNumber",
    "Registry":"airplaneRegistry",
    "MSN":"airplaneSerialNumber",
    "Variable":"airplaneId",
    "CEC":"customerEffectivity",
    "Line":"airplaneLineNumber",
];

//飞机所适用的手册
var kAirplanePublications:[String:Any] = [:]

//当前选中的飞机信息
var kAirplaneModel:AirplaneModel?


///PATH
let ROOTPATH = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
let ROOTSUBPATH = "/TDLibrary/CCA/" //待确定唯一性?

let aplistjsonpath = "/resources/apList.json"
let apmodelmapjspath = ROOTPATH + ROOTSUBPATH + "apModelMap.js"//与MSN字段关联飞机手册








