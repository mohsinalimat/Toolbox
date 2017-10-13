//
//  ImgCollectionViewCell.swift
//  Toolbox
//
//  Created by gener on 17/10/12.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import SSZipArchive

class ImgCollectionViewCell: UICollectionViewCell,UIWebViewDelegate {

    @IBOutlet weak var _imgwebview: UIWebView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        _imgwebview.scrollView.showsHorizontalScrollIndicator = false
        _imgwebview.scrollView.showsVerticalScrollIndicator = false
        _imgwebview.scrollView.bounces = false
    }
    
    func fillCellWith(_ model:SegmentModel) {
        guard var urlStr = getFilePath(model.content_location) else{return}
        
        //Loading()
        urlStr =  urlStr.replacingOccurrences(of: " ", with: "%20")
        let key:String = "cec"
        let value:String! = kSelectedAirplane?.value(forKey: "customerEffectivity") as! String
        let newurl = urlStr.appending("?airplane=\(value!)&idType=\(key)")
        _imgwebview.loadRequest(URLRequest.init(url: URL.init(string: newurl)!))
        
    }
    
    //MARK: - 获取文件路径
    func getFilePath(_ location:String?) -> String? {
        guard let pub_url = kSelectedPublication?.booklocalurl,let seg_url = location else {
            return nil
        }

        let s1 = ROOTPATH
        let s2 = pub_url
        let s3 = seg_url
        let htmlfullpath = s1 + s2 + s3
        let htmlzippath = htmlfullpath + ".zip"
        let htmldirpath = s1 + s2 + s3.substring(to: (s3.index((s3.startIndex), offsetBy: 3))) + "/images"
        let fileExist = FileManager.default.fileExists(atPath: htmlfullpath)
        if !fileExist
        {
            print("file：\(htmlfullpath) 不存在！");
            let zipExist = FileManager.default.fileExists(atPath: htmlzippath)
            if !zipExist
            {
                print("zip路径：\(htmlzippath) 不存在！"); return nil
            }else{
                SSZipArchive.unzipFile(atPath: htmlzippath, toDestination: htmldirpath, progressHandler: {(entry, zipinfo, entrynumber, total) in }, completionHandler: {  (path, success, error) in
                    print("解压完成：\(path)")
                    FILESManager.default.deleteFileAt(path: path)
                })
            }
            
        }
        
        return htmlfullpath
    }
    
    
    //MARK:- UIWebViewDelegate
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        /*let url  = request.url
        let fm = FileManager.default
        if let url = url {

            let path = "\(url.path)"
            let exist = fm.fileExists(atPath: path)
            if !exist {
                let zip = path + ".zip"
                let exist = fm.fileExists(atPath: zip)
                if exist {
                    guard let des = (URL(string: path)?.deletingLastPathComponent().absoluteString) else {
                        return false
                    }
                    
                    SSZipArchive.unzipFile(atPath: zip, toDestination: des, progressHandler: {(entry, zipinfo, entrynumber, total) in }, completionHandler: {  (path, success, error) in
                        print("解压完成：\(path)")
                        FILESManager.default.deleteFileAt(path: path)
                    })
                }
            }
        }*/
        
        return true
    }
    
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("\(#function)-error：\(error.localizedDescription)")
        Dismiss()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("\(#function)")
        
        Dismiss()
    }
    

    
    

}
