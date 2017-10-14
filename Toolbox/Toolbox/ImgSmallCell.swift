//
//  ImgSmallCell.swift
//  Toolbox
//
//  Created by gener on 17/10/13.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import SSZipArchive
class ImgSmallCell: UICollectionViewCell {

    @IBOutlet weak var imgwebView: UIWebView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        imgwebView.scrollView.showsHorizontalScrollIndicator = false
        imgwebView.scrollView.showsVerticalScrollIndicator = false
        imgwebView.scrollView.bounces = false
        imgwebView.backgroundColor = UIColor.white
        imgwebView.scrollView.minimumZoomScale = 0.1
        imgwebView.scrollView.zoomScale = 0.5
        imgwebView.scrollView.isUserInteractionEnabled = false
    }
    
    
    func fillCellWith(_ model:SegmentModel) {
        guard var urlStr = Tools.default.getFilePath(model.content_location) else{return}
        
        //Loading()
        urlStr =  urlStr.replacingOccurrences(of: " ", with: "%20")
        let key:String = "cec"
        let value:String! = kSelectedAirplane?.value(forKey: "customerEffectivity") as! String
        let newurl = urlStr.appending("?airplane=\(value!)&idType=\(key)")
        imgwebView.loadRequest(URLRequest.init(url: URL.init(string: newurl)!))
        
    }
    
    func _isSelected() {
        self.layer.borderWidth = 5
        self.layer.borderColor = kTableview_headView_bgColor.cgColor
    }

    override func prepareForReuse() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
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
