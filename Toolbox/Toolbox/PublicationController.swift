//
//  PublicationController.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class PublicationController: BaseViewControllerWithTable ,UISearchBarDelegate{

    var selectButton : UIButton?
    var currentAirplaneModel:AirplaneModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        NotificationCenter.default.addObserver(self, selector: #selector(recnotification(_ :)), name: knotification_airplane_changed, object: nil)
        
    }

    func recnotification(_ noti:Notification)  {
        currentAirplaneModel = nil
        kSelectedPublication = nil
    }
    

    
    func loadData(_ key:String? = nil) {
        //数据可能为空
        guard let selectedAirplane = kSelectedAirplane else {
            dataArray.removeAll()
            tableview?.reloadData()
            return
        }
        /*guard currentAirplaneModel !== selectedAirplane  else {
            return
        }*/
        
        currentAirplaneModel = selectedAirplane
        
        let msn:String = currentAirplaneModel.airplaneSerialNumber
        /*
        let books:[String:String] = kAllPublications[msn] as! [String : String]
        let sorted =  books.sorted { (s1, s2) -> Bool in
            return s1 < s2
        }
        */
        
        let bookArr = APMMap.search(withSql: "select bookid from APMMAP where msn = '\(msn)' order by bookid asc") as! [APMMap]
        var sql = "("
        for (value) in bookArr {
           sql =  sql.appending("'\(value.bookid!)',")
        }
        
        sql.remove(at: sql.index(before: sql.endIndex))
        sql = sql.appending(")")
        
        var str = "book_uuid in \(sql)"
        if let key = key {
            if key.lengthOfBytes(using: String.Encoding.utf8) > 0{
                str = "book_uuid in \(sql) and display_title like '%\(key)%'"
            }
        }
        let m =  PublicationsModel.search(with: str, orderBy: nil)
        dataArray.removeAll()
        dataArray = dataArray + m!
        tableview?.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    
    override func initSubview(){
        let searchBar = UISearchBar (frame: CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: 44))
        searchBar.barStyle = UIBarStyle.default
        searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.returnKeyType = .search
        view.addSubview(searchBar)
        
        tableview?.frame = CGRect (x: 0, y: searchBar.frame.maxY, width: kCurrentScreenWidth, height: kCurrentScreenHeight - 64 - searchBar.frame.height)
        tableview?.register(UINib(nibName: "PublicationCell", bundle: nil), forCellReuseIdentifier: "PublicationCellReuseIdentifier")
        sectionHeadtitle =  "Publications"
    }
    
    //MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard (currentAirplaneModel != nil) else {return}
        guard let msn:String = currentAirplaneModel.airplaneSerialNumber else {return}
        let bookArr = APMMap.search(withSql: "select bookid from APMMAP where msn = '\(msn)' order by bookid asc") as! [APMMap]
        var sql = "("
        for (value) in bookArr {
            sql =  sql.appending("'\(value.bookid!)',")
        }
        
        sql.remove(at: sql.index(before: sql.endIndex))
        sql = sql.appending(")")
        
        var str = "book_uuid in \(sql)"
        if let key = searchBar.text {
            if key.lengthOfBytes(using: String.Encoding.utf8) > 0{
                str = "book_uuid in \(sql) and display_title like '%\(key.uppercased())%'"
            }
        }
        let m =  PublicationsModel.search(with: str, orderBy: nil)
        dataArray.removeAll()
        dataArray = dataArray + m!
        tableview?.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    //MARK: 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataArray.count == 0 {
            return getCellForNodata(tableView, info: "NO AIRPLANE SELECTED")
        }
        
        let cell = tableview?.dequeueReusableCell(withIdentifier: "PublicationCellReuseIdentifier", for: indexPath) as! PublicationCell
        let model : PublicationsModel! = dataArray[indexPath.row] as! PublicationsModel
        cell.fillCell(model: model)
        if let kSelectedPublication = kSelectedPublication{
            let select = kSelectedPublication.book_uuid == model.book_uuid
            cell.isSelected(select)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableview?.cellForRow(at: indexPath) as! PublicationCell
        cell.isSelected(true)
        
        let model : PublicationsModel! = dataArray[indexPath.row] as! PublicationsModel
        kSelectedPublication = model
        ////

        kseg_direction = 1
        NotificationCenter.default.post(name: knotification_publication_changed, object: nil)
        
        tableview?.reloadData()
        RootControllerChangeWithIndex(2)
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
