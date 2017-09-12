//
//  DataSourceManager.swift
//  Toolbox
//
//  Created by gener on 17/9/1.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import Alamofire

protocol DownloadCompletedDelegate : NSObjectProtocol {
    
    func downloadTotalFilesCompleted()
    
}


class DataSourceManager: NSObject {
    static let `default` = DataSourceManager()
    let subPathArr = [kpackage_info,ksync_manifest,ktdafactorymobilebaseline]
    
    var ds_totalDownloadCnt:Int = 0;
    var ds_currentDownloadCnt:Int = 0;
    var ds_downloadprogress:Float = 0
    var ds_serverupdatestatus:Int = 0
    var ds_serverlocationurl:String?
    var ds_isdownloading:Bool = false

    let kLibrary_tmp_path = LibraryPath.appending("/TDLibrary/tmp")
    let kPlistinfo_path = LibraryPath.appending("/Application data")
    let kDownload_queue_path:String
    weak var delegate: DownloadCompletedDelegate?
    private var is_thelast:Bool = false
    let _opreationqueue:OperationQueue
    
    override init() {
        FILESManager.default.fileExistsAt(path: kLibrary_tmp_path)
        FILESManager.default.fileExistsAt(path: kPlistinfo_path)
        kDownload_queue_path = kPlistinfo_path.appending("/downloadqueuelist.plist")
        
        _opreationqueue = OperationQueue.init()
        _opreationqueue.maxConcurrentOperationCount = 1
        _opreationqueue.isSuspended = true
        _opreationqueue.qualityOfService = .utility
        
    }
    
    
    
    //MARK:-
    /*
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
    }*/
    
    func checkupdateFromServer() {
        var cnt:Int = 0
        for base in kDataSourceLocations {
            
            let group = DispatchGroup.init()
            var package_info = [String:Any]()
            for sub in self.subPathArr{
                let url = base + sub
                print("Start : \(url)")
                group.enter()
                Alamofire.request(url).responseJSON(completionHandler: { (response) in
                    if let value = response.result.value{
                        package_info[sub] = value;
                    }
                    print("End : \(url)")
                    group.leave()
                })
            }
            
            group.notify(queue: DispatchQueue.global(), execute: {[weak self] in
                guard let strongSelf = self else{return}
                strongSelf.compareJsonInfoFromLocal(base, info: package_info)
                cnt = cnt + 1
                if cnt == kDataSourceLocations.count {
                    print("检测更新完成！")
                    strongSelf.startDownload()
                }
            })
            
        }
    }
    
    func compareJsonInfoFromLocal(_ url:String , info:[String:Any]) {
      guard info.keys.count == 3 else {return}
      if let ret = DataSourceModel.search(with: "location_url='\(url)'", orderBy: nil){
        guard let server_syncArr = info["sync_manifest.json"] as?[[String:String]] else {return}
        
        if !ret.isEmpty && ret.count > 0{
            let m = ret.first as! DataSourceModel
            
            guard let syncjsonStr = m.sync_manifest else{return}
            
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
                       if doc_number == doc_number_l && doc_version == doc_version_l {///....
                        //添加到下载
                        let zip:String! = sdic["file_loc"]
                        let fileurl = url + "\(zip!)"
                        
                        getPlistWith(key:url,filePath: fileurl)
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
                getPlistWith(key:url,filePath: fileurl)
            }
        }
      
        //开始下载
        //startDownload()
    }
        
    }
    
    func getPlistWith(key:String, filePath:String,isAdd:Bool = true) {
        objc_sync_enter(self)
        let fileurl = filePath
        let plist = kDownload_queue_path
        let old = NSKeyedUnarchiver.unarchiveObject(withFile: plist) as? [String : [String]]
        var added = [String:[String]]();
        
        if let old = old {
            for (key,value) in old{
                added[key] = value
            }
        }
        if isAdd{
            let arr = added[key]
            if var arr = arr{
                arr.append(fileurl)
                added[key] = arr
            }else{
                added[key] = [fileurl]
            }

        }else{
            let arr = added[key]
            if var arr = arr{
                if arr.contains(fileurl) {
                    arr.remove(at: arr.index(of: fileurl)!)
                }
                if arr.count == 0{
                    added.removeValue(forKey: key)
                }else{
                    added[key] = arr
                }
                
            }
        }

        NSKeyedArchiver.archiveRootObject(added, toFile: plist)
        objc_sync_exit(self)
    }

    func startDownload() {
        let plist = kDownload_queue_path
        let downloadfiles = NSKeyedUnarchiver.unarchiveObject(withFile: plist) as? [String:[String]]

        let semaphore = DispatchSemaphore.init(value: 2)
        //下载单个文件
        func downloadFileFrom(path:URL?) {
            print("开始下载 : \(path!)")
            guard let path = path else { return }
            let downloadDestination : DownloadRequest.DownloadFileDestination = {_,_ in
                let url = LibraryPath.appending("/TDLibrary/tmp").appending("/\(path.lastPathComponent)")
                let des = URL (fileURLWithPath: url)
                //let des:URL! = URL (string: url)//这个方法url文件无法写入？
                return (des,[.removePreviousFile, .createIntermediateDirectories])
            }
            
            Alamofire.download( path, to: downloadDestination)
                .downloadProgress(queue: DispatchQueue.main) {(progress) in
                    let progress = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                    DataSourceManager.default.setValue(progress, forKey: "ds_downloadprogress")
                    //print(DataSourceManager.default.ds_downloadprogress)
                }
                .response {[weak self] (response) in
                    let des = response.request?.url
                    let base = des?.deletingLastPathComponent()
                    
                    print("完成下载 : \(des!)")
                    guard let strongSelf = self else{return}
                    strongSelf.getPlistWith(key:"\(base!)",filePath: "\(des!)", isAdd: false)
                    strongSelf.ds_currentDownloadCnt = strongSelf.ds_currentDownloadCnt + 1
                    DataSourceManager.default.setValue(strongSelf.ds_currentDownloadCnt, forKey: "ds_currentDownloadCnt")
                    
                    if strongSelf.ds_totalDownloadCnt == strongSelf.ds_currentDownloadCnt{
                        print("全部下载完成!")
                        if let ret = DataSourceModel.search(with: "location_url='\(base!)'", orderBy: nil).first as? DataSourceModel{
                            ret.update_status = 2
                            if ret.saveToDB() {
                                DataSourceManager.default.setValue(2, forKey: "ds_serverupdatestatus")
                            }
                        }
                        
                        DataSourceManager.default.ds_isdownloading = false
                        
                        ///全部下载完成
                        strongSelf.delegate?.downloadTotalFilesCompleted()
                        
                        semaphore.signal()
                    }
                    
                    semaphore.signal()
            }
            
        }
        

        if let downloadfiles = downloadfiles {//多个数据源地址未测试
            for (key,value) in downloadfiles {
                semaphore.wait()
                
                //_opreationqueue.addOperation {
                    if let ret = DataSourceModel.search(with: "location_url='\(key)'", orderBy: nil).first as? DataSourceModel{
                        ret.update_status = 1
                        if ret.saveToDB() {
                            DataSourceManager.default.setValue(1, forKey: "ds_serverupdatestatus")
                        }
                    }
                    
                    print("begin server : \(key)")
                    
                    self.ds_serverlocationurl = key
                    DataSourceManager.default.setValue(self.ds_serverlocationurl, forKey: "ds_serverlocationurl")
                    self.ds_isdownloading = true
                    self.ds_totalDownloadCnt = value.count
                    DataSourceManager.default.setValue(self.ds_totalDownloadCnt, forKey: "ds_totalDownloadCnt")
                    self.ds_currentDownloadCnt = 0
                    DataSourceManager.default.setValue(self.ds_currentDownloadCnt, forKey: "ds_currentDownloadCnt")
                    
                    for url in value{
                        semaphore.wait()
                        let u = URL (string: url)
                        downloadFileFrom(path: u)
                        
                    }//
                //}
 
            }//d
            
            //_opreationqueue.isSuspended = false
        }

    }
    
  
    
}


