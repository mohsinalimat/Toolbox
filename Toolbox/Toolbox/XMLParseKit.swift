//
//  XMLParseKit.swift
//  Toolbox
//
//  Created by gener on 17/8/18.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import CoreData

class XMLParseKit: NSObject,XMLParserDelegate {

    static let `default` = XMLParseKit.init()
    
    var xmlParser:XMLParser!
    var book_id:String!
    
    var parent_id:String!
    var primary_id:String!
    
    var nodeName:String!
    var nodeLevel:Int = 0
    
    var modelDic = [String : String]()
    var parDic = [Int:String]()
    
    var completeHandlers:((Void)->(Void))?
    
    var TotalModel = [Any]()
    
    let isCoreData = false
    
    var cnt = 0
    
    deinit {
        print("XMLParseKit - deinit---------------")
    }
    
    //MARK:-
    func parserStart(withBookPath path:String ,bookName:String,completeHandler:(()->())? = nil) {
        print("\(path)")
        
        let path = path.appending("/resources/toc.xml")
        
        book_id = bookName
        if let handler = completeHandler{
            completeHandlers = handler
        }
        
        do{
            let jsonString = try String(contentsOfFile: path)
            if let jsondata = jsonString.data(using: .utf8, allowLossyConversion: true){
                xmlParser = XMLParser.init(data: jsondata)
                xmlParser.delegate = self
                xmlParser.parse()
            }
        }catch{
            print(error.localizedDescription)
        }
        
    }

    private func _save(){
        if !modelDic.isEmpty {
            let dic = modelDic
            TotalModel.append(dic)
            
            if TotalModel.count > 10000{
                FMDB.default().insert(with: TotalModel)
                TotalModel.removeAll()
            }
//            if !isCoreData{
//                SegmentModel.saveToDbNotCheck(with: modelDic)
//            }else{
//                CoreDataKit.default.insert(dic: modelDic)
//            }
            
            //FMDB.default().insert(withDic: modelDic)
            
            modelDic.removeAll()
        }
    }
    
    //MARK:-XMLParserDelegate
    func parserDidEndDocument(_ parser: XMLParser) {
        print("\(#function)")
        
        _save()
        
        FMDB.default().insert(with: TotalModel)
        
        //CoreDataKit.default.update(data: TotalModel as! [[String : Any]])
        if let completeHandler = completeHandlers {
            completeHandler()
        }
        
        TotalModel.removeAll()
        parDic.removeAll()
        xmlParser = nil
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        //print("\(#function)---- \(elementName)")
        
        nodeName = elementName
        
        guard nodeLevel > 0 else {
            nodeLevel = nodeLevel + 1;return
        }
        
        if elementName == "segment" {
            _save()
            if nodeLevel == 1 {
                parent_id = book_id
                parDic.removeAll()
            }else{
                parent_id = parDic[nodeLevel]
            }
            
            for d in attributeDict{
                modelDic[d.key] = d.value
            }
            
            var _id = modelDic["id"]
            if _id == nil {
                //print("ID nillll。。。")
                _id = book_id//.................
            }
            
            let primaryid = book_id + _id!
            modelDic["toc_id"] = _id
            modelDic["primary_id"] = primaryid
            modelDic["parent_id"] = parent_id
            modelDic["book_id"] = book_id
            modelDic["nodeLevel"] = "\(nodeLevel)"
            
            parDic[nodeLevel] = parent_id
            parDic[nodeLevel + 1] = primaryid
            
            
            //content_location
            let isleaf = Int(modelDic["is_leaf"]!)!
            let isvisible = Int(modelDic["is_visible"]!)!
            if isleaf == 1 && isvisible == 1 {
                let localtion :String! = modelDic["content_location"]
                let new = localtion.substring(from: (localtion.index(localtion.startIndex, offsetBy: 2)))
                modelDic["content_location"] = new
            }
            
            
            //下一层级
            nodeLevel = nodeLevel + 1
        }
        else if elementName == "effect"{//有效性判断
            for d in attributeDict{
                modelDic[d.key] = d.value
            }
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //print("\(#function)----\(nodeName!) : \(string)")
        
        if nodeName == "title" {
            modelDic[nodeName] = string
        }
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //print("\(#function)---- \(elementName)")
        
        if elementName == "segment" {
             nodeLevel = nodeLevel - 1
        }
        
       nodeName = ""
    }
    
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("\(#function) : \(parseError.localizedDescription)")
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}


