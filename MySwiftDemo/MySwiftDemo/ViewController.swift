//
//  ViewController.swift
//  MySwiftDemo
//
//  Created by gener on 16/11/21.
//  Copyright © 2016年 Light. All rights reserved.
//

import UIKit
import Foundation

import Alamofire

class ViewController: BaseVCWithListController{
    
//    var dataArray:NSArray = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//
        let _index:Int! = tabBarController?.selectedIndex
        
        switch _index {
        case 0:
            itemTitle = "首页"
        case 1:
            itemTitle = "发现"
        case 2:
            itemTitle = "+"
        case 3:
            itemTitle = "消息"
        default:
            itemTitle = ""
        }
        
        
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
        
        self.editButtonItem.title = "编辑"
        navigationItem.leftBarButtonItem = self.editButtonItem
        
//        test()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if editing {
            self.editButtonItem.title = "完成"
            _tableView.isEditing = true
            _tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 50 - 60)
            let btn = UIButton (frame: (CGRect (x: 0, y: SCREEN_HEIGHT - 50 - 60, width: SCREEN_WIDTH, height: 60)))
            btn.backgroundColor = UIColor.red
            btn.setTitle("删除", for: .normal)
            btn.tag = 1001
            
            view.addSubview(btn)
        }else{
            self.editButtonItem.title = "编辑"
            _tableView.isEditing = false
            _tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 50)
            view.viewWithTag(1001)?.removeFromSuperview()
        }
    }
    
    func test(){
        //(() -> ())没有参数，没有返回值的闭包
        let `default` :String = {
            print("default");
            
            return "result"
        }()
        
        print(`default`)

        //
        do {
           _  = try click();
            print("123")
        }catch{
            print(error);
        }
        

        //
        let utilityQueue = DispatchQueue.global(qos: .utility)
        
        Alamofire.request("https://httpbin.org/get").responseJSON(queue: utilityQueue) { response in
            print("Executing response handler on utility queue")
        }

    }

    enum PrinterError: Error {
        case OutOfPaper
        case NoToner
        case OnFire
    }

    func click() throws
    {
        throw PrinterError.OutOfPaper
        
        print("click");
    }
    

    //MARK:
    func initSubviews()
    {
        _tableView = UITableView (frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 0), style: .grouped)
        _tableView.delegate = self
        _tableView.dataSource = self
        
        view .addSubview(_tableView)//cellID
        _tableView .register(UINib.init(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: "cellID")
        
        _tableView.showsVerticalScrollIndicator = true
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK:
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
        let vc = SecondViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}













