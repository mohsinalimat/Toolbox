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
    
    var activity:UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        _cellInit()
        
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
        
        //_initActivityView()
        
        urlStr =  urlStr.replacingOccurrences(of: " ", with: "%20")
        /*let key:String = "cec"
        let value:String! = kSelectedAirplane?.value(forKey: "customerEffectivity") as! String
        let newurl = urlStr.appending("?airplane=\(value!)&idType=\(key)")*/
        imgwebView.loadRequest(URLRequest.init(url: URL.init(string: urlStr)!))
        
    }
    
    func _initActivityView() {
        activity = UIActivityIndicatorView.init(frame: CGRect (x: 0, y: 0, width: 50, height: 50))
        activity.center = CGPoint (x: (self.frame.width - activity.frame.width) / 2, y: (self.frame.height - activity.frame.width)/2)
        activity.activityIndicatorViewStyle = .gray
        activity.hidesWhenStopped = true
        self.addSubview(activity)
        
        activity.startAnimating()
    }
    
    
    override func prepareForReuse() {
        //imgwebView.isHidden = true
        
        _cellInit()
    }

    
    func _isSelected(_ selected:Bool = false) {
        if selected {
            self.layer.borderWidth = 5
            self.layer.borderColor = kTableview_headView_bgColor.cgColor
        }else{
            _cellInit()
        }
    }

    func _cellInit() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
    }

    
    //MARK:- UIWebViewDelegate
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        dismiss()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        dismiss();
    }

    
    func dismiss() {
        if imgwebView.isHidden {
            imgwebView.isHidden = false
        }
        
        activity.stopAnimating()
    }
}
