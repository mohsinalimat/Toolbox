//
//  CoreDataKit.swift
//  Toolbox
//
//  Created by gener on 17/8/21.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import CoreData

class CoreDataKit: NSObject {

    static let `default` = CoreDataKit()
    
    var manageredContext:NSManagedObjectContext!
    var manageredModel:NSManagedObjectModel!
    var persistentStoreCoordinator:NSPersistentStoreCoordinator!
    
    
    
    
    override init() {
        let modelUrl = Bundle.main.url(forResource: "Model", withExtension: "momd")
        manageredModel = NSManagedObjectModel.init(contentsOf: modelUrl!)
        
        //let sqlpath = ROOTPATH.appending("/Database/CoreData.sqlite")
        persistentStoreCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: manageredModel)
        do{
            //.appendingPathComponent("/TDLibrary/Database/CoreData.sqlite")
            var url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last
            url = url?.appendingPathComponent("CoreData.sqlite")
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            
            manageredContext = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
            manageredContext.persistentStoreCoordinator = persistentStoreCoordinator
        }catch{
            print("addPersistentStore-- : \(error.localizedDescription)")
        }
        
    
        //let batchUpdate = NSBatchUpdateRequest(entityName: "myEntityName")

        
    }
    
    
    func modelFrom(_ dic:[String:Any]) -> NSManagedObject{
        let m:CoreDataModel = NSEntityDescription.insertNewObject(forEntityName: "CoreDataModel", into: manageredContext) as!CoreDataModel
        
        var outCount:UInt32 = 0
        let list = class_copyPropertyList(CoreDataModel.self, &outCount);
        for i in 0..<outCount{
            let property = list?[Int(i)];
            let charname = property_getName(property);
            let name:String! = String (utf8String: charname!)
            m.setValue(dic[name], forKey: name)
        }
        
        free(list)
        
        return m
    }
    
    
    func insert(dic:[String:Any]) {
        let m:CoreDataModel = NSEntityDescription.insertNewObject(forEntityName: "CoreDataModel", into: manageredContext) as!CoreDataModel
        
        var outCount:UInt32 = 0
        let list = class_copyPropertyList(CoreDataModel.self, &outCount);
        for i in 0..<outCount{
            let property = list?[Int(i)];
            let charname = property_getName(property);
            let name:String! = String (utf8String: charname!)
            m.setValue(dic[name], forKey: name)
        }
        
        free(list)

        manageredContext.performAndWait {[weak self] in
            guard let strongSelf = self else{return}
            
            do{
                try strongSelf.manageredContext.save()
            }catch{
                print("manageredContext.save()-error : \(error.localizedDescription)")
            }
        }

        
    }
    
    
    
    
}
