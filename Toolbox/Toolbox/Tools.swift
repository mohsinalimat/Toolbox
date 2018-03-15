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
    
    
    //MARK: - 获取文件路径
    func getFilePath(_ location:String?) -> String? {
        objc_sync_enter(self)
        guard let pub_url = kSelectedPublication?.book_uuid,let seg_url = location else {
            return nil
        }
        

        let s0 = kDataSourceLocations[0] //ROOTPATH
        let s1 = pub_url + "/"
        
        guard let s2 = kSelectedPublication?.doc_abbreviation!.lowercased() else { return nil}
        
        let s3 = seg_url
        
        let htmlfullpath = s0 + s1 + s2 + s3
        
        /*let htmlzippath = htmlfullpath + ".zip"
        let htmldirpath = s1 + s2 + s3.substring(to: (s3.index((s3.startIndex), offsetBy: 3))) + "/images"
        let fileExist = FileManager.default.fileExists(atPath: htmlfullpath)
        if !fileExist
        {
            print("file：\(htmlfullpath) 不存在！");
            let zipExist = FileManager.default.fileExists(atPath: htmlzippath)
            if !zipExist
            {
                print("zip路径：\(htmlzippath) 不存在！"); return nil
            }else{
                SSZipArchive.unzipFile(atPath: htmlzippath, toDestination: htmldirpath, progressHandler: {(entry, zipinfo, entrynumber, total) in }, completionHandler: {  (path, success, error) in
                    print("解压完成：\(path)")
                    FILESManager.default.deleteFileAt(path: path)
                })
            }
            
        }*/
        
        objc_sync_exit(self)
        return htmlfullpath
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
