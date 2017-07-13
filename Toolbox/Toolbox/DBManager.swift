//
//  DBManager.swift
//  Toolbox
//
//  Created by gener on 17/7/10.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class DBManager: NSObject {
    static let `default` :DBManager = DBManager()
    
    /// 解析json格式的数据
    ///
    /// - parameter path:               文件路径
    /// - parameter preprogressHandler: 预处理操作（可选）
    /// - parameter completionHandler:  回调处理
    static func parseJsonData(path:String,preprogressHandler:((String)->(String))? = nil, completionHandler:((Any)->())) -> Void {
        //CCAA320CCAAIPC20161101 /CCAA330CCAAIPC20170101
        ///let subpath = "/TDLibrary/CCA/CCAA320CCAAIPC20161101/aipc/resources/apList.json"
        let libpath :String =  NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        let basepath = libpath + "/TDLibrary/CCA/"
        let newpath = basepath.appending(path)
        print(newpath)
        
        let isExist = FileManager.default.fileExists(atPath: newpath)
        if isExist {
            print("file is exist")
        }
        else
        {
            print("目标路径：\(newpath) 不存在！");return
        }
         
        do{
            var jsonString = try String(contentsOfFile: newpath)
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "\r", with: "")
            if let preprogressHandler = preprogressHandler {
                jsonString = preprogressHandler(jsonString)
            }
            
            if let jsondata = jsonString.data(using: .utf8, allowLossyConversion: true) {
                // let json = JSON(data: dataFromString)
                let anyObj =  try JSONSerialization.jsonObject(with: jsondata, options: .allowFragments)
                completionHandler(anyObj)
            }
        }catch{
            print("json解析异常 ： \(error)")
        }

    }

    
    
    
    
}
