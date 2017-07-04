//
//  ViewerController.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class ViewerController: BaseViewControllerWithTable {

    override func viewDidLoad() {
        super.viewDidLoad()


        let url = Bundle.main.path(forResource: "11-00-00-01B", ofType: "html")
        let webview = UIWebView.init(frame:  CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: kCurrentScreenHight - 64 - 49))
        webview.loadRequest(URLRequest.init(url: URL.init(string: url!)!))
        view.addSubview(webview)
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
