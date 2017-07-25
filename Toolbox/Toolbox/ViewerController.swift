//
//  ViewerController.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import SSZipArchive

class ViewerController: BaseViewControllerWithTable ,SSZipArchiveDelegate{

    var currentPublication:PublicationsModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let url = loadData() else {
            return
        }
        
//        let url = Bundle.main.path(forResource: "11-00-00-01B", ofType: "html")
        let webview = UIWebView.init(frame:  CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: kCurrentScreenHight - 64 - 49))
        webview.loadRequest(URLRequest.init(url: URL.init(string: url)!))
        view.addSubview(webview)
    }

    
    //MARK: - 数据处理
    //前级数据改变-后级数据的操作处理？？？？？？
    func loadData() -> String? {
        //第一次进入currentPublication数据可能为空，稍后做提示处理？
        guard let selectedPublication = kSelectedPublication else {
            return nil
        }
        guard currentPublication !== selectedPublication  else {
            return nil
        }
        currentPublication = selectedPublication
        
        
        /*
         /var/mobile/Containers/Data/Application/3DE63D99-03B4-40D6-8CA5-581FD04C1AF1/Library/TDLibrary
         /CCA/CCAA320CCAAIPC20161101/aipc
         /75/EN75244880B.html
        
        */
        
        
        let s1 = ROOTPATH
        let s2 = currentPublication.booklocalurl
        let s3 = kSelectedSegment?.content_location
        
        let path = s1 + s2! + s3!
        let pathzip = path + ".zip"
        
        /*
        let existFile = FileManager.default.fileExists(atPath: path)
        if !existFile
        {
            //print("目标路径：\(path) 不存在！");//return nil
        }
        
        let existZip = FileManager.default.fileExists(atPath: pathzip)
        if !existZip
        {
            //print("目标路径：\(pathzip) 不存在！");//return nil
        }
        */
        
        let p = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] + "/210"
        
      
        
         do{
      
          try  FileManager.default.createDirectory(atPath: p, withIntermediateDirectories: true, attributes: nil)
    
         }catch{
         print(error)
         }
         
        
        
        //let test = Bundle.main.path(forResource: "EN21210101C", ofType: ".html.zip")
        //let des = test?.substring(to: ((test?.index((test?.endIndex)!, offsetBy: -4)))!)
        

        SSZipArchive.unzipFile(atPath: pathzip, toDestination: p, delegate: self)
        
        
        return path
    }
    
    
    //MARK:-
    func zipArchiveWillUnzipArchive(atPath path: String, zipInfo: unz_global_info) {
        print("zipArchiveWillUnzipArchive")
    }
    
    func zipArchiveDidUnzipArchive(atPath path: String, zipInfo: unz_global_info, unzippedPath: String) {
        print("zipArchiveDidUnzipArchive")
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
