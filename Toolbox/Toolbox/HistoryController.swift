//
//  HistoryController.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class HistoryController: BaseViewControllerWithTable {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableview?.frame = CGRect (x: 0, y:0, width: kCurrentScreenWidth, height: kCurrentScreenHight - 64 )
        tableview?.register(UINib(nibName: "BookmarksCell", bundle: nil), forCellReuseIdentifier: "BookmarksCellReuseIdentifier")
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataArray.removeAll()
        
        dataArray = dataArray + kseg_hasopened_arr
        
        tableview?.reloadData()
    }
    
    
    //MARK:
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard dataArray.count > 0 else {
            return 1
        }
        
        return section == 0 ? 1 :  dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if dataArray.count == 0 {
            return getCellForNodata(tableView, info: "No history data.")
        }
        
        let m = dataArray[indexPath.row] as! BookmarkModel
        
        let cell = tableview?.dequeueReusableCell(withIdentifier: "BookmarksCellReuseIdentifier", for: indexPath) as! BookmarksCell
        
        cell.fillCell(model: m)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let m = dataArray[indexPath.row] as! BookmarkModel
//        kseg_contentlocation_url = m.seg_content_location
        let segs = SegmentModel.search(with: "primary_id='\(m.seg_primary_id!)'", orderBy: nil)
        kSelectedSegment = segs?.first as? SegmentModel
        
        let bookid = m.pub_book_uuid
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
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return {
            let v = UIView (frame: CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: 30))
            v.backgroundColor = kTableviewHeadViewBgColor
            let title = UILabel (frame: CGRect (x: 0, y: 0, width: v.frame.width, height: 30))
            title.textColor = UIColor.white
            title.font = UIFont.boldSystemFont(ofSize: 18)
            title.text = "\t\t\(section == 0 ? "Opened Publications" :"Recent History")"
            
            v.addSubview(title)
            return v
            }()
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  30
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
