//
//  ManagerController.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class ManagerController: BaseViewControllerWithTable {

    var selectedDataArray = [Int]()
    var selectButton : UIButton?
    
    var popButtonWidth = 200
    var popViewselectedIndex:Int?
    var popViewDataArray = ["Publications","Document Type","Document #","Document Title","Modified Date"]
    var popViewHeadTitle = "Sort Documents By"
    
    
    let managerCellIdentifier = "ManagerCellReuseIdentifier"
    let managerDetailCellReuseIdentifier = "ManagerDetailCellReuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
         navigationItem.titleView = nil
        // Do any additional setup after loading the view.
    }

    
    override func initSubview(){
        
        title = "Manager"
        let topview : UIView  = {
            let v = UIView (frame: CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: 60))
            v.backgroundColor = UIColor.white
            let button = UIButton (frame: CGRect (x: 20, y: 10, width: popButtonWidth, height: 40))
            button.setBackgroundImage(UIImage (named: "buttonBg"), for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)//15 .13
            button.setTitle("Publications", for: .normal)
            button.setTitleColor(UIColor.darkGray, for: .normal)
            button.setImage(UIImage (named: "downSleft"), for: .normal)
            button.addTarget(self, action: #selector(popButtonAction(_:)), for: .touchUpInside)
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20)
            button.imageEdgeInsets = UIEdgeInsetsMake(17, button.frame.width - 20 , 17, 10)
            v.addSubview(button)
            selectButton = button
            
            let searchBtn = UITextField(frame: CGRect (x: kCurrentScreenWidth - 260, y: 10, width: 250, height: 40))
            searchBtn.placeholder = "Search"
            searchBtn.borderStyle = .roundedRect
            searchBtn.font = UIFont.systemFont(ofSize: 18)
            searchBtn.textColor = UIColor.darkGray
            searchBtn.clearButtonMode  = UITextFieldViewMode.whileEditing
            
            searchBtn.leftViewMode = .always
            let leftview = UIView (frame: CGRect (x: 0, y: 0, width: 25, height: 30))
            let imgview = UIImageView (image: UIImage (named: "search_mag_icon_"))//35 .32
            imgview.frame = CGRect (x: 10, y: 8, width: 15, height: 16)
            leftview.addSubview(imgview)
            
            searchBtn.leftView = leftview
            v.addSubview(searchBtn)
            
            return v
        }()
        view.addSubview(topview)
        
        //...test data
        dataArray = dataArray + [111,222,333,444]
        
        tableview?.frame = CGRect (x: 0, y: topview.frame.maxY, width: kCurrentScreenWidth, height: kCurrentScreenHight - 64 - 60)
        sectionHeadtitle =  "Publications on Devices"
        tableViewRegisterCell()
        
    }
    
    
    func tableViewRegisterCell() {
        tableview?.register(UINib(nibName: "ManagerCell", bundle: nil), forCellReuseIdentifier: managerCellIdentifier)
        tableview?.register(UINib (nibName:"ManagerDetailCell", bundle: nil), forCellReuseIdentifier: managerDetailCellReuseIdentifier)
    }
    
    
    
    //popView选择排序项
    func popButtonAction(_ button:UIButton)
    {
        let vc = BaseViewControllerWithTable.init()
        let rect =  CGRect (x: 0, y: 0, width: 280, height: 44 * popViewDataArray.count)
        //...先赋值？才会走到 viewDidLoad
        vc.needtitleView = false
        vc.view.frame = rect
        vc.dataArray = popViewDataArray
        vc.navigationItem.rightBarButtonItems = nil
        
        vc.title = popViewHeadTitle
        vc.tableview?.frame = rect
        vc.tableview?.separatorStyle = .singleLine
        vc.tableview?.bounces = false
        vc.tableview?.showsVerticalScrollIndicator = false
        vc.cellSelectedIndex = popViewselectedIndex
        vc.cellSelectedAction = {
            index in
            self.popViewselectedIndex = index
            button.setTitle(self.popViewDataArray[index], for: .normal)
            //...刷新列表
            
        }
        
        let nav = BaseNavigationController(rootViewController:vc)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        nav.popoverPresentationController?.sourceView = selectButton
        nav.popoverPresentationController?.sourceRect = (selectButton?.frame)!
        nav.preferredContentSize = rect.size
        self.present(nav, animated: true)
    }
    
    
    //MARK:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let value = dataArray[indexPath.row] as? Int
        
        if isDetailCell(value: value!){
            let cell = tableview?.dequeueReusableCell(withIdentifier: managerDetailCellReuseIdentifier, for: indexPath) as! ManagerDetailCell
            cell.selectionStyle = .none
            return cell
        }
        else
        {
            let cell = tableview?.dequeueReusableCell(withIdentifier: managerCellIdentifier, for: indexPath) as! ManagerCell
            cell.selectionStyle = .none

            cell.cellIsSelected(self.selectedDataArray.index(of: value!) != nil)
            
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tmp = dataArray[indexPath.row] as? Int
        if let isdetail = tmp
        {
            if isdetail == 0 {
                return 90;
            }
        }
        
        return 70;
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        guard dataArray[indexPath.row] as? Int != 0 else {
            return
        }

     let value = dataArray[indexPath.row] as! Int
        
       if self.selectedDataArray.index(of: value) != nil {
            selectedDataArray.remove(at: selectedDataArray.index(of: value)!)
            self.dataArray.remove(at: indexPath.row + 1)
        }
        
        else
       {
         selectedDataArray.append(value)
         self.dataArray.insert(0, at: indexPath.row + 1)
        }
       
        
        self.tableview?.reloadData()
        
    }
    
    
    //判断是否详情cell
    func isDetailCell(value: Int) -> Bool {
        return value == 0 ? true : false
    }
    
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}