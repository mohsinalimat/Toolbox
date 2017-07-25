//
//  constant.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//

import Foundation
import UIKit

let kColor:((Int,Int,Int) -> UIColor) = {
    r,g,b in
    return UIColor (red: 54/255.0, green:  54/255.0, blue:  54/255.0, alpha: 1)
}

//Color
let kBartintColor =  UIColor (red: 54/255.0, green:  54/255.0, blue:  54/255.0, alpha: 1)
let kTableviewHeadViewBgColor = UIColor(red: 84/255.0, green:  150/255.0, blue:  194/255.0, alpha: 1)
let kTableviewBackgroundColor = UIColor.init(colorLiteralRed: 231/255.0, green: 231/255.0, blue: 231/255.0, alpha: 1)
let kDOCTYPEColor:[String:UIColor] = ["AIPC":UIColor(red: 255/255.0, green:  227/255.0, blue:  30/255.0, alpha: 1),
                                      "AMM":UIColor(red: 169/255.0, green:  67/255.0, blue:  85/255.0, alpha: 1),
                                      "TSM":UIColor(red: 146/255.0, green:  154/255.0, blue:  158/255.0, alpha: 1),]

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

//全部手册
var kAllPublications:[String:Any] = [:]

//当前选中的飞机
var kSelectedAirplane:AirplaneModel?
//当前选中的手册
var kSelectedPublication:PublicationsModel?
//当前选中的目录节点
var kSelectedSegment:SegmentModel?



///PATH
//"/var/mobile/Containers/Data/Application/E2F03F14-9FA2-415A-87F6-E46B68A03E2A/Library/TDLibrary/CCA/CCAA320CCAAIPC20161101/aipc"
let ROOTPATH = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0].appending("/TDLibrary")
let ROOTSUBPATH = "/CCA/" //待确定唯一性?

//sub
let APLISTJSONPATH = "/resources/apList.json"
let APMODELMAPJSPATH = ROOTPATH + ROOTSUBPATH + "apModelMap.js"//与MSN字段关联飞机手册








