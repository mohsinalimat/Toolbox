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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        

    }

    func loadData() {
        //数据可能为空
        guard let selectedAirplane = kSelectedAirplane else {
            return
        }
        
        let msn:String = selectedAirplane.airplaneSerialNumber
        let books = kAirplanePublications[msn]
        
        
    }
    
    override func initSubview(){

        let searchBar = UISearchBar (frame: CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: 44))
        searchBar.barStyle = UIBarStyle.default
        searchBar.searchBarStyle = UISearchBarStyle.minimal
        
        searchBar.placeholder = "Search"
        
        
        view.addSubview(searchBar)
        
        tableview?.frame = CGRect (x: 0, y: searchBar.frame.maxY, width: kCurrentScreenWidth, height: kCurrentScreenHight - 64 - searchBar.frame.height)
        tableview?.register(UINib(nibName: "PublicationCell", bundle: nil), forCellReuseIdentifier: "PublicationCellReuseIdentifier")
        
        //....统计文档数量
        sectionHeadtitle =  "Publications"
        
        //...test data
        dataArray = dataArray + ["1","2","3","4"]
    }
    
    
    
    //MARK: 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview?.dequeueReusableCell(withIdentifier: "PublicationCellReuseIdentifier", for: indexPath) as! PublicationCell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        jumptoNextWithIndex(2)
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
