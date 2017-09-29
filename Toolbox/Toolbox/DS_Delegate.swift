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
            if !APP_IS_BACKGROUND{//全解压完成，可以更新
                DispatchQueue.main.async {[weak self] in
                    guard let strongSelf = self else{return}
                    if ktabbarVCIndex != 6{
                        RootControllerChangeWithIndex(6)
                    }
                    strongSelf._showAlert(withurl)
                }
            }
        }
    }
    
    func ds_hasCheckedUpdate() {
        if !DataSourceManager.default.unzipQueueIsEmpty().0{
            DataSourceManager.default.setValue(true, forKey: "ds_startupdating")
            let files = DataSourceManager.default.unzipQueueIsEmpty().1
            for url in files.keys {
                ds_downloadTotalFilesCompleted(url)
            }
        }else{
            print("NO NEED UPDATE")
            if !APP_IS_BACKGROUND && DataSourceManager.default.ds_checkupdatemanual{
                DispatchQueue.main.async {
                    HUD.show(info: "已是最新")
                    DataSourceManager.default.ds_checkupdatemanual = false
                }
            }
        }
        
    }
    

    func ds_checkoutFromDocument() {
        
    }
    
    
    
    //MARK:
    func _showAlert(_ withurl: String) {
        print("+++++++++++++ 全部解压完成，开始更新! +++++++++++++")
        let action_1 = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        let action_2 = UIAlertAction.init(title: "立即更新", style: .default, handler: { (action) in
            UNZIPFile.default.update(url:withurl)
        })
        
        let ac = UIAlertController.init(title: "提示", message: "文件解压已完成,是否安装更新?", preferredStyle: .alert)
        ac.addAction(action_1)
        ac.addAction(action_2)
        UIApplication.shared.keyWindow?.rootViewController?.present(ac, animated: false, completion: nil)
    }
    
    
    
}
