//
//  TOCViewController.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//  Table Of Content 章节目录

import UIKit

let kSegmentCellIdentifier = "SegmentCellIdentifier"
let kPublicationCellReuseIdentifier = "PublicationCellReuseIdentifier"

class TOCViewController: BaseViewControllerWithTable {

    var currentPublication:PublicationsModel!
//    var kseg_parentnode_arr:[SegmentModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        super.viewWillAppear(animated)
    }
    
    
    override func initSubview(){
        tableview?.frame = CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: kCurrentScreenHight - 64)
        tableview?.register(UINib(nibName: "PublicationCell", bundle: nil), forCellReuseIdentifier: kPublicationCellReuseIdentifier)
        tableview?.register(UINib (nibName: "SegmentCell", bundle: nil), forCellReuseIdentifier: kSegmentCellIdentifier)

    }
    
    
    
    
    //MARK:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //是否为目录
        if indexPath.row == 0 {
            getNewData(modelId: currentPublication.book_uuid,flushDir: true)
        }
        else{
            let m = dataArray[indexPath.row] as! SegmentModel
            if Int(m.is_leaf) == 0 {
                let has = kseg_parentnode_arr.index(of: m)
                if let has = has {
                    kseg_parentnode_arr.removeSubrange(has+1..<kseg_parentnode_arr.count)
                }
                else if has == nil {
                    kseg_parentnode_arr.append(m)
                }
                
                getNewData(modelId: m.primary_id)
            }
            else {//没有子节点了
                    /////
                    kseg_contentlocation_url = m.content_location
                    kseg_primary_id = m.primary_id
                
                    kSelectedSegment = m
                    RootControllerChangeWithIndex(3)
                
            }
        }
        
    }
    
    
    //MARK: - 数据处理
    func loadData() {
        //第一次进入currentPublication数据可能为空，稍后做提示处理？
        guard let selectedPublication = kSelectedPublication else {
            return
        }
        guard currentPublication !== selectedPublication  else {
            return
        }
        currentPublication = selectedPublication
        
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
    /// - parameter flushDir: 标记为是否需要清空已展开的目录数据-openedDirArray
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
