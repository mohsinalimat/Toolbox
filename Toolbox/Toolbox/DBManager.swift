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
//            getSegments()
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
    
    //获取节点目录-现在的处理的指定手册，需完善？？？？？
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
    
    
}


//MARK: 文件解压及数据处理
extension DBManager : SSZipArchiveDelegate {
    
    
    //安装手册
    func installBook(){
        let fm = FileManager.default
        let despath = ROOTPATH + ROOTSUBPATH
        
        let exist = fm.fileExists(atPath: despath)
        if !exist
        {
            print("目录：\(despath) 不存在！");
            do{
                try fm.createDirectory(atPath: despath, withIntermediateDirectories: true, attributes: nil)
                print("创建目录\(despath)")
            }catch{
                print(error)
            }
        }
        
        do{
            let zipArr = try fm.contentsOfDirectory(atPath: HTMLPATH)
            
            for p in zipArr {
                let fullzip = HTMLPATH + "/\(p)"
                
                let filefullpath = despath + p.substring(to: p.index(p.endIndex, offsetBy: -4))
                
                if !fm.fileExists(atPath: filefullpath){
                    print("开始解压：\(fullzip)")
                    SSZipArchive.unzipFile(atPath: fullzip, toDestination: despath, delegate: self)
                    
                    //获取手册信息
                    
                    //获取章节目录
                    
                }else{
                    print("文件已存在:\(filefullpath)")
                }
                
            }
        }catch{
            print(error)
        }
        
    }

   
    //MARK: -
    func zipArchiveWillUnzipArchive(atPath path: String, zipInfo: unz_global_info) {
        
    }
    
    func zipArchiveDidUnzipArchive(atPath path: String, zipInfo: unz_global_info, unzippedPath: String) {
     let arr = path.components(separatedBy: "/")
        let zip = arr.last
        let name = zip?.substring(to: (zip?.index((zip?.endIndex)!, offsetBy: -4))!)
    }
}











