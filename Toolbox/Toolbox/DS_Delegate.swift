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
    ///执行解压操作
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
    
    //MARK: - 删除操作
    ///删除已安装的手册
    func ds_deleteBooksWithId(_ uids:[String]) {
        guard uids.count > 0 else { return}
        
        //未考虑删除人为中断的情况????
        for uid in uids {
            if let pub = PublicationsModel.searchSingle(withWhere: "book_uuid='\(uid)'", orderBy: nil) as? PublicationsModel{
                guard let doc_owner = pub.customer_code else{return}
                print("start delete \(uid) - \(Date())")
                UNZIPFile.default.deleteApModelMap(with: uid)
                
                //delete Publication
                pub.deleteToDB()
                
                //delete PublicationVersionModel
                PublicationVersionModel.delete(with: "book_uuid='\(uid)'")
                
                //SegmentModel
                SegmentModel.delete(with: "book_id='\(uid)'")
                
                //APMMap,Airplane
                let mapArr = APMMap.search(with: "bookid='\(uid)'", orderBy: nil)as! [APMMap]
                for map in mapArr{
                    let msn = map.msn
                    let msnArr = APMMap.search(with: "msn='\(msn!)'", orderBy: nil) as![APMMap]
                    if msnArr.count == 1{
                        AirplaneModel.delete(with: "airplaneSerialNumber='\(msn!)'")
                    }
                    map.deleteToDB()
                }
                
                
                //bookmark
                if BookmarkModel.isExistTable() {
                    BookmarkModel.delete(with: "pub_book_uuid='\(uid)'")
                }
                
                //delete files in Library
                let path = ROOTPATH.appending("/\(doc_owner)/\(uid)")
                FILESManager.default.deleteFileAt(path: path)
                print("end  delete \(uid) - \(Date())")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name (rawValue: "kNotification_book_update_complete"), object: nil, userInfo: nil)
                    NotificationCenter.default.post(name: knotification_publication_changed, object: nil)
                }
            }
            
        }
        
        kSelectedAirplane = nil
        kSelectedPublication = nil
        kSelectedSegment = nil
        kseg_hasopened_arr.removeAll()

    }
    
    
    ///删除未安装的手册数据
    func ds_deleteBooksWillInstall(_ uids:[String]) {
        guard uids.count > 0 else { return}
        for uid in uids {
            if let pub = InstallLaterModel.searchSingle(withWhere: "book_uuid='\(uid)'", orderBy: nil) as? InstallLaterModel {
                
                //delete Publication
                pub.deleteToDB()
                
                //delete PublicationVersionModel
                let pid = pub.publication_id
                PublicationVersionModel.delete(with: "publication_id='\(pid!)'")
                
                //恢复数据源状态
                let ds = pub.data_source
                DataSourceManager.default._update_ds_status(url: ds!, key: "update_status", value: DSStatus.completed.rawValue)
                
                
                //delete files in Library
                let file_loc = pub.file_loc
                let path = ROOTPATH.appending("/tmp/\(file_loc!)")
                FILESManager.default.deleteFileAt(path: path)
                print("end  delete \(uid) - \(Date())")
                
                
                DataSourceManager.default.setValue(false, forKey: "ds_startupdating")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name (rawValue: "kNotification_book_update_complete"), object: nil, userInfo: nil)
                }
                
            }
            
        }
        
    }
    
    
    //MARK: - 外部调用方法
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
