//
//  Tools.swift
//  Toolbox
//
//  Created by wyg on 2017/10/2.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import SSZipArchive

class Tools: NSObject,SSZipArchiveDelegate {

    static let `default` = Tools.init()
    let _reach:Reachability
    
    override init() {
        _reach = Reachability(hostName: "www.baidu.com")
    }
    
    //MARK: - Net Reachable
    static func startNetMonitor() {
       Tools.default._reach.startNotifier()
    }
    
    class func isReachable() -> Bool {
        return NotReachable != Tools.default._reach.currentReachabilityStatus()
    }
    
    
    
    func unzipFile(atPath:String,to:String) {
        SSZipArchive.unzipFile(atPath: atPath, toDestination: to, delegate: self)
    }
    
    
    //MARK:-
    func zipArchiveWillUnzipArchive(atPath path: String, zipInfo: unz_global_info) {
        print("zipArchiveWillUnzipArchive")
    }
    
    func zipArchiveDidUnzipArchive(atPath path: String, zipInfo: unz_global_info, unzippedPath: String) {
        print("zipArchiveDidUnzipArchive")
        
        if FileManager.default.isDeletableFile(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            }catch{
                print(error)
            }
        }else {
            print("文件删除失败")
        }
        
    }
    
    
    
}
