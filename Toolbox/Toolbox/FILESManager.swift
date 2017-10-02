//
//  FILESManager.swift
//  Toolbox
//
//  Created by gener on 17/8/8.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class FILESManager: NSObject {

    static let `default` :FILESManager = FILESManager()
    let fm = FileManager.default

    
    //MARK:
    @discardableResult
    func fileExistsAt(path:String,createWhenNotExist:Bool? = true) -> Bool {
        let exist = fm.fileExists(atPath: path)
        if !exist && createWhenNotExist!
        {
            print("目录:\(path) 不存在！");
            do{
                try fm.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                print("FILESManager创建目录:\(path)")
            }catch{
                print(error)
            }
        }
        
        return exist
    }

    func deleteFileAt(path:String) {
        if FileManager.default.isDeletableFile(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            }catch{
                print(error)
            }
        }else {
            print("文件删除失败:\(path)")
        }
    }
    
    class func moveFileAt(path:String,to:String) {
        do{
            try FileManager.default.moveItem(atPath: path, toPath: to)
        }catch{
            print("move file occur error : \(error.localizedDescription)")
        }
    }
    
    
    
    
}
