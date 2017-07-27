//
//  ViewerController.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import SSZipArchive

class ViewerController: BaseViewControllerWithTable ,SSZipArchiveDelegate,UIWebViewDelegate{

    var currentSegment:SegmentModel!
    var currenthtml:String?
    var webview:UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webview = UIWebView.init(frame:  CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: kCurrentScreenHight - 64 - 49))
        view.addSubview(webview)
    }

    override func viewWillAppear(_ animated: Bool) {
        guard let url = getFilePath() else {
            return
        }
        webview.loadRequest(URLRequest.init(url: URL.init(string: url)!))
        super.viewWillAppear(animated)
    }
    
    
    
    //MARK: - 获取文件路径
    //前级数据改变-后级数据的操作处理？？？？？？
    func getFilePath() -> String? {
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
        let htmlfullpath = s1 + s2! + s3!
        let htmlzippath = htmlfullpath + ".zip"
        let htmldirpath = s1 + s2! + (s3?.substring(to: (s3?.index((s3?.startIndex)!, offsetBy: 3))!))!

        let fileExist = FileManager.default.fileExists(atPath: htmlfullpath)
        if !fileExist
        {
            print("file：\(htmlfullpath) 不存在！");
            let zipExist = FileManager.default.fileExists(atPath: htmlzippath)
            if !zipExist
            {
                print("zip路径：\(htmlzippath) 不存在！"); return nil
            }else{
                
                SSZipArchive.unzipFile(atPath: htmlzippath, toDestination: htmldirpath, delegate: self)
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
    
    
    //MARK:- UIWebViewDelegate
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //保存到浏览历史记录
        
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
