//
//  ManagerController.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class ManagerController: BaseViewControllerWithTable {

    var selectedDataArray = [String]()
    var selectButton : UIButton?
    
    var popButtonWidth = 200
    var popViewselectedIndex:Int?
    var popViewDataArray = ["Publications","Document Type","Document #","Document Title","Modified Date"]
    var popViewHeadTitle = "Sort Documents By"
    
    var _navigationController:BaseNavigationController?
    
    let managerCellIdentifier = "ManagerCellReuseIdentifier"
    let managerDetailCellReuseIdentifier = "ManagerDetailCellReuseIdentifier"
    
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
         navigationItem.titleView = nil
        
        initNavigationBarItem()
        NotificationCenter.default.addObserver(self, selector: #selector(startUnzip(_:)), name: NSNotification.Name (rawValue: "kNotification_unzipfile_start"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(startParsebook(_:)), name: NSNotification.Name (rawValue: "kNotification_start_update"), object: nil)
        
        //UpdateBookViewController
        NotificationCenter.default.addObserver(self, selector: #selector(allbookupdatecomplete(_:)), name: NSNotification.Name (rawValue: "kNotification_allbooksupdate_complete"), object: nil)
        
        loadData()
        
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //检测更新
        
        DBManager.default.installBook()
        
        /*
         if DBManager.hasBookNeedUpdate() {
         DBManager.default.installBook()
         
         ////
         //showUnzipViewController()
         }*/
        
    }
    
    
    //MARK:-
    func initNavigationBarItem(){
        var itemArr = navigationItem.rightBarButtonItems;
        let btn = UIButton (frame: CGRect (x: 0, y: 0, width: 40, height: 40))//23 * 23
        btn.setImage(UIImage (named: "update_button"), for: .normal)
        btn.setImage(UIImage (named: "update_button"), for: .highlighted)
        btn.addTarget(self, action: #selector(downloadBtnClicked(_:)), for: .touchUpInside)
        btn.tag = 100
        
        let ritem = UIBarButtonItem (customView: btn)
        itemArr?.append(ritem)
        navigationItem.rightBarButtonItems = itemArr

        let fixed = UIBarButtonItem (barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixed.width = 8
        //navigationItem.leftBarButtonItems = [fixed, litem_1,fixed]
        
        navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        return
        
        if !editing {
            self.editButtonItem.title = "Edit"
            tableview?.isEditing = false
        }else{
            self.editButtonItem.title = "Cancle"
            tableview?.isEditing = true
        }
    }
    
    
    func downloadBtnClicked(_ btn:UIButton){
        let vc = BaseViewControllerWithTable.init()
        let rect =  CGRect (x: 0, y: 0, width: Int(kCurrentScreenWidth - 200), height: 60 * 5)
        //...先赋值？才会走到 viewDidLoad
        vc.needtitleView = false
        vc.view.frame = rect
        
        let ds = DataSourceModel.search(with: nil, orderBy: nil) as! [DataSourceModel]
        
        vc.dataArray = ds
        vc.navigationItem.rightBarButtonItems = nil
        vc.title = "Updates"

        vc.tableview?.register(UINib.init(nibName: "DownloadCell", bundle: nil), forCellReuseIdentifier: "DownloadCellReuseIdentifierId")
        
        vc.kTableviewCellRowHeight = 88
        vc.tableview?.backgroundColor = UIColor.init(red: 109/255.0, green: 109/255.0, blue: 109/255.0, alpha: 0.6)
        vc.tableview?.backgroundView = nil
        vc.tableview?.frame = rect
        vc.tableview?.separatorStyle = .none
        vc.tableview?.bounces = true
        vc.tableview?.showsVerticalScrollIndicator = false
        vc.cellSelectedAction = {
            index in
            
        }
        
        //checkupdatebtn
        let checkupdatebtn = UIButton (frame: CGRect (x: 0, y: 0, width: 100, height: 30))
        checkupdatebtn.setBackgroundImage(UIImage (named: "donwload_data_button"), for: .normal)
        checkupdatebtn.setBackgroundImage(UIImage (named: "donwload_data_button"), for: .highlighted)
        checkupdatebtn.setTitle("检测更新", for: .normal)
        checkupdatebtn.setTitleColor(UIColor.white, for: .normal)
        checkupdatebtn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: 1)
        checkupdatebtn.addTarget(self, action: #selector(closeBtn), for: .touchUpInside)
        checkupdatebtn.tag = 100
        checkupdatebtn.layer.cornerRadius = 10
        checkupdatebtn.layer.masksToBounds = true
        
        let ritem = UIBarButtonItem (customView: checkupdatebtn)
        vc.navigationItem.rightBarButtonItem = ritem
        
        //close
        let closebtn = UIButton (frame: CGRect (x: 0, y: 0, width: 60, height: 40))
        closebtn.setTitle("取消", for: .normal)
        closebtn.setTitleColor(UIColor.white, for: .normal)
        closebtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: 1)
        closebtn.addTarget(self, action: #selector(closeBtn), for: .touchUpInside)
        closebtn.tag = 100
        let litem = UIBarButtonItem (customView: closebtn)
        vc.navigationItem.leftBarButtonItem = litem
        
        
        ///
        let nav = BaseNavigationController(rootViewController:vc)
        _navigationController = nav
        
        nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
        nav.preferredContentSize = rect.size
        self.present(nav, animated: false)
        
    }
    
    func closeBtn(){
        _navigationController?.dismiss(animated: false, completion: nil)
    }
    
    
    //MARK:- Notification
    func startUnzip(_ noti:Notification) {
        ////
        print("通知-showUnzipViewController.")
        showUnzipViewController()

    }
    
    
    func allbookupdatecomplete(_ noti:Notification)  {
        ///手册更新完毕，刷新列表
        HUD.show(successInfo: "更新完成")
        loadData()
    }
    
    func startParsebook(_ noti:Notification) {
        let rect = CGRect (x: 0, y: 0, width: 500, height: 180)
        let vc :UpdateBookViewController = UpdateBookViewController.init(nibName: "UpdateBookViewController", bundle: nil)
        
        vc.view.frame = rect
        vc.modalPresentationStyle = .formSheet
        vc.preferredContentSize = rect.size
        
        if let num = noti.userInfo?["filesnumber"] {
            vc.totalBookssnumber = num as! Int
        }
        
        self.navigationController?.present(vc, animated: false, completion: nil)
    }
    
    func test_update(){
        let rect = CGRect (x: 0, y: 0, width: 500, height: 180)
        let vc :UpdateBookViewController = UpdateBookViewController.init(nibName: "UpdateBookViewController", bundle: nil)
        vc.view.frame = rect
        vc.modalPresentationStyle = .formSheet
        vc.preferredContentSize = rect.size
        vc.totalBookssnumber = 5
        self.navigationController?.present(vc, animated: false, completion: nil)
    }
   
    //MARK:
    func showUnzipViewController() {
        let rect = CGRect (x: 0, y: 0, width: 500, height: 180)
        let vc :UnzipInfoViewController = UnzipInfoViewController.init(nibName: "UnzipInfoViewController", bundle: nil)
        /*
        let nav:BaseNavigationController = BaseNavigationController(rootViewController:vc)
        nav.navigationBar.barTintColor = UIColor.darkGray
        nav.navigationBar.tintColor = UIColor.black */
 
        vc.view.frame = rect
        vc.modalPresentationStyle = .formSheet
        vc.preferredContentSize = rect.size
        kUnzipprogress = vc.progress
        self.navigationController?.present(vc, animated: false, completion: nil)
    }
    
    
    func loadData(opt:String = "book_uuid") {
        dataArray.removeAll()
        selectedDataArray.removeAll()
        
        //字段为空的放在最后
        let arr = PublicationsModel.search(with: "\(opt)!=\"\"", orderBy: "\(opt) asc")
        dataArray = dataArray  + arr!
        
        let arr2 = PublicationsModel.search(with: "\(opt)=\"\"", orderBy: "\(opt) asc")
        dataArray = dataArray + arr2!
        
        tableview?.reloadData()
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
        
        if dataArray.count == 0 {
            return getCellForNodata(tableView, info: "No publication on the deveice.")
        }
        
        let value = dataArray[indexPath.row]
        
        if value is Int {
            let value = dataArray[indexPath.row - 1]
            let  model:PublicationsModel! = value as! PublicationsModel
            let cell = tableview?.dequeueReusableCell(withIdentifier: managerDetailCellReuseIdentifier, for: indexPath) as! ManagerDetailCell
            cell.selectionStyle = .none
            cell.fillCell(model: model)
            return cell
        }
        else
        {
            let  model:PublicationsModel! = value as! PublicationsModel
            let cell = tableview?.dequeueReusableCell(withIdentifier: managerCellIdentifier, for: indexPath) as! ManagerCell
            cell.selectionStyle = .none
            
            cell.fillCell(model: model)
            
//            if self.selectedDataArray.index(of: model.book_uuid ) != nil {
//                cell.cellSelectedInit()
//            }
            
            cell.cellIsSelected(self.selectedDataArray.index(of: model.book_uuid ) != nil)
            
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dataArray.count == 0 {
            return 70;
        }
        
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

     let value = dataArray[indexPath.row] as! PublicationsModel
        
       if self.selectedDataArray.index(of: value.book_uuid) != nil {
            selectedDataArray.remove(at: selectedDataArray.index(of: value.book_uuid)!)
            self.dataArray.remove(at: indexPath.row + 1)
        }
        
        else
       {
         selectedDataArray.append(value.book_uuid)
         self.dataArray.insert(0, at: indexPath.row + 1)
        }
       
        
        self.tableview?.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        print("收到内存告警!!!")
        // Dispose of any resources that can be recreated.
    }
    

}
