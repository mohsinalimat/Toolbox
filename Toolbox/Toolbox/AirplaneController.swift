//
//  AirplaneController.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import SSZipArchive

class AirplaneController:BaseViewControllerWithTable {
    var selectedDataArray = [String]()//当前已选择展开的model标记
    var selectButton : UIButton?
    
    let popButtonWidth = 135
    var popViewselectedIndex:Int? //标记pop当前选择的索引
    let popViewkeyArr = ["Tail","Registry","MSN","Variable","CEC","Line"]

    let popViewHeadTitle = "Sort Airplanes By"
    var currentFieldKey:String! = "Registry"
    var currentFieldName:String! = "airplaneRegistry"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataArray = dataArray as! [AirplaneModel]
        
        navigationItem.titleView = nil

        //...第一次解析后保存标记
        
//        loadData()
        
//        var arr = [11,22,33]
//        for (i,seg) in arr.enumerated() {
//            print("\(i) - \(seg)")
//            if seg == 22 {
//                arr.remove(at: i)
//                break
//            }
//        }
        
        
//        let workitem1 = DispatchWorkItem(qos: .userInitiated, flags: DispatchWorkItemFlags.detached) {
//            for i in 0..<20 {
//            print("-------\(i)")
//            }
//        }
//        
//        let workitem2 = DispatchWorkItem.init(qos: .userInitiated, flags: DispatchWorkItemFlags.detached) {
//            for i in 0..<20 {
//                print("++++++++\(i)")
//            }
//        }
//        
//        workitem1.perform()
//        
//        let queue = DispatchQueue.init(label: "com.dbmanager.queue",qos:DispatchQoS.utility)
//        
//        queue.async(execute: workitem1)
//        queue.async(execute: workitem2)
        
        //Test()
        //CoreDataKit.default.insert(dic: ["primary_id":"22"])
        
        
    }

    func Test() {
      //let path = ROOTPATH.appending("/CCA/CCAA330CCATSM_20170101/tsm/resources/book.xml")
        let path = Bundle.main.path(forResource: "book", ofType: "xml")
      DataParseKit.default.parserStart(withBookPath: path!, bookName: "CCAA330CCATSM_20170101")
      
        
        DataParseKit.default.parserStart(withBookPath: ROOTPATH.appending("/CCA/CCAA330CCATSM_20170101/tsm"), bookName: "CCAA330CCATSM_20170101", completeHandler: {
            
            print("all ok")
        })
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
        if let hasSelectedAir = kSelectedAirplane{
            for (index,value)  in dataArray.enumerated() {
                let m = value as? AirplaneModel
                if hasSelectedAir.airplaneId == m?.airplaneId {
                    dataArray.insert(0, at: index + 1)
                    selectedDataArray.append(hasSelectedAir.airplaneId)
                }
            }
        }

        
        tableview?.reloadData()
    }
    
    //MARK:-
    func loadData(opt:String = "airplaneRegistry") {
        dataArray.removeAll()
        selectedDataArray.removeAll()
        
        HUD.show(withStatus: "Loading...")
        //字段为空的放在最后
        let arr = AirplaneModel.search(with: "\(opt)!=\"\"", orderBy: "\(opt) asc")
        dataArray = dataArray  + arr!
        
        let arr2 = AirplaneModel.search(with: "\(opt)=\"\"", orderBy: "\(opt) asc")
        dataArray = dataArray + arr2!
 
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
             HUD.dismiss()    
        }
        
        
    }
    
    
    var completionHandlers: [() -> Void] = []
    func someFunctionWithEscapingClosure(completionHandler:@escaping () -> Void) {
       completionHandlers.append(completionHandler)
    }
    
    override func initSubview(){
        title = "Aiplane Selector"
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
            selectButton = button
            
            let searchBtn = UITextField(frame: CGRect (x: kCurrentScreenWidth - 220, y: 10, width: 200, height: 40))
            searchBtn.placeholder = "Search your fleet"
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
        nav.popoverPresentationController?.sourceView = selectButton
        nav.popoverPresentationController?.sourceRect = (selectButton?.frame)!
        nav.preferredContentSize = rect.size
        self.present(nav, animated: true)
    }
    
    
    //MARK:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if dataArray.count == 0 {
            return getCellForNodata(tableView, info: "No airplane data.")
        }
        
        let value = dataArray[indexPath.row]
        if  value is Int{
            let value = dataArray[indexPath.row - 1]
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
            
            cell.fillCell(model: model ,title: currentFieldName)
            
            if self.selectedDataArray.index(of: model.airplaneId ) != nil || ((kSelectedAirplane?.airplaneId == model.airplaneId) && (dataArray[indexPath.row + 1] is Int)) {
                cell.cellSelectedInit()
            }
            
            
            cell.clickCellBtnAction = {
                isSelected in
                if isSelected{
                    self.dataArray.insert(0, at: indexPath.row + 1)
                    //保存唯一标示airplaneId
                    self.selectedDataArray.append(model.airplaneId)
//                    self.tableview?.insertRows(at: [IndexPath.init(row: indexPath.row + 1, section: 0)], with: UITableViewRowAnimation.top)
                }
                else{
                    self.dataArray.remove(at: indexPath.row + 1)
                    self.selectedDataArray.remove(at: self.selectedDataArray.index(of: model.airplaneId)!)
                    
                }
                
                self.tableview?.reloadData()
            }
            
            return cell
        }

    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dataArray.count == 0 {
            return 64;
        }
        
        let tmp = dataArray[indexPath.row] as? Int
        if let isdetail = tmp
        {
            if isdetail == 0 {
                return 50;
            }
        }
        
        return 64;
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let value:Any! = dataArray[indexPath.row]
        
        if  value is Int{
            let value = dataArray[indexPath.row - 1]
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
