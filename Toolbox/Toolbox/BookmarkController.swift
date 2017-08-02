//
//  BookmarkController.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class BookmarkController: BaseViewControllerWithTable {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableview?.frame = CGRect (x: 0, y:0, width: kCurrentScreenWidth, height: kCurrentScreenHight - 64 )
        tableview?.register(UINib(nibName: "BookmarksCell", bundle: nil), forCellReuseIdentifier: "BookmarksCellReuseIdentifier")
        headNumShouldChange = true

        sectionHeadtitle = "Bookmarks"
    }

    override func viewWillAppear(_ animated: Bool) {
        
        dataArray.removeAll()
        HUD.show(withStatus: "Loading...")
        if let arr = BookmarkModel.search(with: nil, orderBy: nil)
        {
            dataArray = dataArray + arr
        }
        
        tableview?.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            HUD.dismiss()
        }
        
        super.viewWillAppear(animated)
    }
    
    //MARK:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview?.dequeueReusableCell(withIdentifier: "BookmarksCellReuseIdentifier", for: indexPath) as! BookmarksCell
        let m = dataArray[indexPath.row] as! BookmarkModel
        cell.fillCell(model: m)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let m = dataArray[indexPath.row] as! BookmarkModel
        kseg_contentlocation_url = m.seg_content_location
        kseg_primary_id = m.seg_primary_id
        let segs = SegmentModel.search(with: "primary_id='\(kseg_primary_id!)'", orderBy: nil)
        kSelectedSegment = segs?.first as? SegmentModel
        
        let bookid = m.pub_book_uuid
        kpub_booklocal_url = m.pub_booklocalurl
        let books = PublicationsModel.search(with: "book_uuid='\(bookid!)'", orderBy: nil)
        kSelectedPublication = books?.first as? PublicationsModel
        
        let airid = m.airplaneId
        let airs = AirplaneModel.search(with: "airplaneId='\(airid!)'", orderBy: nil)
        kSelectedAirplane = airs?.first as? AirplaneModel
        kseg_parentnode_arr.removeAll()
        
        if let str = m.seg_parents {
            let data = Data.init(base64Encoded: str)
            do{
                let arr = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String]
                
                var sql = "("
                for value in arr {
                    sql =  sql.appending("'\(value)',")
                }
                sql.remove(at: sql.index(before: sql.endIndex))
                sql = sql.appending(")")
                
                let s = SegmentModel.search(with: "primary_id in \(sql)", orderBy: nil)
                kseg_parentnode_arr = s as! [SegmentModel]
            }catch{
                print(error)
            }
        }
        
        kseg_direction = 2
        RootControllerChangeWithIndex(3)
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
       let m = dataArray[indexPath.row] as! BookmarkModel
       let seg_id = m.seg_primary_id
        
        if editingStyle == .delete {
            let ret = BookmarkModel.delete(with: "seg_primary_id='\(seg_id!)'")
            if ret {
                print("delete success")
            }
            dataArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.top)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
