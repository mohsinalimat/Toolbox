//
//  TOCViewController.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//  Table Of Content 章节目录

import UIKit

let kSegmentCellIdentifier = "SegmentCellIdentifier"
let kPublicationCellReuseIdentifier = "PublicationCellReuseIdentifier"

class TOCViewController: BaseViewControllerWithTable {

    var currentPublication:PublicationsModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataArray = [1,2,3,4,5,6]
        
        let s = dataArray.index(after: 3)
        
        dataArray.removeSubrange(s..<dataArray.endIndex)
        
    }

    func loadData() {
        //数据可能为空
        guard let selectedPublication = kSelectedPublication else {
            return
        }
        guard currentPublication !== selectedPublication  else {
            return
        }

        currentPublication = selectedPublication
        
        dataArray.removeAll()
        dataArray.append(currentPublication)
        //CCAA320CCAAIPC20161101
       let chapter = SegmentModel.search(with: "parent_id='\(currentPublication.book_uuid!)'", orderBy: "toc_code asc")
        
        dataArray = dataArray + chapter!
        
        tableview?.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        super.viewWillAppear(animated)
    }
    
    
    override func initSubview(){
        tableview?.frame = CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: kCurrentScreenHight - 64)
        tableview?.register(UINib(nibName: "PublicationCell", bundle: nil), forCellReuseIdentifier: kPublicationCellReuseIdentifier)
        tableview?.register(UINib (nibName: "SegmentCell", bundle: nil), forCellReuseIdentifier: kSegmentCellIdentifier)

    }
    
    
    
    
    //MARK:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableview?.dequeueReusableCell(withIdentifier: kPublicationCellReuseIdentifier, for: indexPath) as! PublicationCell
            let model = dataArray[0] as! PublicationsModel
            cell.fillCell(model: model)
            return cell
        }
        else{
            let cell = tableview?.dequeueReusableCell(withIdentifier: kSegmentCellIdentifier, for: indexPath) as! SegmentCell
            let model = dataArray[indexPath.row] as! SegmentModel
        
            cell.fillCell(model: model)
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //判断目录层级
        
        
//        jumptoNextWithIndex(3)
    }
    
    
    
    
    
  
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
