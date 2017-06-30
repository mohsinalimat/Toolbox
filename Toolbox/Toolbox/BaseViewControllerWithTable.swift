//
//  BaseViewControllerWithTable.swift
//  Toolbox
//
//  Created by gener on 17/6/28.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class BaseViewControllerWithTable: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    var tableview:UITableView?
    var dataArray = [Any]()
    var sectionHeadtitle:String?
    
    var cellSelectedAction:((Int) -> (Void))?
    var cellSelectedIndex : Int?

    private var headSectionHeight = 30.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableview = UITableView (frame: CGRect (x: 0, y: 0, width: 0, height: 0), style: .plain)
        tableview?.delegate = self
        tableview?.dataSource = self
        tableview?.backgroundColor = kTableviewBackgroundColor
        tableview?.separatorStyle = .none
        tableview?.tableFooterView = UIView()
        view.addSubview(tableview!)
        
        initSubview();
    }

    public func initSubview(){
    
    }
    
    //MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil
        {
            cell = UITableViewCell (style: .default, reuseIdentifier: "reuseIdentifier")
            cell?.textLabel?.textColor = UIColor.darkGray
        }
        
        if indexPath.row == cellSelectedIndex {
            cell?.accessoryType = .checkmark
        }
        
        cell?.textLabel?.text = dataArray[indexPath.row] as? String
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return {
            let v = UIView (frame: CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: 30))
            v.backgroundColor = kTableviewHeadViewBgColor
            let title = UILabel (frame: CGRect (x: 0, y: 0, width: v.frame.width, height: 30))
            title.textColor = UIColor.white
            title.font = UIFont.boldSystemFont(ofSize: 18)
            title.text = sectionHeadtitle
            
            v.addSubview(title)
            return v
            }()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 44;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(sectionHeadtitle != nil ? headSectionHeight : 0.0)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tmp = cellSelectedAction {
            tmp(indexPath.row)
            
            self.dismiss(animated: true, completion: nil)
        }
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
