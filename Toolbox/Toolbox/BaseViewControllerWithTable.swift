//
//  BaseViewControllerWithTable.swift
//  Toolbox
//
//  Created by gener on 17/6/28.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class BaseViewControllerWithTable: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    var tableview:UITableView?
    var dataArray = [Any]()
    var sectionHeadtitle:String?
    
    var cellSelectedAction:((Int) -> (Void))?
    var cellSelectedIndex : Int?

    var needtitleView:Bool = true
    
    private var headSectionHeight = 30.0
    private var headSectionNum = 0//head中显示数字
    var headNumShouldChange:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableview = UITableView (frame: CGRect (x: 0, y: 0, width: 0, height: 0), style: .plain)
        tableview?.delegate = self
        tableview?.dataSource = self
        tableview?.backgroundColor = kTableviewBackgroundColor
        tableview?.separatorStyle = .none
        tableview?.tableFooterView = UIView()
        view.addSubview(tableview!)
        
        initSubview();
        
        guard needtitleView else {
            return
        }
        
        let button = UIButton (frame: CGRect (x: 0, y: 0, width: 200, height: 40))
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)//15 .13
        button.setTitle("Registry B-1638", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setImage(UIImage (named: "cheveron-normal_gry"), for: .normal)
        button.addTarget(self, action: #selector(popPresentControllerButtonAction(_:)), for: .touchUpInside)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20)
        button.imageEdgeInsets = UIEdgeInsetsMake(18, button.frame.width - 22 , 12, 10)
        navigationItem.titleView = button
    }

    func popPresentControllerButtonAction(_ button:UIButton){
        
        let rect = CGRect (x: 0, y: 0, width: 320, height: 160)
        
        let vc = PopViewController.init(nibName: "PopViewController", bundle: nil)
        vc.view.frame = rect
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.sourceView = button//指定原点，固定pop
        vc.popoverPresentationController?.sourceRect = CGRect (x: 0, y: 0, width: 200, height: 40)//pop的箭头位置在这个区域中间
        vc.preferredContentSize = CGSize (width: 320, height: 160)
        
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    public func initSubview(){
    
    }
    
    
    
    
    //MARK: - UITableViewDataSource
    //以下大多用于pop中的列表，其他情况下都在子类中重写
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil
        {
            cell = UITableViewCell (style: .default, reuseIdentifier: "reuseIdentifier")
            cell?.textLabel?.textColor = UIColor.darkGray
        }
        
        if indexPath.row == cellSelectedIndex {
            cell?.accessoryType = .checkmark
        }
        
        cell?.textLabel?.text = dataArray[indexPath.row] as? String
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        return {
            if headSectionNum == 0 || headNumShouldChange {
                headSectionNum = dataArray.count
            }
            
            let v = UIView (frame: CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: 30))
            v.backgroundColor = kTableviewHeadViewBgColor
            let title = UILabel (frame: CGRect (x: 0, y: 0, width: v.frame.width, height: 30))
            title.textColor = UIColor.white
            title.font = UIFont.boldSystemFont(ofSize: 18)
            title.text = "\t\t\(sectionHeadtitle!)\t\t\(headSectionNum)"
            
            v.addSubview(title)
            return v
            }()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 44;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(sectionHeadtitle != nil ? headSectionHeight : 0.0)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tmp = cellSelectedAction {
            tmp(indexPath.row)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
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
