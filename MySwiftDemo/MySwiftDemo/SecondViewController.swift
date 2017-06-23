//
//  SecondViewController.swift
//  MySwiftDemo
//
//  Created by gener on 17/6/13.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

import Alamofire

class SecondViewController: BaseViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        test()
    }

    
    
    func test() -> Void {
        
        Alamofire
            .request("http://192.168.6.54:80/Test/testforswift.php",method:.get,parameters:["number":1001,"name":"xiaoming"],encoding:URLEncoding.default)
            .responseJSON
            {
                response in
                print(response.request)  // original URL request
//                print(response.response) // HTTP URL response
//                print(response.data)     // server data
                print(response.result)   // result of response serialization
 
                if let value = response.result.value {
                    let arr = value as? [String:Any]
                  
                    for (key,value) in arr! {
                        debugPrint("\(key) : \(value)");
                    }


                    
//                    do{
//                    let json = try JSONSerialization.jsonObject(with: Data.init(bytes: [1,2,3]), options: JSONSerialization.ReadingOptions.allowFragments)
//                        
//                    }
//                    catch{
//                    
//                    }
                }
        }
    }
    
    
 }
