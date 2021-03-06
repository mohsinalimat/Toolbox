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

    func ds_startUnzipFile(_ withurl:String)
    
    func ds_checkoutFromDocument()
    
    func ds_hasCheckedUpdate(_ shouldHud:Bool)
    
    
}

enum DataQueueType {
    case download //下载
    case unzip //解压
}

let kNotificationName_willInstall_downloadCompletion = "kNotificationName_willInstall_downloadCompletion"

class DataSourceManager: NSObject {
    static let `default` = DataSourceManager()
    private let _subPathArr = [ksync_manifest] //[kpackage_info,ksync_manifest,ktdafactorymobilebaseline]
    
    var ds_totalDownloadCnt:Int = 0;
    var ds_currentDownloadCnt:Int = 0;
    var ds_downloadprogress:Float = 0
    var ds_serverupdatestatus:Int = 0
    var ds_serverlocationurl:String?
    var ds_isdownloading:Bool = false //正在下载
    var ds_startupdating:Bool = false /*{ //开始一次更新操作
        didSet{
            guard let vc = (UIApplication.shared.keyWindow?.rootViewController as! BaseTabbarController).viewControllers?.last else{
                return;
            }
            DispatchQueue.main.async {
                if DataSourceManager.default.ds_startupdating {
                    if ktabbarVCIndex != 6{
                        RootControllerChangeWithIndex(6)
                    }
                    vc.tabBarItem.badgeValue = ""
                }else{
                    vc.tabBarItem.badgeValue = nil
                }
            }
        }
    }*/
    
    var ds_checkupdatemanual:Bool = false //手动点击更新
    private let ds_from_itunes = "itunes import"
    
    private let kLibrary_tmp_path = LibraryPath.appending("/TDLibrary/tmp")
    private let ds_plist_basepath = LibraryPath.appending("/Application data")
    let ds_download_queue_path:String
    let kUnzip_queue_path:String
    let ds_unzip_queue_itunes:String
    
    let delegate: DS_Delegate?
    let _opreationqueue:OperationQueue
    private let _dispatch_queue:DispatchQueue
    
    //MARK:-
    override init() {
        FILESManager.default.fileExistsAt(path: kLibrary_tmp_path)
        FILESManager.default.fileExistsAt(path: ds_plist_basepath)
        ds_download_queue_path = ds_plist_basepath.appending("/downloadqueuelist.plist")
        kUnzip_queue_path = ds_plist_basepath.appending("/unzipqueue.plist")
        ds_unzip_queue_itunes = ds_plist_basepath.appending("/unzipqueueforitunes.plist")
        
        delegate = DS_Delegate()
        _opreationqueue = OperationQueue.init()
        _opreationqueue.maxConcurrentOperationCount = 1
        _opreationqueue.isSuspended = true
        _opreationqueue.qualityOfService = .utility
  
        _dispatch_queue = DispatchQueue.init(label: "com.gener-tech.download")
    }
    
    func ds_checkupdate() {
        let hasUpdate = UserDefaults.standard.value(forKey: kHasDataUpdateAsValidDate) as? Bool
        if let b = hasUpdate{
            if b {
                return;
            }
            
        }
        
        guard !ds_startupdating  else {return}
        DispatchQueue.global().async {
            self._checkupdateFromServer()
            
            //self._checkUpdateFromDocument()
 
        }
    }
    
    
    func _checkupdateFromServer() {
        guard Tools.isReachable() else {
            print("cannot connect network...")
            HUD.show(info: "无法连接网络！")
            return
        }
        guard !ds_isdownloading else {return}
        
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
                    if response.result.isFailure{
                        print("Request Error:\(String(describing: response.result.error?.localizedDescription))")
                        DispatchQueue.main.async {
                            HUD.show(info: "请求服务器超时!")
                        }
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
    
    func _checkUpdateFromDocument() {
        UNZIPFile.default.unzipFileFromDocument{[weak self] isExist in
            print("Document unzip ok,next unzip queue...")
            guard let strongSelf = self else{return}
            guard !strongSelf.unzipQueueIsEmpty().0 else {
                strongSelf.delegate?.ds_hasCheckedUpdate(false);return
            }
            
            guard isExist else {return}
            let m = DataSourceModel()
            m.location_url = strongSelf.ds_from_itunes
            m.update_status = DSStatus.downloading.rawValue
            m.saveToDB()
            strongSelf.delegate?.ds_checkoutFromDocument()
        }
    }
    
    
    func compareJsonInfoFromLocal(_ url:String , info:[String:Any]) {///////// "publication_id": "AMUA320AMUTSM_","revision_number": "52",
        guard info.keys.count == _subPathArr.count else {return}
        guard let server_syncArr = info["sync_manifest.json"] as? [[String:String]] else {return}
        if let m = DataSourceModel.searchSingle(withWhere: "location_url='\(url)'", orderBy: nil) as? DataSourceModel
        {
            for dic in server_syncArr{
                let file = dic["file_loc"]!;
                guard let pid = dic["publication_id"] else{return}
                let old = PublicationVersionModel.searchSingle(withWhere: "publication_id='\(pid)'", orderBy: nil) as? PublicationVersionModel
                //比较ID，版本号。判断是否已存在
                if let old = old{
                    //如果已存在,比较版本号
                    guard let v_new = dic["revision_number"] else{return}
                    guard let v_old = old.revision_number else{return}
                    if UInt16.init(v_new)! > UInt16.init(v_old)! {
                        var dic = dic
                        dic["data_source"] = url
                        //删除原记录，保存新的记录
                        
                        let oldbookid = old.book_uuid
                        saveWillDeleteBookId(oldbookid!)
                        
                        
                        PublicationVersionModel.delete(with: "publication_id='\(pid)'")
                        PublicationVersionModel.saveToDb(with: dic)
                        
                        //添加到下载
                        let fileurl = url + "\(file)"
                        updatedsQueueWith(key:url,filePath: fileurl,datatype:.download)
                        m.update_status = DSStatus.wait_update.rawValue
                    }
                }else{
                    var dic = dic
                    dic["data_source"] = url
                    PublicationVersionModel.saveToDb(with: dic)
                    let fileurl = url + "\(file)"
                    updatedsQueueWith(key:url,filePath: fileurl,datatype:.download)
                    m.update_status = DSStatus.wait_update.rawValue//更新状态
                }
            }
            
            m.time = "\(Date.timeIntervalSinceReferenceDate)"
            m.updateToDB()
        }else{//不存在，(不同的数据源会不会有相同的数据？？？,有待验证)
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
            m.update_status = DSStatus.wait_update.rawValue
            m.time = "\(Date.timeIntervalSinceReferenceDate)"
            m.saveToDB();
            
            //添加到下载
            for dic in server_syncArr{
                let zip:String! = dic["file_loc"]
                let fileurl = url + "\(zip!)"
                updatedsQueueWith(key:url,filePath: fileurl,datatype:.download)
                PublicationVersionModel.saveToDb(with: dic)
            }
        }
    }

    

    /// 更新下载列表
    /// - parameter key:      数据源url
    /// - parameter filePath: 文件路径filepath
    /// - parameter isAdd:    添加/删除操作
    /// - parameter datatype: 数据类型
    func updatedsQueueWith(key:String, filePath:String,isAdd:Bool = true,datatype:DataQueueType) {
        objc_sync_enter(self)
        let fileurl = filePath
        var path:String
        
        switch datatype {
            case .download: path = ds_download_queue_path; break
            case .unzip:
                path = kUnzip_queue_path;
                if /*key.hasPrefix("http")*/ true {
                    
                }else{
                    //path = ds_unzip_queue_itunes
                }
            break
        }
        
        let old = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [String : [String]]
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

        NSKeyedArchiver.archiveRootObject(added, toFile: path)
        objc_sync_exit(self)
    }

    ///待更新检测,如果有需要更新，加入解压队列等待更新
    func ds_checkIfHasUpdate() -> Bool {
        guard !ds_startupdating else {return false}
        
        let hasUpdate = UserDefaults.standard.value(forKey: kHasDataUpdateAsValidDate) as? Bool
        if let b = hasUpdate{
            if b {
                return true;
            }
            
        }

        let wil = InstallLaterModel.search(with: nil, orderBy: nil)
        guard let w = wil as? [InstallLaterModel] , w.count > 0 else {return false;}
        
        /////添加到解压队列
        let now = self.dateToString(Date())
        for m in w {
            var date_time:String!;
            
            //生效日期
            if let mark_data = m.mark_valid_data {
                date_time = mark_data;
            }else {
                date_time = m.revision_date;
            }
            
            if date_time <= now {
                if let ds = m.data_source {
                    self.updatedsQueueWith(key:ds,filePath: "\(m.file_loc!)", datatype:.unzip)
                    m.deleteToDB()
                    
                    UserDefaults.standard.set(true, forKey: kHasDataUpdateAsValidDate)
                    UserDefaults.standard.synchronize()
                }
            }
        }
        
        guard !unzipQueueIsEmpty().0 else {return false}
       return true
    }
    
    /// 更新有效期内的数据
    func _ds_update_loc() {
        let plist = kUnzip_queue_path
        let files = NSKeyedUnarchiver.unarchiveObject(withFile: plist) as? [String:[String]]
        guard let urls = files?.keys  else{ return}

        UserDefaults.standard.removeObject(forKey: kHasDataUpdateAsValidDate)
        for _u in urls {
            _update_ds_status(url: _u, key: "update_status", value: DSStatus.unzipping.rawValue)

            self.delegate?.ds_startUnzipFile(_u);
        }
        
    }
    
    
    //MARK:
    func startDownload() {
        let plist = ds_download_queue_path
        let downloadfiles = NSKeyedUnarchiver.unarchiveObject(withFile: plist) as? [String:[String]]
        guard  (downloadfiles != nil) && ((downloadfiles?.count)! > 0) else {//下载队列为空
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
                    //下载完成，删除下载队列中该条记录
                    strongSelf.updatedsQueueWith(key:"\(base!)",filePath: "\(des!)", isAdd: false,datatype:.download)
                    
                    //判断是否是提前下载的(不需要立即更新的)，否则加入解压队列等待更新
                    if let vm = PublicationVersionModel.searchSingle(withWhere: "file_loc='\(zip!)'", orderBy: nil) as? PublicationVersionModel {
                        let now = strongSelf.dateToString(Date())
                        
                        if vm.revision_date < now {
                            strongSelf.updatedsQueueWith(key:"\(base!)",filePath: "\(zip!)", datatype:.unzip)
                        }else {
                            if let _old = InstallLaterModel.searchSingle(withWhere: "publication_id='\(vm.publication_id!)'", orderBy: nil) as? InstallLaterModel {
                                _old.deleteToDB();
                            }
                            
                            let laterM = InstallLaterModel()
                            laterM.revision_date = vm.revision_date
                            laterM.revision_number = vm.revision_number
                            laterM.file_loc = vm.file_loc
                            laterM.publication_id = vm.publication_id
                            laterM.book_uuid = vm.book_uuid
                            laterM.doc_number = vm.doc_number
                            laterM.document_owner = vm.document_owner
                            laterM.model_major = vm.model_major
                            laterM.doc_abbreviation = vm.doc_abbreviation
                            laterM.display_model = vm.display_model
                            laterM.display_title = vm.display_title
                            laterM.data_source = "\(base!)"
                            laterM.saveToDB()
                        }
                        
                        ///刷新数据通知
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name.init(kNotificationName_willInstall_downloadCompletion), object: nil)
                        }
                    }
                    
                    strongSelf.ds_currentDownloadCnt = strongSelf.ds_currentDownloadCnt + 1
                    if let ret = DataSourceModel.search(with: "location_url='\(base!)'", orderBy: nil).first as? DataSourceModel{
                        ret.ds_file_percent = 0.0
                        ret.current_files = strongSelf.ds_currentDownloadCnt
                        if strongSelf.ds_totalDownloadCnt == strongSelf.ds_currentDownloadCnt{
                            print("全部下载完成!")
                            ret.update_status = DSStatus.will_unzip.rawValue
                            ret.current_files = 0
                            ret.total_files = 0
                            ret.saveToDB()
                            
                            ///一个数据源下载完成
                            if !strongSelf.unzipQueueIsEmpty().0 {
                                strongSelf.delegate?.ds_startUnzipFile(base!.absoluteString)
                            }
                            
                            strongSelf.ds_isdownloading = false
                            semaphore.signal()
                        }else{
                            if ret.saveToDB() {
                                
                            }
                        }
                    }
                    
                    semaphore.signal()
            }
            
        }
        
        DataSourceManager.default.setValue(true, forKey: "ds_startupdating")
        if let downloadfiles = downloadfiles {//多个数据源地址
            UIApplication.shared.isIdleTimerDisabled = true
            
//            DispatchQueue.main.async {
//                HUD.show(withStatus: "正在连接飞机网络...")
//            }
            
            for (key,value) in downloadfiles {
                semaphore.wait()
                _update_ds_status(url: key, key: "update_status", value: DSStatus.downloading.rawValue)
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
    
    //MARK:
    //解压队列是否为空
    func unzipQueueIsEmpty() -> (Bool,[String:[String]]) {
        return dataQueueIsEmpty(kUnzip_queue_path)
    }

    func dataQueueIsEmpty(_ atPath:String) -> (Bool,[String:[String]]) {
        let files = NSKeyedUnarchiver.unarchiveObject(withFile: atPath) as? [String:[String]]
        guard let filesDic = files else{
            return (true,[:])
        }
        return (filesDic.isEmpty,filesDic)
    }
   
    
    func dateToString(_ date:Date, formatter:String = "yyyyMMdd") -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = formatter
        
        return dateFormatter.string(from: date)
    }

    
    //MARK: - delete book
    ///删除已安装的手册
    class func deleteBooksWithId(_ uids:[String]) {
        self.default.delegate?.ds_deleteBooksWithId(uids);
    }
    
    ///删除已下载未完成安装的手册
    class func deleteBooksWillInstall(_ uids:[String]) {
        self.default.delegate?.ds_deleteBooksWillInstall(uids);
    }
    
    
    
    
    
    ////////bookid
    func saveWillDeleteBookId(_ s: String)  {
        if var arr = UserDefaults.standard.value(forKey: "willdelete_bookid") as? [String] {
            if !arr.contains(s){
                arr.append(s);
                
                UserDefaults.standard.setValue(arr, forKey: "willdelete_bookid")
                UserDefaults.standard.synchronize()
            }
        }else{
            UserDefaults.standard.setValue([s], forKey: "willdelete_bookid")
            UserDefaults.standard.synchronize()
        }

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
