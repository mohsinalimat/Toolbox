//
//  DataParseKit.swift
//  Toolbox
//
//  Created by gener on 17/8/18.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class DataParseKit: NSObject,XMLParserDelegate {

    static let `default` = DataParseKit.init()
    
    var xmlParser:XMLParser!
    var book_id:String!
    
    var parent_id:String!
    var primary_id:String!
    
    var nodeName:String!
    var nodeLevel:Int = 0
    
    var modelDic = [String : String]()
    var parDic = [Int:String]()
    
    var completeHandlers:((Void)->(Void))?
    
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

    
    //MARK:-XMLParserDelegate
    func parserDidStartDocument(_ parser: XMLParser ) {
        print("\(#function)")
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        print("\(#function)")
        
        if !modelDic.isEmpty {
            SegmentModel.saveToDb(with: modelDic)
        }
        
        if let completeHandler = completeHandlers {
            completeHandler()
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        print("\(#function)---- \(elementName)")
        
        nodeName = elementName
        
        guard nodeLevel > 0 else {
            nodeLevel = nodeLevel + 1;return
        }
        
        if elementName == "segment" {
            print("nodeLevel : \(nodeLevel)")
            
            if !modelDic.isEmpty {
              SegmentModel.saveToDb(with: modelDic)
            }
            
            modelDic.removeAll()
            
            
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
                print("ID nillll。。。")
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
        print("\(#function)----\(nodeName!) : \(string)")
        
        if nodeName == "title" {
            modelDic[nodeName] = string
        }
        
        
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("\(#function)---- \(elementName)")
        
        if elementName == "segment" {
             nodeLevel = nodeLevel - 1
        }
        
       nodeName = ""
    }
    
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("\(#function) : \(parseError.localizedDescription)")
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}


