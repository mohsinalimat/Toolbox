//
//  AirplaneController.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import Alamofire
import WebKit

class AirplaneController:BaseViewControllerWithTable ,UITextFieldDelegate{
    var selectedDataDic = [String:[String]]()//当前已选择展开的model标记
    var sortButton : UIButton? //sort
    let popButtonWidth = 135
    var popViewselectedIndex:Int = 1 //标记pop当前选择的索引
    let popViewkeyArr = ["Tail","Registry","MSN","Variable","CEC","Line"]
    let popViewHeadTitle = "Sort Airplanes By"
    var currentFieldKey:String! = "Registry"
    var currentFieldName:String! = "airplaneRegistry"
    var searchKey:String = ""//search text
    var pub_customer_arr = [String]()//获取客户名称customer_name
    var selectedindexPath:IndexPath?
    
    var is_in_search:Bool = false
    
    
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = nil
        
        //获取apmodel
//        let _modelpath = ROOTPATH + "/CCA" + "/apModelMap.js"
//        var _apmodel = [String:[String:String]]()
//        if let m = UNZIPFile.default.readApModelMap(_modelpath) {
//            _apmodel = m
//        }

        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        if let hasSelectedAir = kSelectedAirplane{
            for (index_0,value)  in dataArray.enumerated() {
                var dic = value as! [String:[Any]]
                let key = dic.keys.first
                var ds_arr = get_ds(index_0)
                for (index,m) in ds_arr.enumerated() {
                    let m = m as? AirplaneModel
                    if hasSelectedAir.airplaneId == m?.airplaneId {
                        selectedindexPath = IndexPath (row: index, section: index_0)
                        ds_arr.insert(0, at: index + 1)
                        dic[key!] = ds_arr
                        dataArray[index_0] = dic
                        updateSelectedDataWith(key!, value: hasSelectedAir.airplaneId);break
                    }
                }

            }
        }
        
        tableview?.reloadData()
        if let indexpath = selectedindexPath{
            tableview?.scrollToRow(at: indexpath, at: .top, animated: true);
        }
    }
    
    //MARK:-
    func loadData(opt:String = "airplaneRegistry") {
        dataArray.removeAll()
        selectedDataDic.removeAll()
        pub_customer_arr.removeAll()
        
        if let pub_arr =  PublicationsModel.search(withSql: "select customer_name from Publications order by customer_name asc"){
            for pub in pub_arr {
                let m = pub as! PublicationsModel
                let name = m.customer_name
                if !pub_customer_arr.contains(name!){
                    pub_customer_arr.append(name!)
                }
            }
            
        }
        
        HUD.show(withStatus: "Loading...")
        for name in pub_customer_arr{
            let customer_name = name
            var total_arr:[AirplaneModel] = [AirplaneModel]()
            if searchKey != "" && searchKey.lengthOfBytes(using: String.Encoding.utf8) > 0 {
                let arr = AirplaneModel.search(with: "\(opt)!=\"\" and airplaneRegistry like '%\(searchKey)%' and customer_name='\(customer_name)'", orderBy: "\(opt) asc") as! [AirplaneModel]
                total_arr = total_arr  + arr
            }
            else{//字段为空的放在最后 "airplaneRegistry like '%\(s)%'"
                let arr = AirplaneModel.search(with: "\(opt)!=\"\" and customer_name='\(customer_name)'", orderBy: "\(opt) asc") as! [AirplaneModel]
                total_arr = total_arr  + arr
                
                let arr2 = AirplaneModel.search(with: "\(opt)=\"\" and customer_name='\(customer_name)'", orderBy: "\(opt) asc") as! [AirplaneModel]
                total_arr = total_arr + arr2
            }
            
            if total_arr.count > 0 {
                let dic = [customer_name:total_arr]
                dataArray.append(dic)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
             HUD.dismiss()    
        }
    }
    

    override func initSubview(){
        title = "Airplane Selector"
        let topview : UIView  = {
            let v = UIView (frame: CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: 60))
            v.backgroundColor = UIColor.white
            let button = UIButton (frame: CGRect (x: 20, y: 10, width: popButtonWidth, height: 40))
            button.setBackgroundImage(UIImage (named: "buttonBg"), for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)//15 .13
            button.setTitle("Registry", for: .normal)
            button.setTitleColor(UIColor.darkGray, for: .normal)
            button.setImage(UIImage (named: "downSleft"), for: .normal)
            button.addTarget(self, action: #selector(popButtonAction(_:)), for: .touchUpInside)
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20)
            button.imageEdgeInsets = UIEdgeInsetsMake(17, button.frame.width - 20 , 17, 10)
            v.addSubview(button)
            sortButton = button
            
            let searchBtn = UITextField(frame: CGRect (x: kCurrentScreenWidth - 220, y: 10, width: 200, height: 40))
            searchBtn.placeholder = "Search your fleet"
            searchBtn.borderStyle = .roundedRect
            searchBtn.font = UIFont.systemFont(ofSize: 18)
            searchBtn.textColor = UIColor.darkGray
            searchBtn.clearButtonMode  = UITextFieldViewMode.whileEditing
            searchBtn.delegate = self
            searchBtn.returnKeyType = .search
            searchBtn.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
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
        
        tableview?.frame = CGRect (x: 0, y: topview.frame.maxY, width: kCurrentScreenWidth, height: kCurrentScreenHeight - 64 - 60)
        sectionHeadtitle =  "Air China"
        tableview?.register(UINib(nibName: "AirplaneCell", bundle: nil), forCellReuseIdentifier: "AirplaneCellIdentifierId")
        tableview?.register(UINib (nibName:"AirplaneSubCell", bundle: nil), forCellReuseIdentifier: "AirplaneSubCellIdentifierId")
    }

    
    //popView选择排序项
    func popButtonAction(_ button:UIButton)
    {
        let vc = BaseViewControllerWithTable.init()
        let rect =  CGRect (x: 0, y: 0, width: 280, height: 44 * popViewkeyArr.count)
        //...先赋值？才会走到 viewDidLoad
        vc.needtitleView = false
        vc.view.frame = rect
        vc.dataArray = popViewkeyArr
        vc.navigationItem.rightBarButtonItems = nil
        
        vc.title = popViewHeadTitle
        vc.tableview?.frame = rect
        vc.tableview?.separatorStyle = .singleLine
        vc.tableview?.bounces = false
        vc.tableview?.showsVerticalScrollIndicator = false
        vc.cellSelectedIndex = popViewselectedIndex
        vc.cellSelectedAction = {
            [weak self] index in
            guard let strongSelf = self else { return }
            let keytitle = strongSelf.popViewkeyArr[index]
            button.setTitle("\(keytitle)", for: .normal)
            kAIRPLANE_SORTEDOPTION_KEY = keytitle
            
            //记录当前选项刷新列表
            let fname = kAirplaneKeyValue[keytitle]!
            strongSelf.popViewselectedIndex = index
            strongSelf.currentFieldKey = keytitle
            strongSelf.currentFieldName = fname
            strongSelf.loadData(opt:fname)
            strongSelf.tableview?.reloadData()
        }
        
        let nav = BaseNavigationController(rootViewController:vc)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        nav.popoverPresentationController?.sourceView = sortButton
        nav.popoverPresentationController?.sourceRect = (sortButton?.frame)!
        nav.preferredContentSize = rect.size
        self.present(nav, animated: true)
    }
    
    //MARK: 根据关键字搜索
    func textFieldDidChange(_ textField:UITextField) {
         let tf = textField
        dataArray.removeAll()
        selectedDataDic.removeAll()
        if let s = tf.text {
            for name in pub_customer_arr{
                let customer_name = name
                var total_arr:[AirplaneModel] = [AirplaneModel]()
                let arr = AirplaneModel.search(with: "airplaneRegistry!=\"\" and airplaneRegistry like '%\(s)%' and customer_name='\(customer_name)'", orderBy: "airplaneRegistry asc") as! [AirplaneModel]
                total_arr = total_arr + arr
                let arr2 = AirplaneModel.search(with: "airplaneRegistry=\"\" and airplaneRegistry like '%\(s)%' and customer_name='\(customer_name)'", orderBy: "airplaneRegistry asc") as! [AirplaneModel]
                total_arr = total_arr + arr2
                
                if total_arr.count > 0 {
                    let dic = [customer_name:total_arr]
                    dataArray.append(dic)
                }
            }

            searchKey = s
        }
        tableview?.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK:数据源
    func get_ds(_ index:Int) -> [Any] {
        guard dataArray.count > 0 ,let d = dataArray[index] as? [String:[Any]] else {
            return []
        }
        return d.values.first!
    }
    
    //已选择展开的行数据
    func updateSelectedDataWith(_ key:String,value:String) {
        if var arr = selectedDataDic[key]{
            if arr.contains(value){
                arr.remove(at: arr.index(of: value)!)
            }else{
                arr.append(value)
            }
            selectedDataDic[key] = arr
        }else{
            selectedDataDic[key] = [value]
        }
        
    }
    
    func hasContains(_ key:String,value:String) -> Bool {
        if let arr = selectedDataDic[key] {
            if arr.contains(value){
                return true;
            }
        }
        return false
    }
    
    
    //MARK:
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arr = get_ds(section)
        return arr.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let d = dataArray[section] as! [String:[Any]]
        let key = d.keys.first
        let value = d.values.first
        let select = selectedDataDic[key!]        
        return {
            let v = UIView (frame: CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: 30))
            v.backgroundColor = kTableview_headView_bgColor
            let title = UILabel (frame: CGRect (x: 0, y: 0, width: v.frame.width, height: 30))
            title.textColor = UIColor.white
            title.font = UIFont.boldSystemFont(ofSize: 18)
            title.text = "\t\t\(key!)\t\t\((value?.count)! - ((select?.count) ?? 0))"
            v.addSubview(title)
            return v
            }()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataArray.count == 0 {
            return getCellForNodata(tableView, info: "NO AIRPLANE")
        }
        var dic = dataArray[indexPath.section] as![String:[Any]]
        var _dataArray = dic.values.first
        let key = dic.keys.first
        let value = _dataArray?[indexPath.row]
        if  value is Int{
            let value = _dataArray?[indexPath.row - 1]
            let  model:AirplaneModel! = value as! AirplaneModel
            let cell = tableview?.dequeueReusableCell(withIdentifier: "AirplaneSubCellIdentifierId", for: indexPath) as! AirplaneSubCell
            cell.selectionStyle = .none
            cell.fillCell(model: model ,title: currentFieldKey)
            return cell
        }
        else
        {
            let  model:AirplaneModel! = value as! AirplaneModel
            let cell = tableview?.dequeueReusableCell(withIdentifier: "AirplaneCellIdentifierId", for: indexPath) as! AirplaneCell
            cell.selectionStyle = .none
            cell.fillCell(model: model ,title: currentFieldName)// && !is_in_search
            if self.hasContains(key!, value: model.airplaneId) /*|| ((kSelectedAirplane?.airplaneId == model.airplaneId) && (_dataArray?[indexPath.row + 1] is Int) )*/ {
                cell.cellSelectedInit()
            }else{
                cell._init()
            }
            
            cell.clickCellBtnAction = {[weak self] isSelected in
                guard let strongSelf = self else { return }
                if isSelected{
                    _dataArray?.insert(0, at: indexPath.row + 1)
                    dic[key!] = _dataArray
                    strongSelf.dataArray[indexPath.section] = dic
                }
                else{
                    _dataArray?.remove(at: indexPath.row + 1)
                    dic[key!] = _dataArray
                    strongSelf.dataArray[indexPath.section] = dic
                }
                
                strongSelf.updateSelectedDataWith(key!, value: model.airplaneId)
                strongSelf.tableview?.reloadData()
            }
            
            return cell
        }

    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let arr = get_ds(indexPath.section)
        let tmp = arr[indexPath.row] as? Int
        if let isdetail = tmp{
            if isdetail == 0 {
                return 50;
            }
        }
        
        return 64;
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let arr = get_ds(indexPath.section)
        let value:Any! = arr[indexPath.row]
        if  value is Int{
            let value = arr[indexPath.row - 1]
            let  model:AirplaneModel! = value as! AirplaneModel
            kSelectedAirplane = model
        }
        else
        {
            kSelectedAirplane = (value as! AirplaneModel)
        }

        NotificationCenter.default.post(name: knotification_airplane_changed, object: nil)
        RootControllerChangeWithIndex(1)
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
