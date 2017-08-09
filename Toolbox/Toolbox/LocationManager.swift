//
//  LocationManager.swift
//  Toolbox
//
//  Created by gener on 17/8/8.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class LocationManager: NSObject {

    static let `default` :LocationManager = LocationManager()
    let fm = FileManager.default
    
    override init() {
        
    }
    
    
    @discardableResult
    func checkPathIsExist(path:String,createWhenNotExist:Bool? = true) -> Bool {
        let exist = fm.fileExists(atPath: path)
        if !exist && createWhenNotExist!
        {
            print("目录:\(path) 不存在！");
            do{
                try fm.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                print("LocationManager创建目录:\(path)")
            }catch{
                print(error)
            }
        }
        
        return exist
    }

    
    
    
    
}
