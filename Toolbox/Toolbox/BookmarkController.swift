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

        // Do any additional setup after loading the view.
        
        tableview?.frame = CGRect (x: 0, y:0, width: kCurrentScreenWidth, height: kCurrentScreenHight - 64 )
        tableview?.register(UINib(nibName: "BookmarksCell", bundle: nil), forCellReuseIdentifier: "BookmarksCellReuseIdentifier")
        
        //....统计文档数量
        sectionHeadtitle =  "Bookmarks"
        
        //...test data
        dataArray = dataArray + ["1","2","3","4"]
        
    }

    
    
    //MARK:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview?.dequeueReusableCell(withIdentifier: "BookmarksCellReuseIdentifier", for: indexPath) as! BookmarksCell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
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
