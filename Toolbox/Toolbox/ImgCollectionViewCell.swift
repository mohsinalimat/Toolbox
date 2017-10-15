//
//  ImgCollectionViewCell.swift
//  Toolbox
//
//  Created by gener on 17/10/12.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
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
        _imgwebview.backgroundColor = UIColor.white
        _imgwebview.scrollView.isUserInteractionEnabled = false
        _imgwebview.addGestureRecognizer(_imgwebview.scrollView.pinchGestureRecognizer!)
    }
    
    func fillCellWith(_ model:SegmentModel) {
        guard var urlStr = Tools.default.getFilePath(model.content_location) else{return}
        
        //Loading()
        urlStr =  urlStr.replacingOccurrences(of: " ", with: "%20")
        let key:String = "cec"
        let value:String! = kSelectedAirplane?.value(forKey: "customerEffectivity") as! String
        let newurl = urlStr.appending("?airplane=\(value!)&idType=\(key)")
        _imgwebview.loadRequest(URLRequest.init(url: URL.init(string: newurl)!))        
    }
    
    
    //MARK:- UIWebViewDelegate
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("\(#function)-error：\(error.localizedDescription)")
        Dismiss()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        Dismiss()
    }
 

}
