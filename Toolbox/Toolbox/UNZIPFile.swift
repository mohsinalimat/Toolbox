//
//  UNZIPFile.swift
//  Toolbox
//
//  Created by gener on 17/7/10.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import KissXML
import SSZipArchive

class UNZIPFile: NSObject {
    static let `default` :UNZIPFile = UNZIPFile()
    let fm = FileManager.default
    var unzipFilesnumber = 0
    let queue:OperationQueue
    
    var zip_total_filescnt:Int = 0
    var zip_current_filescnt:Int = 0
    var zip_unzip_progress:Float = 0
    
    var update_total_filescnt = 0
    var update_current_filescnt = 0
    
    ////
    var _unzip_ds_url:String?

    //MARK:-
    override init() {
        self.queue = {
            let operationQueue = OperationQueue()
            operationQueue.maxConcurrentOperationCount = 1
            operationQueue.isSuspended = true
            operationQueue.qualityOfService = .utility
            operationQueue.addOperation({ 
               print("queue init")
            })
            
            return operationQueue
        }() 
    }
    
    func unzipOperationQueue() -> OperationQueue {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.isSuspended = true
        operationQueue.qualityOfService = .utility
        operationQueue.addOperation({
            print("queue init")
        })
        
        return operationQueue
    }
    
    
    /// 解析json格式的数据
    ///
    /// - parameter path:               文件路径
    /// - parameter preprogressHandler: 预处理操作（可选）
    /// - parameter completionHandler:  回调处理
    static func parseJsonData(
        path:String,
        preprogressHandler:((String)->(String))? = nil,
        completionHandler:((Any)->()))
    {
        print(path)
        let isExist = FileManager.default.fileExists(atPath: path)
        if !isExist
        {
            print("目标路径：\(path) 不存在！");return
        }
         
        do{
            var jsonString = try String(contentsOfFile: path)
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "\r", with: "")
            if let preprogressHandler = preprogressHandler {
                jsonString = preprogressHandler(jsonString)
            }
            
            if let jsondata = jsonString.data(using: .utf8, allowLossyConversion: true) {
                // let json = JSON(data: dataFromString)
                let anyObj =  try JSONSerialization.jsonObject(with: jsondata, options: .allowFragments)
                completionHandler(anyObj)
            }
        }catch{
            print("json解析异常 ： \(error)")
        }

    }

    //MARK:
    //飞机信息
    func getAirplanesData(withPath path:String,bookName:String){
        print("\(bookName) : 获取飞机信息")
        UNZIPFile.parseJsonData(path: path.appending(APLISTJSONPATH), completionHandler: { (obj) in
            let obj =  obj as? [String:Any]
            guard let airplaneEntryArr = obj?["airplaneEntry"] as? [Any] else { return}
            AirplaneModel.saveToDb(with: airplaneEntryArr)
            
            for item in airplaneEntryArr {
                let item = item as? [String:Any]
                if let msn = item?["airplaneSerialNumber"]{
                    let dic = ["bookid":bookName,"msn":msn,"primary_id":bookName + "\(msn)"]
                    APMMap.saveToDb(with: dic)
                }
            }
        })
    }

    
    //获取手册信息
    func getBookData(withPath path:String) {
        print("\(path) : 获取手册")
            var path = path
            let booklocalurl = path.substring(from: ROOTPATH.endIndex)
            let metadataurl = booklocalurl.appending("/resources/toc.xml")
            
            var des:[String:String] = [:]
            des["booklocalurl"] = booklocalurl
            des["metadataurl"] = metadataurl
            
            path = path.appending("/resources/book.xml")
            do{
                let jsonString = try String(contentsOfFile: path)
                if let jsondata = jsonString.data(using: .utf8, allowLossyConversion: true){
                    let doc = try DDXMLDocument.init(data: jsondata, options: 0)
                    //let bookElement:DDXMLNode = try doc.nodes(forXPath: "//books/book")[0]
                    
                    let rootE:DDXMLElement! = doc.rootElement()
                    let book:DDXMLElement! = rootE.elements(forName: "book")[0]
                    let attrNodes =  book.attributes
                    guard let attributeArr = attrNodes else {
                        return
                    }
                    
                    for node in attributeArr {
                        if let key = node.name,let value = node.stringValue{
                            des[key] = value
                        }
                    }
                    PublicationsModel.saveToDb(with: des)
                }
            }catch{
                print(error)
            }
    }

    func getSegmentsData(withBookPath path:String ,bookName:String) {
        autoreleasepool { () -> () in
            print("\(bookName) : 获取getSegmentsData")
            
            var path = path
            path = path.appending("/resources/toc.xml")
            let book_id = bookName//book_id = bookname
            
            do{
                let jsonString = try String(contentsOfFile: path)
                if let jsondata = jsonString.data(using: .utf8, allowLossyConversion: true){
                    let doc = try DDXMLDocument.init(data: jsondata, options: 0)
                    let rootE:DDXMLElement! = doc.rootElement()
                    let segs:[DDXMLElement] = rootE.elements(forName: "segment")
                    let parent_id = book_id
                    
                    //建立索引
                    let group = DispatchGroup()
                    for element in segs {
                        let item  = DispatchWorkItem.init(block: { [weak self] in
                            guard let strongSelf = self else{return}
                            strongSelf.traversalNode(element: element, parentId: parent_id, bookId: book_id,lv:1)
                        })

                       DispatchQueue.global().async(group: group, execute: item)
                    }
                    group.wait()
                }
            }catch{
                print(error)
            }
        }
    }

    
    /// 遍历节点
    ///
    /// - parameter element:  当前节点元素
    /// - parameter parentId: 上一级节点ID
    /// - parameter bookId:   当前手册ID
    /// - parameter lv:       节点层级
    private func traversalNode(element:DDXMLElement,
                               parentId:String,
                               bookId:String,
                               lv:Int) {
        autoreleasepool { () -> () in
        
            let parentId = parentId
            let attrs = element.attributes
            var des:[String:String]! = [:]
            let lv = lv;
            
            guard let attributeArr = attrs else {
                return
            }
            for node in attributeArr {
                if let key = node.name,let value = node.stringValue{
                    des[key] = value
                }
            }
            
            let titleElement = element.elements(forName: "title")
            if titleElement.count > 0 {
                des["title"] = titleElement[0].stringValue
            }
            
            
            //....
            
            let _id = des["id"]
            if _id == nil {
                print("ID 数据有问题。。。")
            }
            let primaryid = bookId + _id!
            des["toc_id"] = _id
            des["primary_id"] = primaryid
            des["parent_id"] = parentId
            des["book_id"] = bookId
            des["nodeLevel"] = "\(lv)"
        
            //有效性判断
            let effect = element.elements(forName: "effect")
            if  effect.count > 0 {
                let effect = effect[0]
                let effAttrs = effect.attributes
                guard let attributeArr = effAttrs else {
                    return
                }
                for node in attributeArr {
                    if let key = node.name,let value = node.stringValue{
                        des[key] = value
                    }
                }
            }
            
            //是否还有子节点
            /*
             <segment has_content="0" id="EN21210003011450001" is_leaf="1" is_visible="0" original_tag="graphic" revision_type="OEM" toc_code="21-21-00-11450">
             <effect effrg="001999" tocdisplayeff="** ON A/C ALL" />
             <title>21-21-00-11450</title>
             <segment content_location="../21/images/f_ts_212100_3_aam0_01_00.svg" has_content="1" is_leaf="1" is_visible="0" mime_type="image/svg" original_tag="sheet" revision_type="OEM" toc_code="21-21-00-11450-1">
             <effect effrg="001999" tocdisplayeff="** ON A/C ALL" />
             </segment>
             </segment>
                是叶节点，又有子节点，图片，不可见
             */
            let isleaf = Int(des["is_leaf"]!)!
            let isvisible = Int(des["is_visible"]!)!
            if isleaf == 1 && isvisible == 1 {
                let localtion :String! = des["content_location"]
                let new = localtion.substring(from: (localtion.index(localtion.startIndex, offsetBy: 2)))
                des["content_location"] = new
            }
            SegmentModel.saveToDb(with: des)
        
            if isleaf == 0  /*|| (isleaf == 1 && isvisible == 0)*/ {//有问题
                let eles = element.elements(forName: "segment")
                for ele in eles {
                    traversalNode(element: ele, parentId: primaryid, bookId: bookId,lv:lv + 1)
                }
            }
            
        }
    }

    
    
    //MARK:-
    /*
    //表更新记录
    private func updateTableinfo(cls:Model.Type,id:String? = nil)  {
        var infodic = [String:Any]()
        infodic["table_name"] = cls.getTableName()
        infodic["update_time"] = Date().timeIntervalSince1970
        if let id = id {
            infodic["ID"] = id
        }
        
        UpdateInfo.saveToDb(with: infodic)
    }
*/
    

    
    
    //Document 是否有更新
   static func hasBookNeedUpdate() ->Bool{
        let zipArr = UNZIPFile.default.getFilesAt(path: DocumentPath)
        return zipArr.count > 0
    }
    
}


//1502086746.428690
//MARK: 文件解压及数据处理
extension UNZIPFile  {
    
    //获取手册路径
    func getBookPath(withRelPath path:String) -> String {
        var bookpath:String = path
        let files = getFilesAt(path: bookpath)
        if files.count > 0 {
            bookpath.append("/\(files[0])")
        }
        
        return bookpath
    }
    
    //获取指定路径下文件名
    func getFilesAt(path:String) -> [String] {
        var files = [String]()
        do {
            files = try fm.contentsOfDirectory(atPath: path)
        } catch  {
            print("\(#function)" + error.localizedDescription)
        }
        
        return files
    }
    
    //获取指定路径下zip文件名
    func getZipFiles(items:[String]) -> [String] {
        var zips = [String]()
        
        for item in items {
            if item.hasSuffix(".zip") {
                zips.append(item)
            }
        }
        
        return zips
    }
    
    //MARK:- 解压操作
    //--1
    func unzipFileFromDocument(_ completionHandler:((Void) -> Void)? = nil) {
        autoreleasepool { () -> () in
            let tmppath = LibraryPath.appending("/TDLibrary/tmp")
            let baseinfodatapath = LibraryPath.appending("/Application data")
            let installpath = LibraryPath.appending("/installingbook")
            
            //路径检测
            FILESManager.default.fileExistsAt(path: tmppath)
            FILESManager.default.fileExistsAt(path: baseinfodatapath)
            do{
                let fileArr = try fm.contentsOfDirectory(atPath: DocumentPath)
                let zipArr = getZipFiles(items: fileArr)
                guard zipArr.count > 0 else{return}
                FILESManager.default.fileExistsAt(path: installpath)
                
                for p in zipArr {
                    if p.hasSuffix(".zip") {
                        let srczip = DocumentPath + "/\(p)"
                        print("开始解压：\(srczip)")
                        SSZipArchive.unzipFile(atPath: srczip, toDestination: installpath, progressHandler: { (entry, zipinfo, entrynumber, total) in
                            print("Doc:\(entrynumber) - \(total)")
                            /*if !entry.hasSuffix(".zip") {
                                do{
                                    try self.fm.moveItem(atPath: despath + "/\(entry)", toPath: baseinfodatapath +  "/\(entry)")
                                }catch{
                                    print(error)
                                }
                            }*/
                            }, completionHandler: { (path, success, error) in
                                print("DOCMENT解压完成：\(path)")
                                //////////删除源文件
                                FILESManager.default.deleteFileAt(path: path)
                                
                                ////添加到解压队列
                                do{
                                    let p = installpath.appending("/sync_manifest.json")
                                    let jsonStr = try String (contentsOfFile: p)
                                    guard let data = jsonStr.data(using: String.Encoding.utf8) else {return}
                                    
                                    do {
                                        guard let arr = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String:String]] else{return}
                                        
                                        for dic in arr{
                                            let file = dic["file_loc"]!;
                                            
                                            //...比较ID，版本号。判断是否已存在
                                            if true{
                                                //如果已存在，删除压缩文件
                                            }else{
                                                //不存在，添加到解压队列等待更新
                                            }
                                            
                                            //move zip
                                            let zip = installpath.appending("/\(file)")
                                            FILESManager.moveFileAt(path: zip, to: tmppath +  "/\(file)")
                                            DataSourceManager.default.updatedsQueueWith(key: "itunes import", filePath: file, datatype: .unzip)
                                        }
                                        
                                        //move json
                                        let files = self.getFilesAt(path: installpath)
                                        for f in  files {
                                            if f.hasSuffix(".json"){
                                               FILESManager.moveFileAt(path: installpath.appending("/\(f)"), to: baseinfodatapath +  "/\(f)")
                                            }
                                        }
                                        
                                        print("add ok")
                                        FILESManager.default.deleteFileAt(path: installpath)
                                        if let handler = completionHandler{
                                            handler()
                                        }
                                    }
                                }catch{
                                    print(error)
                                }
                                
                        })
                    }
                }
                
                if zipArr.count == 0{
                    print("Document not zip.")
                    if let handler = completionHandler{
                        handler()
                    }
                }
            }catch{
                print(error)
            }
            
        }
    }
    
    
    //解压缓存目录到指定目录，然后解压资源文件
    func unzipFileFromTmp(url:String? = nil)  {
        let path = ROOTPATH.appending("/tmp")
        let fileArr = getFilesAt(path: path)
        let zipArr = getZipFiles(items: fileArr)
        
        guard zipArr.count > 0 else{return}
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name (rawValue: "kNotification_unzipfile_totalnumber"), object: nil, userInfo: ["filesnumber":zipArr.count])
            
            UNZIPFile.default.setValue(zipArr.count, forKey: "zip_total_filescnt")
        }
        
        //单个数据源情况
        if let url = url{
            DataSourceManager.default._update_ds_status(url: url, key: "update_status", value: 4)
            DataSourceManager.default._update_ds_status(url: url, key: "total_files", value: zipArr.count)
        }
        
        for item in zipArr {
            if item.hasSuffix(".zip") {//解压tmp目录
                let srcpath = path.appending("/\(item)")
                let newpath = ROOTPATH + "/\(Date().timeIntervalSince1970)"
                FILESManager.default.fileExistsAt(path: newpath)
                
                SSZipArchive.unzipFile(atPath: srcpath, toDestination:newpath , progressHandler:{(entry, zipinfo, entrynumber, total)in
                    //print("Tmp:\(entrynumber) - \(total)")
//                    DispatchQueue.main.async {
                        let progress =  Float(entrynumber) / Float(total)
                        //kUnzipprogress.progress = kUnzipProgressStatus
                        UNZIPFile.default.setValue(progress, forKey: "zip_unzip_progress")
                        
                        if progress <= 1.0 {
                            if let url = url{
                                DataSourceManager.default._update_ds_status(url: url, key: "ds_file_percent", value: progress)
                            }
                        }
//                    }
                    },completionHandler:{/*[weak self]*/(path, success, error) in
                       /* DispatchQueue.main.async {
                            NotificationCenter.default.post(Notification.init(name: NSNotification.Name (rawValue: "kNotification_unzipsinglefile_complete")))
                            
                            //已解压完的zip
                            self.zip_current_filescnt = self.zip_current_filescnt + 1
                            UNZIPFile.default.setValue(self.zip_current_filescnt, forKey: "zip_current_filescnt")
                            print("++++++++++已解压完成的文件数 : \(self.zip_current_filescnt)")
                            
                        }*/
                        
                        self.zip_current_filescnt = self.zip_current_filescnt + 1

                        if let url = url, let ret = DataSourceModel.search(with: "location_url='\(url)'", orderBy: nil).first as? DataSourceModel{
                            ret.ds_file_percent = 0.0
                            ret.current_files = self.zip_current_filescnt
                            
                            if self.zip_current_filescnt == zipArr.count{
                                print("++++++++++++++++++++ 全部解压完成!")
                                ret.update_status = 5 //解压完成，准备更新数据库
                                ret.current_files = 0
                                ret.ds_file_percent = 0
                                ret.total_files = 0
                            }
                            
                            if ret.saveToDB() {
                                
                            }
                            
                        }
                        
                        //遍历资源目录
                        self._unzipSourceFile(filePath: newpath)
                        
                         FILESManager.default.deleteFileAt(path: srcpath)
                })
            }
        }
        
        //删除tmp所有文件
        //FILESManager.default.deleteFileAt(path: path)
    }
    
    //unzip queue获取数据
    func unzipFileFromTmp_2(url:String? = nil)  {
        let path = ROOTPATH.appending("/tmp")
        let plist = DataSourceManager.default.kUnzip_queue_path
        let downloadfiles = NSKeyedUnarchiver.unarchiveObject(withFile: plist) as? [String:[String]]
        guard let url = url ,let filesDic = downloadfiles ,let zipArr = filesDic[url] else{
            return
        }
        
        guard zipArr.count > 0 else{return}
        //单个数据源情况
        DataSourceManager.default._update_ds_status(url: url, key: "update_status", value: 4)
        DataSourceManager.default._update_ds_status(url: url, key: "total_files", value: zipArr.count)
        var has_unzipCnts:Int = 0
        
        for item in zipArr {
            if item.hasSuffix(".zip") {//解压tmp目录
                let srcpath = path.appending("/\(item)")
                let time = "\(Date().timeIntervalSince1970)"
                let newpath = ROOTPATH + "/\(time)"
                guard FILESManager.default.fileExistsAt(path: srcpath,createWhenNotExist: false) else {return}//zip不存在
                FILESManager.default.fileExistsAt(path: newpath)
                updateUnzipStatusData(time)
                
                SSZipArchive.unzipFile(atPath: srcpath, toDestination:newpath , progressHandler:{(entry, zipinfo, entrynumber, total)in
                    let progress =  Float(entrynumber) / Float(total)
                    if progress <= 1.0 {
                        DataSourceManager.default._update_ds_status(url: url, key: "ds_file_percent", value: progress)
                    }
                    },completionHandler:{/*[weak self]*/(path, success, error) in
                        has_unzipCnts = has_unzipCnts + 1
                        if let ret = DataSourceModel.search(with: "location_url='\(url)'", orderBy: nil).first as? DataSourceModel{
                            ret.ds_file_percent = 0.0
                            ret.current_files = has_unzipCnts
                            if has_unzipCnts == zipArr.count{
                                print("++++++++++++++++++++:\(url), 全部解压完成!")
                                ret.update_status = 5 //解压完成，准备更新数据库
                                ret.current_files = 0
                                ret.ds_file_percent = 0
                                ret.total_files = 0
                            }
                            
                            if ret.saveToDB() {
                                
                            }
                            
                        }
                        
                        //遍历资源目录
                        self._unzipSourceFile(filePath: newpath)
                        let u = URL.init(string: srcpath)
                        DataSourceManager.default.updatedsQueueWith(key:"\(url)",filePath: "\((u?.lastPathComponent)!)", isAdd: false,datatype:.unzip)
                        FILESManager.default.deleteFileAt(path: srcpath)
                        self.updateUnzipStatusData(time, isadd: false)
                })
            }
        }
    }
    
    
    /*手册内部遍历*/
    fileprivate func _unzipSourceFile(filePath:String){
        autoreleasepool { () -> () in
            do{
                let fileArr = try fm.contentsOfDirectory(atPath: filePath)
                guard fileArr.count > 0 else{return}
                for item in fileArr {
                    var isDir = ObjCBool(false)
                    let path = filePath.appending("/\(item)")
                    let isexist = fm.fileExists(atPath: path, isDirectory: &isDir)
                    if isexist && isDir.boolValue && !filePath.hasSuffix("resources") {
                        _unzipSourceFile(filePath: path)
                    }else if filePath.hasSuffix("resources") /*||  filePath.hasSuffix("images")*/ {
                        //解压资源目录,然后删除ZIP
                        SSZipArchive.unzipFile(atPath: path, toDestination: filePath,
                                               progressHandler: {(entry, zipinfo, entrynumber, total) in
                            },
                                               completionHandler: {(path, success, error) in
                                                guard success && path != "" else{return}
                                                FILESManager.default.deleteFileAt(path: path)
                        })
                    }
                }
                
            }catch{}
        }
        
    }
    
    /*func unzipWithCompleted(withurl:String, _ handler:@escaping (()->Void)) {
        _unzip_ds_url = withurl
        
//        let zipqueue = unzipOperationQueue()
        
        //从tmp更新
        self.queue.addOperation({
            self.unzipFileFromTmp_2(url: withurl)
        })
        
        self.queue.addOperation {
            let path = ROOTPATH.appending("/tmp")
            //FILESManager.default.deleteFileAt(path: path)
        }
        
        self.queue.addOperation({
            print("解压完成！！")
            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification.init(name: NSNotification.Name (rawValue: "kNotification_unzip_all_complete")))
            }
        })
        
        self.queue.addOperation({
            self.queue.isSuspended = true
            handler()    
        })
        
        self.queue.isSuspended = false
    }*/
    
    func unzipWithCompleted(withurl:String, _ handler:@escaping (()->Void)) {
        let zipqueue = unzipOperationQueue()
        UIApplication.shared.isIdleTimerDisabled = true
        
        //从tmp更新
        zipqueue.addOperation({
            self.unzipFileFromTmp_2(url: withurl)
        })

        zipqueue.addOperation({
            print("解压完成！！")
            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification.init(name: NSNotification.Name (rawValue: "kNotification_unzip_all_complete")))
            }
        })
        
        zipqueue.addOperation({
            zipqueue.isSuspended = true
            if DataSourceManager.default.unzipQueueIsEmpty().0 {
                handler()
            }
            
        })
        
        zipqueue.isSuspended = false
    }

    
    //MARK:-
    func checkUpdate() {
        let tmppath = LibraryPath.appending("/TDLibrary/tmp")
        let doczip = getZipFiles(items: UNZIPFile.default.getFilesAt(path: DocumentPath))
        if doczip.count > 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name (rawValue: "kNotification_unzipfile_start"), object: nil, userInfo: nil)
            }
            
            FILESManager.default.deleteFileAt(path: tmppath)
            //从doc更新
            self.queue.addOperation({
                self.unzipFileFromDocument()
            })
            
            //delete doc
            self.queue.addOperation {
                let files = self.getFilesAt(path: DocumentPath)
                let zipArr = self.getZipFiles(items: files)
                for p in zipArr {
                    if p.hasSuffix(".zip") {
                        let srczip = DocumentPath + "/\(p)"
                        FILESManager.default.deleteFileAt(path: srczip)
                    }
                }
            }
            
            self.queue.addOperation({
                self.unzipFileFromTmp()
            })
            
            //delete tmp
            self.queue.addOperation {
                let path = ROOTPATH.appending("/tmp")
                FILESManager.default.deleteFileAt(path: path)
            }
            
            self.queue.addOperation({
                print("解压完成！！")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(Notification.init(name: NSNotification.Name (rawValue: "kNotification_unzip_all_complete")))
                }
            })
            
            self.queue.addOperation {
                self._sendNotificationBeforeUpdate()
            }

            self.queue.addOperation({
                self._startUpdate()
            })
            
            self.queue.addOperation({
                print("移动完成！！")
                self.queue.isSuspended = true
            })
            
            
        }else{
            
            if FILESManager.default.fileExistsAt(path: tmppath, createWhenNotExist: false) && UNZIPFile.default.getFilesAt(path: tmppath).count > 0{
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name (rawValue: "kNotification_unzipfile_start"), object: nil, userInfo: nil)
                }

                let files = getFilesAt(path: ROOTPATH)
                    for item in files {
                        if Double(item as String) != nil {
                            let itempath = ROOTPATH.appending("/\(item)")
                            FILESManager.default.deleteFileAt(path: itempath)
                        }
                    }
                
                //从tmp更新
                self.queue.addOperation({
                    self.unzipFileFromTmp()
                })
                
                self.queue.addOperation {
                    let path = ROOTPATH.appending("/tmp")
                    FILESManager.default.deleteFileAt(path: path)
                }
                
                
                self.queue.addOperation({
                    print("解压完成！！")
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(Notification.init(name: NSNotification.Name (rawValue: "kNotification_unzip_all_complete")))
                    }
                })
                
                self.queue.addOperation {
                    self._sendNotificationBeforeUpdate()
                }

                self.queue.addOperation({
                    self._startUpdate()
                })
                
                self.queue.addOperation({
                    print("移动完成！！")
                    self.queue.isSuspended = true
                })

            }else{
                if let path = UserDefaults.standard.string(forKey: "book_path") {
                    let bookpath = getBookPath(withRelPath: ROOTPATH.appending("/\(path)"))
                    let arr  = path.components(separatedBy: "/")
                    let name = arr.last//...？？？？
                    
                    //从3.更新
                    self.queue.addOperation({
                        self._parseBook(bookpath: bookpath, bookname: name!)
                    })
                    
                    self.queue.addOperation {
                        self._sendNotificationBeforeUpdate()
                    }

                    self.queue.addOperation({
                        self._startUpdate()
                    })
                    
                    self.queue.addOperation({
                        print("移动完成！！")
                        self.queue.isSuspended = true
                    })
                }else{
                    print("DOCUMENT 没有文档需要更新！")
                }
                
            }
            
            }
       
    }
    
    //安装手册
    func installBook(){

        //检测是否有更新
        UIApplication.shared.isIdleTimerDisabled = true
        
        checkUpdate()
        
        self.queue.isSuspended = false
    }
    
    func update(url:String? = nil) {
        UIApplication.shared.isIdleTimerDisabled = true

        self.queue.addOperation {
            self._sendNotificationBeforeUpdate()
        }
        
        self.queue.addOperation {
            self._startUpdate()
        }
        
        self.queue.addOperation({
            if  let ret = DataSourceModel.search(with: "update_status='\(5)'", orderBy: nil) as? [DataSourceModel]{
                for m in ret{
                    m.ds_file_percent = 0.0
                    m.update_status = 6
                    
                    if m.location_url == "itunes import"{
                        m.deleteToDB()
                    }else if m.saveToDB() {
                        
                    }
                }
                print("++++++++++++++++++++ 全部更新完成!")
                
            }

            self.queue.isSuspended = true
        })
        
        self.queue.isSuspended = false

    }
    

    //MARK:- 数据更新
    ///
    func _sendNotificationBeforeUpdate(){
        let files = getFilesAt(path: ROOTPATH)
        let pubs = {(_ items: [String]) -> ([String]) in
            var zips = [String]()
            for item in items {
                if Double(item as String) != nil {
                    if let last = UserDefaults.standard.object(forKey: "unzipfileinprocessing") as?[String]{
                        if last.contains(item){
                            let p = ROOTPATH.appending("/\(item)")
                            FILESManager.default.deleteFileAt(path: p)
                            continue;
                        }

                    }
                    
                    zips.append(item)
                }
            }
            return zips
        }(files)
        
        guard pubs.count > 0 else{return}
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name (rawValue: "kNotification_start_update"), object: nil, userInfo: ["filesnumber":pubs.count])
        }
        
    }
    
    //保存正在解压中的文件，用于中断处理
    func updateUnzipStatusData(_ file:String,isadd:Bool = true,flush:Bool = false) {
        let key = "unzipfileinprocessing"
        if flush {
            UserDefaults.standard.removeObject(forKey: key);return
        }

        if var arr = UserDefaults.standard.object(forKey: key) as?[String]{
            if isadd{
                arr.append(file)
            }else{
                arr.remove(at: arr.index(of: file)!)
            }
            
            UserDefaults.standard.set(arr, forKey: key)
        }else{
            UserDefaults.standard.set([file], forKey: key)
        }
        UserDefaults.standard.synchronize()
    }
    
    //解析
    func _startUpdate() {
    autoreleasepool(invoking: { () -> () in
        let files = getFilesAt(path: ROOTPATH)
        let pubs = {(_ items: [String]) -> ([String]) in
            var zips = [String]()
            for item in items {
                if Double(item as String) != nil {
                    zips.append(item)
                }
            }
            return zips
        }(files)
        
        updateUnzipStatusData("", isadd: false, flush: true)
        guard pubs.count > 0 else{return}
        for item in pubs {
            let path1 = ROOTPATH.appending("/\(item)")//150r4r4425435.64562
            let f2 = getFilesAt(path: path1)
            for item in f2{//cca
                let path_cca = ROOTPATH.appending("/\(item)")
                let path2 = path1.appending("/\(item)")
                guard let bookname  = getFilesAt(path: path2).first else{return}
                let srcpath = path2.appending("/\(bookname)")
                let despath = path_cca.appending("/\(bookname)")
                
                UserDefaults.standard.setValue(item + "/\(bookname)", forKey: "book_path")
                UserDefaults.standard.synchronize()
                if FILESManager.default.fileExistsAt(path: path_cca){//owner 已存在
                    let cca_files = getFilesAt(path: path_cca)
                    if !cca_files.contains(bookname) {
                        do{
                            try fm.moveItem(atPath: srcpath, toPath: despath)
                            //FILESManager.default.deleteFileAt(path: path1)
                        }catch{
                            print(error)
                        }
                    }else{
                        print("已存在：\(bookname)")
                        UserDefaults.standard.removeObject(forKey: "book_path")
                        FILESManager.default.deleteFileAt(path: path1)
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name (rawValue: "kNotification_book_update_complete"), object: nil, userInfo: nil)
                        }
                        continue
                        //.....RESERVE
                    }
                }else{
                    do{
                        try fm.moveItem(atPath: srcpath, toPath: despath)
                    }catch{
                        print(error)
                    }
                }
                FILESManager.default.deleteFileAt(path: path1)
                
                /////解析
                let bookpath = getBookPath(withRelPath: despath)
                _parseBook(bookpath: bookpath, bookname: bookname)
            }
       
        }
      })
    }
    
    //解析BOOK
    func _parseBook(bookpath:String,bookname:String){
        autoreleasepool(invoking: { () -> () in
        HUD.show(withStatus: "数据更新中...")
        getAirplanesData(withPath: bookpath,bookName:bookname as String)
        getBookData(withPath: bookpath)
        #if false
        getSegmentsData(withBookPath: bookpath,bookName:bookname as String)
        #else
        XMLParseKit.default.parserStart(withBookPath: bookpath, bookName: bookname, completeHandler: {
            UserDefaults.standard.removeObject(forKey: "book_path")
            DispatchQueue.main.async {
                print("单个手册数据处理完成")
                HUD.dismiss()
                NotificationCenter.default.post(name: NSNotification.Name (rawValue: "kNotification_book_update_complete"), object: nil, userInfo: nil)
            }
        })
        #endif
        })
    }
    
    
    
    //MARK: - SSZipArchiveDelegate
    func zipArchiveWillUnzipArchive(atPath path: String, zipInfo: unz_global_info) {
        print("\(#function)")
    }
    
    func zipArchiveDidUnzipArchive(atPath path: String, zipInfo: unz_global_info, unzippedPath: String) {
        print("\(#function)")
        if FileManager.default.isDeletableFile(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            }catch{
                print(error)
            }
        }else {
            print("文件删除失败-----------------------")
        }
    
    }
    
    
}

