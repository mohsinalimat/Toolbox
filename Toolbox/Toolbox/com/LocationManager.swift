//
//  LocationManager.swift
//  MDM Agent
//
//  Created by gener on 2017/12/15.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject ,CLLocationManagerDelegate {

    static let `default` = LocationManager()
    let _locationManager = CLLocationManager.init();
    
    var didUpDateLocatonHandler:((CLLocation) -> Void)?
    
    var _shouldUpdate:Bool = false
    
    func startUpdateLocation() {
        _shouldUpdate = true
        _locationManager.startUpdatingLocation()
    }
    
    func stopUpdateLocation() {
        _locationManager.stopUpdatingLocation()
    }
    
    
    
    override init() {
        super.init()
        
        _initLocationServices()
    }
    
    
    //MARK: -
    //开启定位
    func _initLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .denied {
                let vc = UIAlertController.init(title: nil, message: nil, preferredStyle: .alert)
                let action1 = UIAlertAction.init(title: "取消", style: .default, handler: nil)
                vc.title = "请在设置-定位中允许访问位置信息"
                let action2 = UIAlertAction.init(title: "去设置", style: .default, handler: { (action) in
                    let url = URL.init(string: UIApplicationOpenSettingsURLString);
                    if  UIApplication.shared.canOpenURL(url!){
                        UIApplication.shared.openURL(url!)
                    }
                })
                
                vc.addAction(action1)
                vc.addAction(action2)
                UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil);
                return
            }
            
            _locationManager.delegate  = self
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest
            _locationManager.distanceFilter = kCLLocationAccuracyBest
            _locationManager.pausesLocationUpdatesAutomatically = false

            if #available(iOS 9.0, *) {
                _locationManager.allowsBackgroundLocationUpdates = true
                
            } else {
                // Fallback on earlier versions
            }
            
            _locationManager.requestAlwaysAuthorization();
            _locationManager.startUpdatingLocation()
        }else{
            let vc = UIAlertController.init(title: nil, message: nil, preferredStyle: .alert)
            let action1 = UIAlertAction.init(title: "取消", style: .default, handler: nil)
            vc.title = "请在系统设置中开启定位功能"
            let action2 = UIAlertAction.init(title: "去设置", style: .default, handler: { (action) in
                let url = URL.init(string: "prefs:root=LOCATION_SERVICES");
                if  UIApplication.shared.canOpenURL(url!){
                    UIApplication.shared.openURL(url!)
                }
            })
            
            vc.addAction(action1)
            vc.addAction(action2)
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil);
        }
        
    }
    
    
    //MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if _shouldUpdate {
            if let location = locations.last {
                _shouldUpdate = false
                            
                if let handler = didUpDateLocatonHandler {
                    handler(location);
                    
                }
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            break
        case .notDetermined:
            print("notDetermined")
            break
        case .restricted :
            print("restricted")
            break
        default:break
        }
    }
    
    
}
