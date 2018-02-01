//
//  DS_Delegate.swift
//  Toolbox
//
//  Created by gener on 17/9/22.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class DS_Delegate: NSObject, DSManagerDelegate {
    
    var unzipfile_arr = [String]()
    
    //MARK:- DSManagerDelegate
    func ds_startUnzipFile(_ withurl: String) {
        guard !unzipfile_arr.contains(withurl) else{return}
        unzipfile_arr.append(withurl)
        
        //开始更新位置
        let app = UIApplication.shared.delegate as? AppDelegate
        app?.locationManager.startUpdateLocation()
        
        UNZIPFile.default.unzipWithCompleted(withurl:withurl) {
            if !APP_IS_BACKGROUND{//全解压完成，可以更新
                DispatchQueue.main.async {[weak self] in
                    guard let strongSelf = self else{return}
                    if ktabbarVCIndex != 6{
                        RootControllerChangeWithIndex(6)
                    }
                    
                    UserDefaults.standard.set(true, forKey: "user_should_show_alert_update")
                    UserDefaults.standard.synchronize()
                    strongSelf._showAlert(withurl)
                }
            }else{//处于后台通知提醒
                UserDefaults.standard.set(true, forKey: "user_should_show_alert_update")
                UserDefaults.standard.synchronize()
                let appdelegate =  UIApplication.shared.delegate as? AppDelegate
                appdelegate?.sendLocalNotification()
            
            }
        }
    }
    
    func ds_hasCheckedUpdate(_ shouldHud:Bool = true) {
        if !DataSourceManager.default.unzipQueueIsEmpty().0{
            DataSourceManager.default.setValue(true, forKey: "ds_startupdating")
            let files = DataSourceManager.default.unzipQueueIsEmpty().1
            for url in files.keys {
                if url.hasPrefix("http"){
                        ds_startUnzipFile(url)
                }
            }
        }else{
            print("NO NEED UPDATE")
            if !APP_IS_BACKGROUND && DataSourceManager.default.ds_checkupdatemanual && shouldHud {
                DispatchQueue.main.async {
                    HUD.show(info: "已是最新")
                    DataSourceManager.default.ds_checkupdatemanual = false
                }
            }
        }
        
    }
    

    func ds_checkoutFromDocument() {
        if !DataSourceManager.default.unzipQueueIsEmpty().0{
            let files = DataSourceManager.default.unzipQueueIsEmpty().1
            for url in files.keys {
                if !url.hasPrefix("http"){
                    DataSourceManager.default.setValue(true, forKey: "ds_startupdating")
                    ds_startUnzipFile(url);return
                }
            }
        }
    }
    
    
    
    //MARK:
    func _showAlert(_ withurl: String) {
        print("+++++++++++++ 全部解压完成，开始更新! +++++++++++++")
        unzipfile_arr.removeAll()
        let action_1 = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        let action_2 = UIAlertAction.init(title: "立即更新", style: .default, handler: { (action) in
            UNZIPFile.default.update(url:withurl)
        })
        
        let ac = UIAlertController.init(title: "提示", message: "文件解压已完成,是否安装更新?", preferredStyle: .alert)
        ac.addAction(action_1)
        ac.addAction(action_2)
        UIApplication.shared.keyWindow?.rootViewController?.present(ac, animated: false, completion: nil)
    }
    
    //更新完成后状态处理
    static func _updateCompletionHandler()  {
        UIApplication.shared.isIdleTimerDisabled = false
        
        DataSourceManager.default.setValue(false, forKey: "ds_startupdating")//更新DS状态
        
        UserDefaults.standard.removeObject(forKey: "user_should_show_alert_update")
        
        //停止更新位置
        let app = UIApplication.shared.delegate as? AppDelegate
        app?.locationManager.stopUpdateLocation()
    }
    
    
    
}
