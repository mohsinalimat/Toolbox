//
//  HomeVersionCell.swift
//  Toolbox
//
//  Created by gener on 2018/3/14.
//  Copyright © 2018年 Light. All rights reserved.
//

import UIKit

class HomeVersionCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var localVersion: UILabel!
    
    @IBOutlet weak var localData: UILabel!
    
    @IBOutlet weak var serverVersion: UILabel!
    
    @IBOutlet weak var serverDate: UILabel!
    
    @IBOutlet weak var right_version_ig: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
    func fillCell(server:[String:String])  {
        let pubid = _toString(server["publication_id"])
        let title = _toString(server["display_title"])
        let s_version = _toString(server["revision_number"])
        let s_date = _toString(server["revision_date"])
        
        name.text = title
        serverVersion.text = "Reversion Number = \(s_version)"
        serverDate.text = "Date = \(s_date)"
        
        if let m = PublicationVersionModel.searchSingle(withWhere: "publication_id='\(pubid)'", orderBy: nil) as? PublicationVersionModel {
            localVersion.text = "Reversion Number = \(m.revision_number!)";
            localData.text = "Date = \(m.revision_date!)"
            right_version_ig.image = UIImage (named: m.revision_number == s_version ? "icon_right":"icon_error")
        } else {
            localVersion.text = "-"
            localData.text = "-"
            right_version_ig.image = UIImage (named:"icon_error");
        }
        
//        let url = kDataSourceLocations[0]
//        let zip:String! = server["file_loc"]
//        let fileurl = url + "\(zip!)"
//        //updatedsQueueWith(key:url,filePath: fileurl,datatype:.download)
//        PublicationVersionModel.saveToDb(with: server)
        
        
    }
    
    
    func _update() {
        
        
    }
    
    func _toString(_ obj:Any?) -> String {
        if let o = obj {
            return "\(o)";
        }
        
        return " "
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
