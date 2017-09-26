//
//  DS_Delegate.swift
//  Toolbox
//
//  Created by gener on 17/9/22.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class DS_Delegate: NSObject, DSManagerDelegate {

    
    //MARK:- DSManagerDelegate
    func ds_downloadTotalFilesCompleted(_ withurl: String) {
        UNZIPFile.default.unzipWithCompleted(withurl:withurl) {
            //解压完成
            print("解压完成，下一步更新操作...")
        }
    }
    
    func ds_hasCheckedUpdate() {

        print("NO NEED UPDATE")
    }
    

}
