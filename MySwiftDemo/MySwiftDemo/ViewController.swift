//
//  ViewController.swift
//  MySwiftDemo
//
//  Created by gener on 16/11/21.
//  Copyright © 2016年 Light. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    var dataArray:NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let textAttributes = [NSFontAttributeName:UIFont.systemFont(ofSize: 16),NSForegroundColorAttributeName:UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.isTranslucent = true
        
         self.navigationController?.navigationBar.setBackgroundImage(imageWithColor(color: UIColor.white.withAlphaComponent(0)), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage.init()
        
//        let rightItem = UIBarButtonItem (title: "设置", style: .plain, target: self, action: nil)
//         self.navigationItem.rightBarButtonItem = rightItem
        
        let itembutton = UIButton (frame: CGRect (x: 0, y: 0, width: 20, height: 20))
        itembutton.setBackgroundImage(UIImage (named: "icon_request_settings"), for: UIControlState.normal)
        
        let item2 = UIBarButtonItem (customView: itembutton)
        navigationItem.rightBarButtonItems = [item2]
        
        initSubviews()
        dataArray = UIFont.familyNames as NSArray
        
    }

    func click()
    {
        print("click");
    }
    
    func imageWithColor(color:UIColor) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        UIGraphicsBeginImageContext(rect.size)
        
        let content = UIGraphicsGetCurrentContext()
        
        content?.setFillColor(color.cgColor)
        
        content?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
        
    }
    
    
    func initSubviews()
    {
        let tableview = UITableView (frame: CGRect.init(x: 0, y: 64, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 50 - 64), style: .plain)
        tableview.delegate = self
        tableview.dataSource = self
        
        view .addSubview(tableview)//cellID
        tableview .register(UINib.init(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: "cellID")
        
        tableview.showsVerticalScrollIndicator = true
        tableview.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! MyTableViewCell
        
        cell.title.text = dataArray[indexPath.row] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if offset > 64{
        self.navigationController?.navigationBar.setBackgroundImage(imageWithColor(color: UIColor.white.withAlphaComponent(1)), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.isTranslucent = false
            scrollView.frame =  CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 50 - 64)
            self.navigationController?.navigationBar.shadowImage = nil
            navigationItem.title = "消息列表"
    }else
        {
            self.navigationController?.navigationBar.setBackgroundImage(imageWithColor(color: UIColor.white.withAlphaComponent(0)), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.isTranslucent = true
            
            scrollView.frame =  CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 50)
            self.navigationController?.navigationBar.shadowImage = UIImage.init()
            navigationItem.title = nil
        }
    
    }
    
}













