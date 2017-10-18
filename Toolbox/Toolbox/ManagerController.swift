//
//  ManagerController.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class ManagerController: BaseViewControllerWithTable{

    var selectedDataArray = [String]()
    var selectedInEditModelArr = [String]()//编辑模式下选中的数据
    
    var selectButton : UIButton?
    var deleteButton:UIButton?
    
    var popButtonWidth = 200
    var popViewselectedIndex:Int?
    var popViewDataArray = ["Publications","Document Type","Document #","Document Title","Modified Date"]
    var popViewHeadTitle = "Sort Documents By"
    
    var _navigationController:BaseNavigationController?
    
    let managerCellIdentifier = "ManagerCellReuseIdentifier"
    let managerDetailCellReuseIdentifier = "ManagerDetailCellReuseIdentifier"
    
    var ds_isbusying:Bool = false
    
    var _update_btn:UIButton?
    var rightItems_old:[UIBarButtonItem]?
    var rightItemSelectAll:UIBarButtonItem?
    var rightItemBtn:UIButton?//== rightItemSelectAll
    var editButton:UIButton?
    
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = nil
        initNavigationBarItem()
        addObservers()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let btn = _update_btn {
            //初始无数据源时更新按钮提示『红叉』
            if let arr = DataSourceModel.search(with: nil, orderBy: nil) as?[DataSourceModel]{
                if arr.count == 0 {
                    btn.setImage(UIImage (named: "red_X_update_button"), for: .normal)
                }
            }
            
            btn.isSelected = DataSourceManager.default.ds_startupdating
        }
    }

    //MARK:- navigation Item
    func initNavigationBarItem(){
        var itemArr = navigationItem.rightBarButtonItems;
        let btn = UIButton (frame: CGRect (x: 0, y: 0, width: 40, height: 40))
        btn.setImage(UIImage (named: "green_update_button"), for: .normal)//23.23
        btn.setImage(UIImage (named: "inprogress_update_button"), for: .selected)
        btn.addTarget(self, action: #selector(downloadBtnClicked(_:)), for: .touchUpInside)
        _update_btn = btn

        let ritem = UIBarButtonItem (customView: btn)
        itemArr?.append(ritem)
        navigationItem.rightBarButtonItems = itemArr
        rightItems_old = itemArr;
        
        let fixed = UIBarButtonItem (barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixed.width = 8
        //navigationItem.leftBarButtonItems = [fixed, litem_1,fixed]
        navigationItem.leftBarButtonItem = navigationItemWith(index: 0, width: 80)
    }
    
    func navigationItemWith(index:Int,width:CGFloat) -> UIBarButtonItem {
        let btn = UIButton (frame: CGRect (x: 0, y: 0, width: width, height: index==0 ? 28 : 30))
        let title_1 = ["Edit","Select All"]
        let title_2 = ["Cancle","Unselect All"]
        btn.setTitle(title_1[index], for: .normal)
        btn.setTitle(title_2[index], for: .selected)
        btn.tag = 100 + index
        btn.addTarget(self, action: #selector(navigationItemBtnAction(_ :)), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        btn.setBackgroundImage(UIImage (named: "buttonBg2"), for: .normal)
        btn.setBackgroundImage(UIImage (named: "buttonBg2"), for: .selected)
        btn.adjustsImageWhenHighlighted = false
        if index == 0{
            editButton = btn
        }else{
            rightItemBtn = btn
        }
        
        let item = UIBarButtonItem.init(customView: btn)
        return item
    }
    
    func navigationItemBtnAction(_ btn:UIButton) {
        guard dataArray.count > 0 else {return}
        btn.isSelected = !btn.isSelected
        switch btn.tag {
        case 100:setEdited(btn.isSelected);break
        case 101:
            selectedInEditModelArr.removeAll()
            if btn.isSelected {//全选
                for m in dataArray {
                    let s = (m as! PublicationsModel).book_uuid
                    selectedInEditModelArr.append(s!)
                }
            }
            self.deleteButton?.isEnabled = selectedInEditModelArr.count > 0
            tableview?.reloadData();break
        default:break
        }
    }
    
    
    /// 是否处于编辑状态
    /// - Parameter isEdit: true/false
    func setEdited(_ isEdit:Bool) {
        if !isEdit {
            navigationItem.rightBarButtonItems = rightItems_old
            tableview?.isEditing = false
            tableview?.frame = CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: kCurrentScreenHeight - 64 - 49)
            selectedInEditModelArr.removeAll()
            view.viewWithTag(201)?.removeFromSuperview()
            rightItemBtn?.isSelected = false
            selectedInEditModelArr.removeAll()
        }else{
            if rightItemSelectAll == nil{
                rightItemSelectAll = navigationItemWith(index: 1, width: 100);
            }
            navigationItem.rightBarButtonItems = [rightItemSelectAll!]
            tableview?.isEditing = true
            tableview?.frame = CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: kCurrentScreenHeight - 64 - 49 - 60)
            
            let deleteBtnBg = UIView(frame: CGRect (x: 0, y: (tableview?.frame.maxY)!, width: kCurrentScreenWidth, height: 60))
            deleteBtnBg.tag = 201
            view.addSubview(deleteBtnBg)
            let deleteBtn = UIButton (frame: CGRect (x: (deleteBtnBg.frame.width - 350) / 2.0, y: (deleteBtnBg.frame.height - 40) / 2.0, width: 350, height: 40))
            deleteBtn.setBackgroundImage(UIImage (named: "deletePub"), for: .normal)
            deleteBtn.setImage(UIImage (named: "trash_icon"), for: .normal)
            deleteBtn.setTitle("Delete", for: .normal)
            deleteBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            deleteBtn.isEnabled = false
            deleteBtn.addTarget(self, action: #selector(deleteBtnClick(_ :)), for: .touchUpInside)
            deleteBtnBg.addSubview(deleteBtn)
            deleteButton = deleteBtn
            loadData()
        }
    }
    
    func downloadBtnClicked(_ btn:UIButton){
        let vc = DownloadViewController.init()
        let rect =  CGRect (x: 0, y: 0, width: Int(kCurrentScreenWidth - 200), height: 60 * 5)
        vc.view.frame = rect////////开始创建view

        let nav = BaseNavigationController(rootViewController:vc)
        nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
        nav.preferredContentSize = rect.size
        self.present(nav, animated: false)
    }

    
    func deleteBtnClick (_ btn:UIButton)  {
        let action_1 = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        let action_2 = UIAlertAction.init(title: "删除", style: .destructive, handler: { [weak self](action) in
            guard let strongSelf = self else{return}
            DispatchQueue.main.async {
                strongSelf.showUpdateVC(strongSelf.selectedInEditModelArr.count, type: 1)
                DispatchQueue.global().async {
                    DataSourceManager.deleteBooksWithId(strongSelf.selectedInEditModelArr)
                }
            }
        })
        
        let ac = UIAlertController.init(title: "提示", message: "删除后会清除所有相关数据,确定要删除?", preferredStyle: .alert)
        ac.addAction(action_1)
        ac.addAction(action_2)
        self.present(ac, animated: false, completion: nil)
    }
    
    
    //MARK:- Notification Mehods
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(startParsebook(_:)), name: NSNotification.Name (rawValue: "kNotification_start_update"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(allbookupdatecomplete(_:)), name: NSNotification.Name (rawValue: "kNotification_allbooksupdate_complete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkdsUpdate), name: NSNotification.Name (rawValue: "knotification_check_ds_update"), object: nil)

        DataSourceManager.default.addObserver(self, forKeyPath: "ds_startupdating", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        DispatchQueue.main.async {
            if keyPath == "ds_startupdating"{
                if let btn = self._update_btn {
                    btn.isSelected = DataSourceManager.default.ds_startupdating
                    if btn.image(for: .normal) == UIImage (named: "red_X_update_button") {
                        btn.setImage(UIImage (named: "green_update_button"), for: .normal)
                    }
                }
            }
        }
    }
    
    //检测服务器是否更新
    func checkdsUpdate() {
        DispatchQueue.global().async {
            if !DataSourceManager.default.ds_startupdating /*&& !self.ds_isbusying*/{
                //self.ds_isbusying = true
                let ds = DataSourceManager.default
                ds.ds_checkupdatemanual = true
                ds.ds_checkupdate()
            }

        }
    }
    
    func allbookupdatecomplete(_ noti:Notification)  {
        if let type = noti.userInfo?["type"] as? Int {
            if type == 0 {
                ///手册更新完毕，刷新列表
                self.ds_isbusying = false
                DataSourceManager.default.setValue(false, forKey: "ds_startupdating")//更新DS状态
                HUD.show(successInfo: "更新完成")
            }else{
                //全部删除完成
                print("delete all ok.")
                editButton?.isSelected = false
                setEdited(false)

                //强制更新检测
                let action = UIAlertAction.init(title: "继续", style: .destructive, handler: { [weak self](action) in
                    guard let strongSelf = self else{return}
                        strongSelf.checkdsUpdate()
                    })
                
                let ac = UIAlertController.init(title: "删除完成", message: nil, preferredStyle: .alert)
                ac.addAction(action)
                self.present(ac, animated: false, completion: nil)
            }
            
            loadData()
        }
    }
    
    func startParsebook(_ noti:Notification) {
        print("+++++++++++ startParsebook");//return
        if let num = noti.userInfo?["filesnumber"] as?Int {
            showUpdateVC(num)
        }
        
    }
    
    func showUpdateVC(_ num:Int = 0,type:Int = 0) {
        let rect = CGRect (x: 0, y: 0, width: 500, height: 180)
        let vc :UpdateBookViewController = UpdateBookViewController.init(nibName: "UpdateBookViewController", bundle: nil)
        vc.view.frame = rect
        vc.modalPresentationStyle = .formSheet
        vc.preferredContentSize = rect.size
        vc.totalBookssnumber = num
        vc.type = type
        self.present(vc, animated: false, completion: nil)
    }

    //MARK:
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
        //view.addSubview(topview)

        tableview?.frame = CGRect (x: 0, y: topview.frame.minY, width: kCurrentScreenWidth, height: kCurrentScreenHeight - 64 - 0)
        sectionHeadtitle =  "Publications on Device"
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
            return getCellForNodata(tableView, info: "NO PUBLICATIONS ON DEVICE")
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

            
            cell.cellIsSelected(self.selectedDataArray.index(of: model.book_uuid ) != nil)
            
            cell.setSelectInEdit(selectedInEditModelArr.contains(model.book_uuid))
            
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
       guard dataArray[indexPath.row] as? Int != 0 else { return }
       let value = dataArray[indexPath.row] as! PublicationsModel
        if tableView.isEditing {
            let s = value.book_uuid
            if let s = s{
                if self.selectedInEditModelArr.contains(s){
                    self.selectedInEditModelArr.remove(at: self.selectedInEditModelArr.index(of: s)!)
                }
                else{
                    self.selectedInEditModelArr.append(s)
                }
                if selectedInEditModelArr.count == dataArray.count{
                    rightItemBtn?.isSelected = true
                }
                if selectedInEditModelArr.count == 0{
                    rightItemBtn?.isSelected = false
                }
            }
            self.deleteButton?.isEnabled = selectedInEditModelArr.count > 0
            self.deleteButton?.setTitle("Delete" + (selectedInEditModelArr.count > 0 ? " (\(selectedInEditModelArr.count))":""), for: .normal)
            self.tableview?.reloadData()
            return
        }
        
       if self.selectedDataArray.index(of: value.book_uuid) != nil {
            selectedDataArray.remove(at: selectedDataArray.index(of: value.book_uuid)!)
            self.dataArray.remove(at: indexPath.row + 1)
        }else
       {
         selectedDataArray.append(value.book_uuid)
         self.dataArray.insert(0, at: indexPath.row + 1)
        }
        
        self.tableview?.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle(rawValue: 3)!
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return {
            let v = UIView (frame: CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: 30))
            v.backgroundColor = kTableview_headView_bgColor
            let title = UILabel (frame: CGRect (x: 0, y: 0, width: v.frame.width, height: 30))
            title.textColor = UIColor.white
            title.font = UIFont.boldSystemFont(ofSize: 18)
            title.text = "\t\t\(sectionHeadtitle!)\t\t\(dataArray.count - (selectedDataArray.count))"
            v.addSubview(title)
            return v
            }()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("收到内存告警!!!")
        // Dispose of any resources that can be recreated.
    }
    

}
