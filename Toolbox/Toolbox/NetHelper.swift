//
//  NetHelper.swift
//  Toolbox
//
//  Created by gener on 17/8/30.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import Alamofire

class NetHelper: NSObject {

    
    func get() {
        
        Alamofire.request("https://httpbin.org/get").responseJSON { (response) in
            
        }
        
        
    }
    
    
    
}
