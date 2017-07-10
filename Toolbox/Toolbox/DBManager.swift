//
//  DBManager.swift
//  Toolbox
//
//  Created by gener on 17/7/10.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class DBManager: NSObject {

    func jsonDataToDB(completionHandler:()->()) -> Void {
        //CCAA320CCAAIPC20161101 /CCAA330CCAAIPC20170101
        let subpath = "/TDLibrary/CCA/CCAA320CCAAIPC20161101/aipc/resources/apList.json"
        let rootpath :String =  NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        let newpath = rootpath.appending(subpath)
        
        print(newpath)
        
        let isExist = FileManager.default.fileExists(atPath: newpath)
        if isExist {
            print("file is exist")
        }
        else
        {
            print("not exist")
        }
        
        
        do{
            let jsonString = try String (contentsOfFile: newpath).replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\r", with: "")
            
            if let jsondata = jsonString.data(using: .utf8, allowLossyConversion: true) {
                // let json = JSON(data: dataFromString)
                
                let obj =  try JSONSerialization.jsonObject(with: jsondata, options: .allowFragments) as? [String:Any]
                guard let airplaneEntryArr = obj?["airplaneEntry"] as? [Any] else {
                    return
                }
//138
                for obj in airplaneEntryArr {
                    let dic = obj as! [String:Any]
                    let model:AirplaneModel = AirplaneModel()
                    model.setModelWith(dic)
                }
            }
          
            completionHandler()
        }catch{
            print("json解析异常 ： \(error)")
        }

    }

}
