//
//  PublicationController.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class PublicationController: BaseViewControllerWithTable {

    var selectButton : UIButton?
    var currentAirplaneModel:AirplaneModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }

    func loadData() {
        //数据可能为空
        guard let selectedAirplane = kSelectedAirplane else {
            return
        }
        guard currentAirplaneModel !== selectedAirplane  else {
            return
        }
        
        currentAirplaneModel = selectedAirplane
        
        let msn:String = currentAirplaneModel.airplaneSerialNumber
        let books:[String:String] = kAllPublications[msn] as! [String : String]
        let sorted =  books.sorted { (s1, s2) -> Bool in
            return s1 < s2
        }
        var sql = "("
        for (_,value) in sorted {
           sql =  sql.appending("'\(value)',")
        }
        
        sql.remove(at: sql.index(before: sql.endIndex))
        sql = sql.appending(")")
        
        let m =  PublicationsModel.search(with: "book_uuid in \(sql)", orderBy: nil)
        dataArray.removeAll()
        dataArray = dataArray + m!
        
        tableview?.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        super.viewWillAppear(animated)
    }
    
    
    override func initSubview(){
        let searchBar = UISearchBar (frame: CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: 44))
        searchBar.barStyle = UIBarStyle.default
        searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchBar.placeholder = "Search"
        view.addSubview(searchBar)
        
        tableview?.frame = CGRect (x: 0, y: searchBar.frame.maxY, width: kCurrentScreenWidth, height: kCurrentScreenHight - 64 - searchBar.frame.height)
        tableview?.register(UINib(nibName: "PublicationCell", bundle: nil), forCellReuseIdentifier: "PublicationCellReuseIdentifier")
        sectionHeadtitle =  "Publications"
    }
    
    
    
    //MARK: 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview?.dequeueReusableCell(withIdentifier: "PublicationCellReuseIdentifier", for: indexPath) as! PublicationCell
        let model : PublicationsModel! = dataArray[indexPath.row] as! PublicationsModel
        cell.fillCell(model: model)
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableview?.cellForRow(at: indexPath) as! PublicationCell
        cell.setSelected(true, animated: true)
        
        let model : PublicationsModel! = dataArray[indexPath.row] as! PublicationsModel
        kSelectedPublication = model
        ////
        kpub_booklocal_url = model.booklocalurl
        
        kseg_direction = 1
        
        RootControllerChangeWithIndex(2)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableview?.cellForRow(at: indexPath) as! PublicationCell
        cell.setSelected(false, animated: true)
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
