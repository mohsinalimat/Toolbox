//
//  MeTableViewController.swift
//  MySwiftDemo
//
//  Created by gener on 17/6/8.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class MeViewController: BaseVCWithListController {
    
    //    var dataArray:NSArray = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //
        itemTitle = "我的"
        
        let textAttributes = [NSFontAttributeName:UIFont.systemFont(ofSize: 16),NSForegroundColorAttributeName:UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.isTranslucent = true
        
        self.navigationController?.navigationBar.setBackgroundImage(imageWithColor(UIColor.white.withAlphaComponent(0)), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //        let rightItem = UIBarButtonItem (title: "设置", style: .plain, target: self, action: nil)
        //         self.navigationItem.rightBarButtonItem = rightItem
        
        let itembutton = UIButton (frame: CGRect (x: 0, y: 0, width: 20, height: 20))
        itembutton.setBackgroundImage(UIImage (named: "icon_request_settings"), for: UIControlState.normal)
        
        let item2 = UIBarButtonItem (customView: itembutton)
        navigationItem.rightBarButtonItems = [item2]
        
        initSubviews()
        dataArray = UIFont.familyNames
        dataArray = Array(repeating: "导航栏渐变", count: 15)
    }
    
    func click()
    {
        print("click");
    }
    
    
    func initSubviews()
    {
        _tableView = UITableView (frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 50 - 0), style: .grouped)
        _tableView.delegate = self
        _tableView.dataSource = self
        
        view .addSubview(_tableView)//cellID
        _tableView .register(UINib.init(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: "cellID")
        
        _tableView.showsVerticalScrollIndicator = true
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    
   override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let _v = UIView(frame: CGRect (x: 0, y: 0, width: SCREEN_WIDTH, height: 64))
        _v.backgroundColor = UIColor.orange
        
        return _v
    }
    
    
    
}
