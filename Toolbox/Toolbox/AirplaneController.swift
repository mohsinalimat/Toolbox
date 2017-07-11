//
//  AirplaneController.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import SwiftyJSON
import SSZipArchive
import SVProgressHUD

class AirplaneController:BaseViewControllerWithTable {
    var selectedDataArray = [String]()
    var selectButton : UIButton?
    
    var popButtonWidth = 135
    var popViewselectedIndex:Int?
    var popViewDataArray = ["Tail","Registry","MSN","Variable","CEC","Line"]
    var popViewHeadTitle = "Sort Airplanes By"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = nil

        //...第一次解析后保存标记
//        DBManager().parseJsonDataToDB{
//            print("parse ok!")
//        }
        
        loadData()

        
    }

    
    
    func loadData() {
        //字段为空的放在最后
        let arr = AirplaneModel.search(with: "airplaneRegistry!=\"\"", orderBy: "airplaneRegistry asc")
        dataArray = dataArray  + arr!
        
        let arr2 = AirplaneModel.search(with: "airplaneRegistry=\"\"", orderBy: "airplaneRegistry asc")
        dataArray = dataArray + arr2!
        
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
        vc.cellSelectedAction = {index in
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
        let value = dataArray[indexPath.row]

        if  value is Int{
            let cell = tableview?.dequeueReusableCell(withIdentifier: "AirplaneSubCellIdentifierId", for: indexPath) as! AirplaneSubCell
            cell.selectionStyle = .none
            return cell
        }
        else
        {
            let  model:AirplaneModel! = value as! AirplaneModel
            let cell = tableview?.dequeueReusableCell(withIdentifier: "AirplaneCellIdentifierId", for: indexPath) as! AirplaneCell
            cell.selectionStyle = .none
            
            cell.fillCell(model: model)
            
            if self.selectedDataArray.index(of: model.airplaneId) != nil{
                cell.cellSelectedInit()
            }
            
            
            cell.clickCellBtnAction = {
                isSelected in
                if isSelected{
                    self.dataArray.insert(0, at: indexPath.row + 1)
                    //...保存模型唯一标示
                    self.selectedDataArray.append(model.airplaneId)
//                    self.tableview?.insertRows(at: [IndexPath.init(row: indexPath.row + 1, section: 0)], with: UITableViewRowAnimation.top)
                }
                else{
                    self.dataArray.remove(at: indexPath.row + 1)
                    self.selectedDataArray.remove(at: self.selectedDataArray.index(of: model.airplaneId)!)
//                    self.tableview?.deleteRows(at: [IndexPath.init(row: indexPath.row + 1, section: 0)], with: UITableViewRowAnimation.fade)
                }
                
                self.tableview?.reloadData()
            }
            
            return cell
        }

    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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

        jumptoNextWithIndex(1)
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
