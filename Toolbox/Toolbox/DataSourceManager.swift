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
    let infodatapath = LibraryPath.appending("/Application data")
    
    func checkupdateFromServer() {
        FILESManager.default.fileExistsAt(path: infodatapath)
        for base in kDataSourceLocations {
            let semaphore = DispatchSemaphore.init(value: 1)
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
        
    }
    
    func compareJsonInfoFromLocal(_ url:String , info:[String:Any]) {
        
      if let ret = DataSourceModel.search(with: "location_url='\(url)'", orderBy: nil){
        if !ret.isEmpty && ret.count > 0{
            //比较同步信息
            let m = ret.first as! DataSourceModel
            guard let server_syncArr = info["sync_manifest.json"] as?[[String:String]] else {return}
            guard let syncjsonStr = m.sync_manifest else{return}
            
            do{
                guard let data = syncjsonStr.data(using: String.Encoding.utf8) else{return}
                guard let local_arr = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String:String]] else {return}
                
                for sdic in server_syncArr{
                    guard let doc_number = sdic["doc_number"] else{return}
                    guard let doc_version = sdic["revision_number"] else{return}
                    for ldic in local_arr {
                       guard let doc_number_l = ldic["doc_number"] else{return}
                       guard let doc_version_l = ldic["revision_number"] else{return}
                       if doc_number == doc_number_l && doc_version == doc_version_l{
                        //下载新版本
                        let zip:String! = sdic["file_loc"]
                        NSKeyedArchiver.archiveRootObject(zip, toFile: infodatapath.appending("/downloadqueuelist.plist"))
                        
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
            
        }
        
    }

    }
    
}
