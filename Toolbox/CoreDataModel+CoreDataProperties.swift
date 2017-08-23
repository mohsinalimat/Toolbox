//
//  CoreDataModel+CoreDataProperties.swift
//  Toolbox
//
//  Created by gener on 17/8/22.
//  Copyright © 2017年 Light. All rights reserved.
//

import Foundation
import CoreData


extension CoreDataModel {

    public static var entityName: String! { return "CoreDataModel" } // Required
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataModel> {
        return NSFetchRequest<CoreDataModel>(entityName: "CoreDataModel");
    }

    @NSManaged public var book_id: String?
    @NSManaged public var content_location: String?
    @NSManaged public var effrg: String?
    @NSManaged public var has_content: String?
    @NSManaged public var is_leaf: String?
    @NSManaged public var is_visible: String?
    @NSManaged public var mime_type: String?
    @NSManaged public var nodeLevel: String?
    @NSManaged public var original_tag: String?
    @NSManaged public var parent_id: String?
    @NSManaged public var primary_id: String?
    @NSManaged public var revision_type: String?
    @NSManaged public var title: String?
    @NSManaged public var toc_code: String?
    @NSManaged public var toc_id: String?
    @NSManaged public var tocdisplayeff: String?

}
