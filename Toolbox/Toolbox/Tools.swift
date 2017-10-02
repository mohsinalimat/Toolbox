//
//  Tools.swift
//  Toolbox
//
//  Created by wyg on 2017/10/2.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class Tools: NSObject {

    static let `default` = Tools.init()
    let _reach:Reachability
    
    override init() {
        _reach = Reachability(hostName: "www.baidu.com")
    }
    
    //MARK: - Net Reachable
    static func startNetMonitor() {
       Tools.default._reach.startNotifier()
    }
    
    class func isReachable() -> Bool {
        return NotReachable != Tools.default._reach.currentReachabilityStatus()
    }
    
    
    
    
    
    
    
}
