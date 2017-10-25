//
//  TOCViewController.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//  Table Of Content 章节目录

import UIKit

private let kSegmentCellIdentifier = "SegmentCellIdentifier"
private let kPublicationCellReuseIdentifier = "PublicationCellReuseIdentifier"

class TOCViewController: BaseViewControllerWithTable {
    var currentPublication:PublicationsModel!
    var currentSegment:SegmentModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(recnotification(_:)), name: knotification_airplane_changed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recnotification(_:)), name: knotification_publication_changed, object: nil)
    }

    func recnotification(_ noti:Notification)  {
        currentPublication = nil
        kSelectedSegment = nil
        
        kseg_direction = 1
        kseg_parentnode_arr.removeAll()
        dataArray.removeAll()
        
        tableview?.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    
    override func initSubview(){
        tableview?.frame = CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: kCurrentScreenHeight - 64)
        tableview?.register(UINib(nibName: "PublicationCell", bundle: nil), forCellReuseIdentifier: kPublicationCellReuseIdentifier)
        tableview?.register(UINib (nibName: "SegmentCell", bundle: nil), forCellReuseIdentifier: kSegmentCellIdentifier)
        tableview?.backgroundView = nil;
    }
    

    //MARK:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataArray.count == 0 {
            return getCellForNodata(tableView, info: "NO PUBLICATION SELECTED")
        }
        
        if indexPath.row == 0 {
            let cell = tableview?.dequeueReusableCell(withIdentifier: kPublicationCellReuseIdentifier, for: indexPath) as! PublicationCell
            let model = dataArray[0] as! PublicationsModel
            cell.fillCell(model: model)
            return cell
        }
        else{
            let cell = tableview?.dequeueReusableCell(withIdentifier: kSegmentCellIdentifier, for: indexPath) as! SegmentCell
            let model = dataArray[indexPath.row] as! SegmentModel
        
            cell.fillCell(model: model)
            
            if currentSegment?.primary_id == model.primary_id {//是否选中
                cell.backgroundColor = kCellSelectedBgColor
                cell.cellIsSelected(true)
            }
            else{
                cell.backgroundColor = kCellDefaultBgColor
                cell.cellIsSelected(false)
            }
            
            
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {//根目录
            currentSegment = nil
            kSelectedSegment = nil
            getNewData(modelId: currentPublication.book_uuid,flushDir: true)
        }
        else{
            let m = dataArray[indexPath.row] as! SegmentModel
            currentSegment = m
            if Int(m.is_leaf) == 0 {
                let has = kseg_parentnode_arr.index(of: m)
                if let has = has {
                    kseg_parentnode_arr.removeSubrange(has+1..<kseg_parentnode_arr.count)
                }
                else if has == nil {
                    kseg_parentnode_arr.append(m)
                }
                
                getNewData(modelId: m.primary_id)
                tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
            }
            else {//最后一级目录
                    let cell = tableView.cellForRow(at: indexPath)
                    cell?.backgroundColor = kCellSelectedBgColor
                    kSelectedSegment = m
                    tableView.reloadData()
                
                if cell?.backgroundView != nil{
                    showMsg()
                }
                else {
                    RootControllerChangeWithIndex(3)
                }
                
                
            }
        }
        
    }
    
    func showMsg() {
       let alert = UIAlertController.init(title: "提示", message: "将要打开的内容不适合当前选择的机型，是否是要继续查看?", preferredStyle: .alert)
       let action_1 = UIAlertAction.init(title: "取消", style: .cancel) { (action) in
        
        }
        let action_2 = UIAlertAction.init(title: "继续", style: .default) { (action) in
            RootControllerChangeWithIndex(3)
        }
        
        alert.addAction(action_1)
        alert.addAction(action_2)
        
        self.present(alert, animated: true)
        
    }
    
    //MARK: - 数据处理
    func loadData() {
        guard let selectedPublication = kSelectedPublication else {
            dataArray.removeAll()
            tableview?.reloadData()
            return
        }
        guard currentPublication !== selectedPublication  else {
            return
        }
        currentPublication = selectedPublication
        currentSegment = kSelectedSegment
        
        if kseg_direction == 1{
            getNewData(modelId: currentPublication.book_uuid,flushDir: true)
        }else{
            let m = kseg_parentnode_arr.last
            guard let parid = m?.primary_id else {
                return
            }
            getNewData(modelId: parid,flushDir: false)
        }
        
    }
    
    
    /// 获取目录数据
    ///
    /// - parameter modelId:  当前model的主键-primary_id
    /// - parameter flushDir: 标记为是否需要清空已展开的目录数据
    func getNewData(modelId:String,flushDir:Bool? = false){
        dataArray.removeAll()
        dataArray.append(currentPublication)
        
        if let  f = flushDir {
            if f {
                kseg_parentnode_arr.removeAll()
            }
            else{
                dataArray = dataArray + kseg_parentnode_arr
            }
        }
        
        //向下遍历子孙节点
        let arr:[SegmentModel] = { id in
            var tmpArr = [SegmentModel]()
            func _search(_ id:String){
                let chapter:[SegmentModel] = SegmentModel.search(with: "parent_id='\(id)'", orderBy: nil) as! [SegmentModel]
                for m in chapter {
                    if Int(m.is_visible) == 0 {
                        //不可见
                        _search(m.primary_id)
                    }else{
                        tmpArr.append(m);
                    }
                }
            }
            
            _search(id)
            return tmpArr
        }(modelId)
        
        dataArray = dataArray + arr
        tableview?.reloadSections(IndexSet.init(integer: 0), with: .fade)
    }

 
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
