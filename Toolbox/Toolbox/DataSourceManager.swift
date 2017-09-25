//
//  DataSourceManager.swift
//  Toolbox
//
//  Created by gener on 17/9/1.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import Alamofire

protocol DSManagerDelegate : NSObjectProtocol {

    func ds_downloadTotalFilesCompleted(_ withurl:String)
    
    func ds_hasCheckedUpdate()
}

enum DataQueueType {
    case download //下载
    case unzip //解压
}

class DataSourceManager: NSObject {
    static let `default` = DataSourceManager()
    private let _subPathArr = [kpackage_info,ksync_manifest,ktdafactorymobilebaseline]
    
    var ds_totalDownloadCnt:Int = 0;
    var ds_currentDownloadCnt:Int = 0;
    var ds_downloadprogress:Float = 0
    var ds_serverupdatestatus:Int = 0
    var ds_serverlocationurl:String?
    var ds_isdownloading:Bool = false //正在下载
    var ds_startupdating:Bool = false //开始一次更新操作
    
    private let kLibrary_tmp_path = LibraryPath.appending("/TDLibrary/tmp")
    private let kPlistinfo_path = LibraryPath.appending("/Application data")
    private let kDownload_queue_path:String
    let kUnzip_queue_path:String
    
    weak var delegate: DSManagerDelegate?
    let _opreationqueue:OperationQueue
    private let _dispatch_queue:DispatchQueue
    
    override init() {
        FILESManager.default.fileExistsAt(path: kLibrary_tmp_path)
        FILESManager.default.fileExistsAt(path: kPlistinfo_path)
        kDownload_queue_path = kPlistinfo_path.appending("/downloadqueuelist.plist")
        kUnzip_queue_path = kPlistinfo_path.appending("/unzipqueue.plist")
        
        _opreationqueue = OperationQueue.init()
        _opreationqueue.maxConcurrentOperationCount = 1
        _opreationqueue.isSuspended = true
        _opreationqueue.qualityOfService = .utility
  
        _dispatch_queue = DispatchQueue.init(label: "com.gener-tech.download")
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
            for sub in self._subPathArr{
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
            do{//比较同步信息
                guard let data = syncjsonStr.data(using: String.Encoding.utf8) else{return}
                guard let local_arr = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String:String]] else {return}
                
                for sdic in server_syncArr{
                    guard let doc_number = sdic["doc_number"] else{return}
                    guard let doc_version = sdic["revision_number"] else{return}
                    for ldic in local_arr {
                       guard let doc_number_l = ldic["doc_number"] else{return}
                       guard let doc_version_l = ldic["revision_number"] else{return}
                       if doc_number == doc_number_l && doc_version > doc_version_l {///比较版本号
                        //添加到下载
                        let zip:String! = sdic["file_loc"]
                        let fileurl = url + "\(zip!)"
                        updateDownloadQueueWith(key:url,filePath: fileurl,datatype:.download)
                        //更新状态
                        if m.update_status != 1 {
                            m.update_status = 1
                            m.saveToDB()
                         }
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
            m.update_status = 1
            m.saveToDB();
            
            //添加到下载
            for sdic in server_syncArr{
                let zip:String! = sdic["file_loc"]
                let fileurl = url + "\(zip!)"
                updateDownloadQueueWith(key:url,filePath: fileurl,datatype:.download)
            }
        }
    }
        
    }
    

    /// 更新下载列表
    /// - parameter key:      数据源url
    /// - parameter filePath: 文件路径filepath
    /// - parameter isAdd:    添加/删除操作
    /// - parameter datatype: 数据类型
    func updateDownloadQueueWith(key:String, filePath:String,isAdd:Bool = true,datatype:DataQueueType) {
        objc_sync_enter(self)
        let fileurl = filePath
        var plist:String
        
        switch datatype {
            case .download: plist = kDownload_queue_path; break
            case .unzip:plist = kUnzip_queue_path;break
        }
        
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

    //MARK:
    func startDownload() {
        let plist = kDownload_queue_path
        let downloadfiles = NSKeyedUnarchiver.unarchiveObject(withFile: plist) as? [String:[String]]
        guard  (downloadfiles != nil) && ((downloadfiles?.count)! > 0) else {//已是最新
            self.delegate?.ds_hasCheckedUpdate();return
        }
        
        let semaphore = DispatchSemaphore.init(value: 2)
        //下载单个文件
        func _downloadFileFrom(path:URL?) {
            print("开始下载 : \(path!)")
            guard let path = path else { return }
            let downloadDestination : DownloadRequest.DownloadFileDestination = {_,_ in
                let url = LibraryPath.appending("/TDLibrary/tmp").appending("/\(path.lastPathComponent)")
                let des = URL (fileURLWithPath: url)
                //let des:URL! = URL (string: url)//这个方法url文件无法写入？
                return (des,[.removePreviousFile, .createIntermediateDirectories])
            }
            
            Alamofire.download( path, to: downloadDestination)
                .downloadProgress(queue: _dispatch_queue) {(progress) in
                    let progress = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                    if progress <= 1.0 {
                        self._update_ds_status(url: self.ds_serverlocationurl!, key: "ds_file_percent", value: progress)
                    }
                    //print(DataSourceManager.default.ds_downloadprogress)
                }
                .response(queue:_dispatch_queue) {[weak self] (response) in
                    //...判断响应状态，检测网络
                    
                    let des = response.request?.url
                    let base = des?.deletingLastPathComponent()
                    let zip = des?.lastPathComponent
                    print("完成下载 : \(des!)")
                    guard let strongSelf = self else{return}
                    strongSelf.updateDownloadQueueWith(key:"\(base!)",filePath: "\(des!)", isAdd: false,datatype:.download)
                    strongSelf.updateDownloadQueueWith(key:"\(base!)",filePath: "\(zip!)", datatype:.unzip)
                    strongSelf.ds_currentDownloadCnt = strongSelf.ds_currentDownloadCnt + 1
                    if let ret = DataSourceModel.search(with: "location_url='\(base!)'", orderBy: nil).first as? DataSourceModel{
                        ret.ds_file_percent = 0.0
                        ret.current_files = strongSelf.ds_currentDownloadCnt
                        if strongSelf.ds_totalDownloadCnt == strongSelf.ds_currentDownloadCnt{
                            print("全部下载完成!")
                            ret.update_status = 3
                            ret.current_files = 0
                            ret.total_files = 0
                            ///一个数据源下载完成
                            strongSelf.delegate?.ds_downloadTotalFilesCompleted(base!.absoluteString)
                            strongSelf.ds_isdownloading = false
                            semaphore.signal()
                        }
                        
                        if ret.saveToDB() {
                            
                        }

                    }
                    
                    semaphore.signal()
            }
            
        }
        
        DataSourceManager.default.setValue(true, forKey: "ds_startupdating")
        if let downloadfiles = downloadfiles {//多个数据源地址
            for (key,value) in downloadfiles {
                semaphore.wait()
                _update_ds_status(url: key, key: "update_status", value: 2)
                _update_ds_status(url: key, key: "total_files", value: value.count)
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
                    _downloadFileFrom(path: u)
                }
            }//d

        }

    }
    
  
    //更新数据源状态
    func _update_ds_status(url:String,key:String,value:Any) {
        if let ret = DataSourceModel.search(with: "location_url='\(url)'", orderBy: nil).first as? DataSourceModel{
            switch key {
            case "update_status":
                ret.update_status = value as! Int;break
                
            case "total_files":
                ret.total_files = value as! Int;break
                
            case "current_files":
                ret.current_files = value as! Int;break
                
            case "ds_file_percent":
                if ret.ds_file_percent >= 1.0 {
                    return;
                }
                ret.ds_file_percent = value as! Float;break
                
            default:break
            }
            
            if ret.saveToDB() {
                //print("数据表更新成功！\(key) : \(value)")
            }
        }
        
    }
    
    
    //解压队列是否为空
    func unzipQueueIsEmpty() -> Bool {
        let downloadfiles = NSKeyedUnarchiver.unarchiveObject(withFile: kUnzip_queue_path) as? [String:[String]]
        guard let filesDic = downloadfiles else{
            return true
        }
        
        return filesDic.isEmpty
    }
    
    
    
}

/***自定义的数据源状态
 1-初始，等待更新
 2-开始下载，正在下载
 3-下载完成，准备解压
 4-开始解压，解压
 5-解压完成，准备更新数据库
 6-开始更新，导入数据到数据库，资源到目标路径（统一处理更新操作）
 7-更新完成,流程结束。
 */
