//
//  ViewMainController.swift
//  Toolbox
//
//  Created by gener on 17/10/11.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class ViewMainController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let vc = ViewerController()
        self.addChildViewController(vc)
        view.addSubview(vc.view)
    }

    
    
    
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
