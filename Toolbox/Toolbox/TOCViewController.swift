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
    var openedDirArray:[SegmentModel] = []
    
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
            openedDirArray.removeAll()
            getNewData(modelId: currentPublication.book_uuid)
        }
        else{
            let m = dataArray[indexPath.row] as! SegmentModel
            if Int(m.is_leaf) == 0 {
                let has = openedDirArray.index(of: m)
                if let has = has {
                    openedDirArray.removeSubrange(has+1..<openedDirArray.count)
                }
                else if has == nil {
                    openedDirArray.append(m)
                }

                
                getNewData(modelId: m.primary_id)
            }
            else {//没有子节点了
            //        jumptoNextWithIndex(3)
                
            }
        }
        
    }
    
    
  //MARK: - 数据处理
    func loadData() {
        //数据可能为空
        guard let selectedPublication = kSelectedPublication else {
            return
        }
        guard currentPublication !== selectedPublication  else {
            return
        }
        currentPublication = selectedPublication
        openedDirArray.removeAll()
        
        getNewData(modelId: currentPublication.book_uuid)
    }
    
    func getNewData(modelId:String){
        dataArray.removeAll()
        dataArray.append(currentPublication)
        dataArray = dataArray + openedDirArray
        
        let arr = traversalModel(id: modelId)
        dataArray = dataArray + arr
    
        tableview?.reloadSections(IndexSet.init(integer: 0), with: .fade)
    }
    
  
    func traversalModel(id:String) -> [SegmentModel] {
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
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
