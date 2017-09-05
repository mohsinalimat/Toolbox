//
//  DataSourceManager.swift
//  Toolbox
//
//  Created by gener on 17/9/1.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import Alamofire

class DataSourceManager: NSObject {

    static let `default` = DataSourceManager()
    let subPathArr = [kpackage_info,ksync_manifest,ktdafactorymobilebaseline]
    
    var totalDownloadCnt:UInt8 = 0;
    var currentDownloadCnt:UInt8 = 0;
    let kLibrary_tmp_path = LibraryPath.appending("/TDLibrary/tmp")
    let kPlistinfo_path = LibraryPath.appending("/Application data")
    let kDownload_queue_path:String
    
    override init() {
        FILESManager.default.fileExistsAt(path: kLibrary_tmp_path)
        FILESManager.default.fileExistsAt(path: kPlistinfo_path)
        kDownload_queue_path = kPlistinfo_path.appending("/downloadqueuelist.plist")
    }
    
    
    //MARK:-
    func checkupdateFromServer() {
        let semaphore = DispatchSemaphore.init(value: 1)
        for base in kDataSourceLocations {
            semaphore.wait()
            let group = DispatchGroup.init()
            var package_info = [String:Any]()

            for sub in subPathArr{
                let url = base + sub
                print("Start : \(url)")
                group.enter()
                Alamofire.request(url).responseJSON(completionHandler: { (response) in
                    //print(response.result.value!)
                    if let value = response.result.value{
                        package_info[sub] = value;
                    }
                    print("End : \(url)")
                    group.leave()
                })
                
            }
            group.notify(queue: DispatchQueue.global(), execute: { 
                print("all ok")
                self.compareJsonInfoFromLocal(base, info: package_info)
                
                semaphore.signal()
            })
        }
       
        
        print("ok!")
    }
    
    func compareJsonInfoFromLocal(_ url:String , info:[String:Any]) {
      guard info.keys.count == 3 else {return}
      if let ret = DataSourceModel.search(with: "location_url='\(url)'", orderBy: nil){
        let m = ret.first as! DataSourceModel
        guard let server_syncArr = info["sync_manifest.json"] as?[[String:String]] else {return}
        guard let syncjsonStr = m.sync_manifest else{return}
        
        if !ret.isEmpty && ret.count > 0{
            //比较同步信息
            do{
                guard let data = syncjsonStr.data(using: String.Encoding.utf8) else{return}
                guard let local_arr = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String:String]] else {return}
                
                for sdic in server_syncArr{
                    guard let doc_number = sdic["doc_number"] else{return}
                    guard let doc_version = sdic["revision_number"] else{return}
                    for ldic in local_arr {
                       guard let doc_number_l = ldic["doc_number"] else{return}
                       guard let doc_version_l = ldic["revision_number"] else{return}
                       if doc_number == doc_number_l && doc_version == doc_version_l {/////////////////
                        //添加到下载
                        let zip:String! = sdic["file_loc"]
                        let fileurl = url + "\(zip!)"
                        
                        getPlistWith(filePath: fileurl)
                        }
                    }
                }
            }catch{
                print("JSONSerialization: \(error.localizedDescription)")
            }
        }else{
            let m = DataSourceModel()
            for(key,value) in info{
                do{
                    let data =  try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let jsonStr = String.init(data: data, encoding: String.Encoding.utf8)
                    switch key {
                        case ksync_manifest: m.sync_manifest = jsonStr;break
                        case kpackage_info: m.package_info = jsonStr;break
                        case ktdafactorymobilebaseline:m.server_baseline = jsonStr;break
                        default: break
                    }
                }catch{
                    print("\(key): \(error.localizedDescription)")
                }
            }
            m.location_url = url
            m.saveToDB();
            
            //添加到下载
            for sdic in server_syncArr{
                let zip:String! = sdic["file_loc"]
                let fileurl = url + "\(zip!)"
                getPlistWith(filePath: fileurl)
            }
        }
      
        //开始下载
        startDownload()
    }
        
    }
    
    func getPlistWith(filePath:String,isAdd:Bool = true) {
        let fileurl = filePath
        let plist = kDownload_queue_path
        let old = NSKeyedUnarchiver.unarchiveObject(withFile: plist) as? [String]
        var added = [String]();
        
        if let old = old {
            added = added + old
        }
        if isAdd{
            added.append(fileurl)
        }else{
            if added.contains(filePath) {
                added.remove(at: added.index(of: filePath)!)
            }
        }

        NSKeyedArchiver.archiveRootObject(added, toFile: plist)
    }

    func startDownload() {
        let plist = kDownload_queue_path
        let downloadfiles = NSKeyedUnarchiver.unarchiveObject(withFile: plist) as? [String]

        let semaphore = DispatchSemaphore.init(value: 1)
        //下载单个文件
        func downloadFileFrom(path:URL?) {
            print("download : \(path)")
            guard let path = path else { return }
            let downloadDestination : DownloadRequest.DownloadFileDestination = {_,_ in
                let url = LibraryPath.appending("/TDLibrary/tmp").appending("/\(path.lastPathComponent)")
                let des = URL (fileURLWithPath: url)
                //let des:URL! = URL (string: url)//这个方法url文件无法写入？
                return (des,[.removePreviousFile, .createIntermediateDirectories])
            }
            
            Alamofire.download( path, to: downloadDestination)
                .downloadProgress(queue: DispatchQueue.main) {
                    (progress) in
                    print("\(progress.completedUnitCount) - \(progress.totalUnitCount)")
                }
                .response {
                    (response) in
                    print("download single file ok.")
                    let des = response.request?.url
                    self.getPlistWith(filePath: "\(des!)", isAdd: false)
                    self.currentDownloadCnt = self.currentDownloadCnt + 1
                    semaphore.signal()
            }
            
        }
        
        if let downloadfiles = downloadfiles {
            totalDownloadCnt = UInt8(downloadfiles.count)
            
            for url in downloadfiles {
                semaphore.wait()
                let u = URL (string: url)
                downloadFileFrom(path: u)
            
            }
            
           print("download finished...")

        //...解压文件
            
            
        }
        
        
        
    }
    
    
 
    
    
    
    
}
















