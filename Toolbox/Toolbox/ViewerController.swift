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

    var currentSegment:SegmentModel!
    var currenthtml:String?
    var webview:UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
//        let p1 = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] + "/210/04/EN04050001.html.zip"
//        let p2 = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] + "/210/04/"


        
        webview = UIWebView.init(frame:  CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: kCurrentScreenHight - 64 - 49))
        view.addSubview(webview)
    }

    override func viewWillAppear(_ animated: Bool) {
        guard let url = loadData() else {
            return
        }
        webview.loadRequest(URLRequest.init(url: URL.init(string: url)!))
        super.viewWillAppear(animated)
    }
    
    
    
    //MARK: - 数据处理
    //前级数据改变-后级数据的操作处理？？？？？？
    func loadData() -> String? {
        //第一次进入currentPublication数据可能为空，稍后做提示处理？
        guard let selectedPublication = kSelectedSegment else {
            return nil
        }
        guard currentSegment !== selectedPublication  else {
            return nil
        }
        currentSegment = selectedPublication
        
        
        /*
         /var/mobile/Containers/Data/Application/3DE63D99-03B4-40D6-8CA5-581FD04C1AF1/Library/TDLibrary
         /CCA/CCAA320CCAAIPC20161101/aipc
         /75/EN75244880B.html
        */
        let s1 = ROOTPATH
        let s2 = kSelectedPublication?.booklocalurl
        let s3 = kSelectedSegment?.content_location
        let path = s1 + s2! + s3!
        let pathzip = path + ".zip"
        
        let htmlfullpath = HTMLPATH + s2! + s3!
        let htmlpath = HTMLPATH + s2! + (s3?.substring(to: (s3?.index((s3?.startIndex)!, offsetBy: 3))!))!
        
        
        let existFile = FileManager.default.fileExists(atPath: htmlpath)
        if !existFile
        {
            print("dir：\(htmlpath) 不存在！");
            do{
                try FileManager.default.createDirectory(atPath: htmlpath, withIntermediateDirectories: true, attributes: nil)
                print("创建目录\(htmlpath)")
            }catch{
                print(error)
            }
        }
        
        let existZip = FileManager.default.fileExists(atPath: htmlfullpath)
        if !existZip
        {
            print("file：\(htmlfullpath) 不存在！");
            
            let existZip = FileManager.default.fileExists(atPath: pathzip)
            if !existZip
            {
                print("zip路径：\(pathzip) 不存在！"); return nil
            }else{
                
               let ret = SSZipArchive.unzipFile(atPath: pathzip, toDestination: htmlpath, delegate: self)
                if ret {
                    do {
                           try FileManager.default.removeItem(atPath: pathzip)
                    }catch{
                        print(error)
                    }
               
                }
            }
            
        }
        
        return htmlfullpath

    }
    
    
    //MARK:-
    func zipArchiveWillUnzipArchive(atPath path: String, zipInfo: unz_global_info) {
        print("zipArchiveWillUnzipArchive")
    }
    
    func zipArchiveDidUnzipArchive(atPath path: String, zipInfo: unz_global_info, unzippedPath: String) {
        print("zipArchiveDidUnzipArchive")
    }
    
    
    
    
    
    /*
     [SSZipArchive] Set attributes failed for directory: /var/mobile/Containers/Data/Application/169034CB-A0A2-4DB9-A695-F5331D5613FC/Library/210/04/EN04050001.html.
     2017-07-26 17:00:57.224 Toolbox[14264:1313126] [SSZipArchive] Error setting directory file modification date attribute: The file “EN04050001.html” doesn’t exist.
     
     
     --------
     
     Error Domain=NSCocoaErrorDomain Code=513 "“EN21210101C.html.zip” couldn’t be removed because you don’t have permission to access it." UserInfo={NSFilePath=/var/mobile/Containers/Data/Application/53C98F87-F04A-4BF0-AAC1-377EB6B25C5A/Library/TDLibrary/CCA/CCAA320CCAAIPC20161101/aipc/21/EN21210101C.html.zip, NSUserStringVariant=(
     Remove
     ), NSUnderlyingError=0x1377ba110 {Error Domain=NSPOSIXErrorDomain Code=13 "Permission denied"}}
     
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
