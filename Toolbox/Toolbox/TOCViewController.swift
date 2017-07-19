//
//  TOCViewController.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//  Table Of Content 章节目录

import UIKit

class TOCViewController: BaseViewControllerWithTable {

    var currentPublication:PublicationsModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func loadData() {
        //数据可能为空
        guard let selectedPublication = kSelectedPublication else {
            return
        }
        guard currentPublication !== selectedPublication  else {
            return
        }

        currentPublication = selectedPublication
        dataArray.removeAll()
        dataArray.append(currentPublication)
        
        
        tableview?.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        super.viewWillAppear(animated)
    }
    
    override func initSubview(){

        tableview?.frame = CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: kCurrentScreenHight - 64)
        tableview?.register(UINib(nibName: "PublicationCell", bundle: nil), forCellReuseIdentifier: "PublicationCellReuseIdentifier")

        //...test data 书本数据 + 章节数据 + 一级Section + 二级section

    }
    
    
    
    
    //MARK:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview?.dequeueReusableCell(withIdentifier: "PublicationCellReuseIdentifier", for: indexPath) as! PublicationCell
        if indexPath.row == 0 {
            let model = dataArray[0] as! PublicationsModel
            cell.fillCell(model: model)
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //判断目录层级
        
        
        jumptoNextWithIndex(3)
    }
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
