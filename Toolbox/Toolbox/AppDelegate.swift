
//  AppDelegate.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager = LocationManager.init();

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow (frame: UIScreen.main.bounds)

        //let tabBarController = BaseTabbarController()
        //window?.rootViewController = tabBarController

        let home = HomeViewController()
        let nav = BaseNavigationController(rootViewController:home)
        window?.rootViewController = nav
        
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()
        
        //初始化操作
        init_system()
        sleep(1)
        
        return true
    }

    //MARK:-
    private func init_system(){
        HUD.config()
        _setterConfig()
        
        //注册通知
        _initNotification()
        
        //位置定位
        locationManager.didUpDateLocatonHandler = { location in
            print("didUpdateLocations")
        }
        
        //..test

    }
    
    func _initNotification() {
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings.init(types: [.alert,.sound,.badge], categories: nil))
    }
    
    
   private func _setterConfig() {
        //获取系统设置
        let bundlepath:String = Bundle.main.path(forResource: "Settings", ofType: "bundle")!
        let rootDic = NSDictionary.init(contentsOfFile: bundlepath.appending("/Root.plist"))
        let rootPrefers:[[String:Any]] = rootDic?["PreferenceSpecifiers"] as! [[String : Any]]
        var newDic = [String:String]()
        for d in rootPrefers{
            let key = d["Key"] as? String
            if let key = key {
                newDic[key] = d["DefaultValue"] as? String
                UserDefaults.standard.setValue(d["DefaultValue"], forKey: key)
                UserDefaults.standard.synchronize()
            }
        }
        
        let infoDic = Bundle.main.infoDictionary
        if let info = infoDic {
            let appversion = info["CFBundleShortVersionString"]
            let buildno = info["CFBundleVersion"]
            newDic["app_version"] = "\(buildno!)_\(appversion!)"
            UserDefaults.standard.setValue("\(buildno!)_\(appversion!)", forKey: "app_version")
            UserDefaults.standard.synchronize()
        }
        UserDefaults.standard.register(defaults: newDic)
        
        //data source
        let dsDic = NSDictionary.init(contentsOfFile: bundlepath.appending("/DataSourceLocation.plist"))
        let dataprefers:[[String:Any]] = dsDic?["PreferenceSpecifiers"] as! [[String : Any]]
        for d in dataprefers{
            let key = d["Key"] as? String
            if let key = key {
                let str = UserDefaults.standard.value(forKey: key) as? String
                if var location = str {
                    if location.lengthOfBytes(using: .utf8) > 0 && location.hasPrefix("http://"){
                        print("Location:\(location)")
                        if !location.hasSuffix("/") {
                            location = location.appending("/CCA/")
                        }
                        if !kDataSourceLocations.contains(location){
                            kDataSourceLocations.append(location)
                        }
                    }
                }
            }
        }
    
        let arr = DataSourceModel.search(with: nil, orderBy: nil) as?[DataSourceModel]
        if let arr = arr{
            for m in arr{
                let url = m.location_url
                if !kDataSourceLocations.contains(url!){
                    m.deleteToDB()
                }
            }
        }
    
        //net check
        Tools.startNetMonitor()
        if Tools.isReachable() {
            print("connected network!")
        }
    
    }
    
    //PUBLIC METHOD
    func sendLocalNotification() {
        let local = UILocalNotification.init()
        local.alertBody = "准备更新"
        local.alertTitle = "解压完成，准备更新"
        local.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(local)
    }
 
    //MARK:
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print(#function)
        let ds_delegate = DS_Delegate.init()
        ds_delegate._showAlert("")
        
        let alert = UIAlertController.init(title: "Update Completed", message: nil, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        application.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(#function)
    }
    
    
    //MARK:
    func application(_ application: UIApplication, willChangeStatusBarFrame newStatusBarFrame: CGRect) {
        print("will change statueBar frame to  \(newStatusBarFrame) !")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print(#function)
        APP_IS_BACKGROUND = true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print(#function)
        APP_IS_BACKGROUND = false
        //checkupdate
        //DataSourceManager.default.ds_checkupdate()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print(#function)
        let tmp = NSTemporaryDirectory()
        do{
            let  files = try FileManager.default.contentsOfDirectory(atPath: tmp)
            for f in files{
                let path = tmp + f
                do{
                   try FileManager.default.removeItem(atPath: path)
                }catch{
                    print(error.localizedDescription)
                }
            }
        }catch{
            print(error.localizedDescription)
        }
        
    }


}

