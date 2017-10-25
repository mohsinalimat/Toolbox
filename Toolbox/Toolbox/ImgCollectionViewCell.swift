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
    
    var activity:UIActivityIndicatorView!
    
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

        _initActivityView()
        urlStr =  urlStr.replacingOccurrences(of: " ", with: "%20")
        _imgwebview.loadRequest(URLRequest.init(url: URL.init(string: urlStr)!))
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
        _imgwebview.isHidden = true
    }
    
    //MARK:- UIWebViewDelegate
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        dismiss()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        dismiss();
    }
 
    func dismiss() {
        if _imgwebview.isHidden {
            _imgwebview.isHidden = false
        }
        
        activity.stopAnimating()
    }
}
