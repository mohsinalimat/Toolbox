//
//  DBManager.swift
//  Toolbox
//
//  Created by gener on 17/7/10.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import KissXML
import SSZipArchive

class DBManager: NSObject {
    static let `default` :DBManager = DBManager()
    let fm = FileManager.default
    
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

    ///主调方法
   public func startParse() {
    
        if !updateTableInfoisExist(cls: AirplaneModel.self) {
            getapList()
        }
        else{
            print("Airplane已存在");
        }
        if !updateTableInfoisExist(cls: PublicationsModel.self) {
            getbooks()
        }
        else{
            print("Publications已存在");
        }
    
        if !updateTableInfoisExist(cls: SegmentModel.self) {
            getSegments()
        }
        else{
            print("SegmentModel已存在");
        }
    
        getapMpdel()
    
        //...test
//        getSegments()
    
    }

    
    //MARK:
    //获取apmodel赋值给全局变量- kAllPublications
    func getapMpdel(){
        DBManager.parseJsonData(path: APMODELMAPJSPATH,preprogressHandler: { str in
            let s = str
            let newstr = s.replacingOccurrences(of: "varapModelMap=", with: "").replacingOccurrences(of: ";", with: "")
            return newstr
        }){(obj) in
            let obj =  obj as? [String:Any]
            if obj != nil{
                kAllPublications = obj!
            }
        }
    }
    
    func getapList(){
        //获取apaList.json所有路径
        let path = getPath()
        
        //解析数据并保存
        for index in 0..<path.count {
            DBManager.parseJsonData(path: path[index].appending(APLISTJSONPATH), completionHandler: { (obj) in
                let obj =  obj as? [String:Any]
                guard let airplaneEntryArr = obj?["airplaneEntry"] as? [Any] else { return}
                AirplaneModel.saveToDb(with: airplaneEntryArr)
            })
        }
    
        updateTableinfo(cls: AirplaneModel.self)
    }
    
    //获取手册信息
    func getbooks() {
        var paths = DBManager.default.getPath()
        for index in 0..<paths.count {
            var path = paths[index]
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

        updateTableinfo(cls: PublicationsModel.self)
    }
    
    //获取节点目录-现在处理的指定手册，需完善？？？？？
    func getSegments(model:PublicationsModel? = nil) {
        var path = getPath()[0]
        path = path.appending("/resources/toc.xml")
        
        let book_id = "CCAA320CCAAIPC20161101"
        
        do{
            let jsonString = try String(contentsOfFile: path)
            if let jsondata = jsonString.data(using: .utf8, allowLossyConversion: true){
                let doc = try DDXMLDocument.init(data: jsondata, options: 0)
                
                let rootE:DDXMLElement! = doc.rootElement()
                let segs:[DDXMLElement] = rootE.elements(forName: "segment")
                
                
                //建立索引
                for element in segs {
                    let parent_id = book_id
                    traversalNode(element: element, parentId: parent_id, bookId: book_id,lv:1)
                }
      
                updateTableinfo(cls: SegmentModel.self,id:model?.book_uuid)
                
//               let queue = DispatchQueue.init(label: "lable")
//              queue.async(execute: {
//                
//              })
                
                
            }
        }catch{
            print(error)
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
        
        let titleElement = element.elements(forName: "title")[0]
        des["title"] = titleElement.stringValue
        
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
        let isleaf = Int(des["is_leaf"]!)!
        if isleaf == 1 {
            let localtion :String! = des["content_location"]
            let new = localtion.substring(from: (localtion.index(localtion.startIndex, offsetBy: 2)))
            des["content_location"] = new
        }
        SegmentModel.saveToDb(with: des)
    
        if isleaf == 0 {
            let eles = element.elements(forName: "segment")
            for ele in eles {
                traversalNode(element: ele, parentId: primaryid, bookId: bookId,lv:lv + 1)
            }
        }
   
    }
    
    
    
    //获取路径-手册
    func getPath() -> [String] {
        let basepath = ROOTPATH + ROOTSUBPATH
        let fm = FileManager.default
        var pathArr = [String]()
        do{
            let files = try fm.contentsOfDirectory(atPath: basepath)
            for item in files {
                var isDir = ObjCBool(false)
                let path = basepath + item
                let isexist = fm.fileExists(atPath: path, isDirectory: &isDir)
                
                if isexist && isDir.boolValue {
                    let sub = try fm.contentsOfDirectory(atPath: path)
                    if sub.count > 0 {
                        pathArr.append(path.appending("/\(sub[0])"))
                    }
                }
            }
        }catch{
            print("GET PATH ERROR:\(error)")
        }
      
        return pathArr
    }
    
    //MARK:-
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
    
    //是否存在
    private func updateTableInfoisExist(cls:Model.Type) -> Bool {
        let m = UpdateInfo.search(with: "table_name='\(cls.getTableName())'", orderBy: nil)
        return (m != nil) && (m?.count)! > 0 ? true:false
    }
    
    
    func deleteFile(path:String) {
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
    
}




//1502086746.428690
//MARK: 文件解压及数据处理
extension DBManager : SSZipArchiveDelegate {
    
    func getFilesAt(path:String) -> [NSString] {
        var files = [String]()
        do {
            files = try fm.contentsOfDirectory(atPath: path)
        } catch  {
            print("\(#function)" + error.localizedDescription)
        }
        
        return files as [NSString]
    }
    
    
    //安装手册
    func installBook(){
        //let despath = ROOTPATH + ROOTSUBPATH
        
        moveAndParse()
        
        let despath = LibraryPath.appending("/TDLibrary/tmp")
        let baseinfodatapath = LibraryPath.appending("/Application data")
        
        LocationManager.default.checkPathIsExist(path: despath)
        LocationManager.default.checkPathIsExist(path: baseinfodatapath)

        do{
            let zipArr = try fm.contentsOfDirectory(atPath: DocumentPath)
            
            for p in zipArr {
                if p.hasSuffix(".zip") {
                    let srczip = DocumentPath + "/\(p)"
                    print("开始解压：\(srczip)")
//                    SSZipArchive.unzipFile(atPath: srczip, toDestination: despath, delegate: self)
                    SSZipArchive.unzipFile(atPath: srczip, toDestination: despath, progressHandler: { (entry, zipinfo, entrynumber, total) in
                        print("\(entrynumber) - \(total)")
                        if !entry.hasSuffix(".zip") {
                            do{
                               try self.fm.moveItem(atPath: despath + "/\(entry)", toPath: baseinfodatapath +  "/\(entry)")
                            }catch{
                                print(error)
                            }
                            
                        }
                        
                        }, completionHandler: { (path, success, error) in
                             print("DOCMENT解压完成：\(path)")
                            //
                            self.unzipFile(path: despath)
                            
                    })
                }
            
            }
        }catch{
            print(error)
        }
        
    }
    
    //解压缓存目录
    func unzipFile(path:String)  {
        print("path:\(path)")
        
        /*手册内部遍历*/
        func unzipSingleFile(filePath:String){
            print("filePath:\(filePath)")
            do{
                let fileArr = try fm.contentsOfDirectory(atPath: filePath)
                for item in fileArr {
                    var isDir = ObjCBool(false)
                    let path = filePath.appending("/\(item)")
                    let isexist = fm.fileExists(atPath: path, isDirectory: &isDir)
                    if isexist && isDir.boolValue {
                        unzipSingleFile(filePath: path)
                        
                    }else if filePath.hasSuffix("resources") /*||  filePath.hasSuffix("images")*/ {
                        //解压资源目录
                        SSZipArchive.unzipFile(atPath: path, toDestination: filePath,
                                               progressHandler: {(entry, zipinfo, entrynumber, total) in
                            },
                                               completionHandler: { [weak self] (path, success, error) in
                        guard let strongSelf = self else { return }
                        strongSelf.deleteFile(path: path)
                        })
                    }
                }
                //1502185017.35775解压处理完毕，判断手册owner，移动,删除
                moveAndParse()
                
            }catch{}
        }
        
        
        do{
            let fileArr = try fm.contentsOfDirectory(atPath: path)
            for item in fileArr {
                if item.hasSuffix(".zip") {//解压tmp目录
                    let srcpath = path.appending("/\(item)")
                    let newpath = ROOTPATH + "/\(Date().timeIntervalSince1970)"
                    
                    
                    LocationManager.default.checkPathIsExist(path: newpath)
                    
                    SSZipArchive.unzipFile(atPath: srcpath, toDestination:newpath , progressHandler:{(entry, zipinfo, entrynumber, total) in
                            print("\(entrynumber) - \(total)")
                        },completionHandler:{[weak self](path, success, error) in
                            print("一个TMP解压完成:\(path)")

                            //重新开始遍历
                            unzipSingleFile(filePath: newpath)
                            
                            //删除源文件
                            guard let strongSelf = self else { return }
                            strongSelf.deleteFile(path: path)
                    })
                }
            }
           
            //删除tmp所有文件
            deleteFile(path: path)
            
        }catch{
            print(error)
        }
        
    }
    
   
    
    
    
    
    
    
    
    
    
    //移动到正式手册路径
    func moveAndParse() {
        let files = getFilesAt(path: ROOTPATH)
        for item in files {
            if item.hasPrefix("150"){
            let path1 = ROOTPATH.appending("/\(item)")//150
                let f2 = getFilesAt(path: path1)
                for item in f2{//cca
                    let path_cca = ROOTPATH.appending("/\(item)")
                    let path2 = path1.appending("/\(item)")
                    guard let f3  = getFilesAt(path: path2).first else{return}
                    if LocationManager.default.checkPathIsExist(path: path_cca){//owner 已存在
                        let cca_files = getFilesAt(path: path_cca)
                        if !cca_files.contains(f3 as NSString) {
                            do{
                                let srcpath = path2.appending("/\(f3)")
                                
                                Model.moveItem(atPath: srcpath, toPath: path_cca)
                                
                                try fm.moveItem(atPath: srcpath, toPath: path_cca)
                            }catch{
                                print(error)
                            }
                        }
                        
                    }else{
                        do{
                            let srcpath = path2.appending("/\(f3)")
                            try fm.moveItem(atPath: srcpath, toPath: path_cca)
                        }catch{
                            print(error)
                        }
                    }
                }
            }
        }
        
        
    }
    
    
    //MARK: - SSZipArchiveDelegate
    func zipArchiveWillUnzipArchive(atPath path: String, zipInfo: unz_global_info) {
        
    }
    
    func zipArchiveDidUnzipArchive(atPath path: String, zipInfo: unz_global_info, unzippedPath: String) {
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











