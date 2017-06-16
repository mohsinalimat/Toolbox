//
//  BaseVCWithListController.swift
//  MySwiftDemo
//
//  Created by gener on 17/6/12.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class BaseVCWithListController: BaseViewController ,UITableViewDelegate,UITableViewDataSource{

    var itemTitle:String?
    
    var dataArray  = [String]()
    
    var _tableView : UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    
    func imageWithColor(_ color:UIColor) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        UIGraphicsBeginImageContext(rect.size)
        
        let content = UIGraphicsGetCurrentContext()
        
        content?.setFillColor(color.cgColor)
        
        content?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
        
    }
    
    
    //MARK:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! MyTableViewCell
        
        cell.title.text = dataArray[indexPath.row] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let _v = UIView(frame: CGRect (x: 0, y: 0, width: SCREEN_WIDTH, height: 64))
        _v.backgroundColor = UIColor.red
        
        return _v
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if offset > 64{
            self.navigationController?.navigationBar.setBackgroundImage(imageWithColor(UIColor.white.withAlphaComponent(1)), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.shadowImage = nil
            
            scrollView.frame =  CGRect(x: 0, y: -64, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 50 )
            
            navigationItem.title = itemTitle!
        }else
        {
            self.navigationController?.navigationBar.setBackgroundImage(imageWithColor(UIColor.white.withAlphaComponent(0)), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.shadowImage = UIImage.init()
            
            scrollView.frame =  CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 50)
            
            navigationItem.title = nil
        }
        
        
        //判断滑动方向
//        let point = scrollView.panGestureRecognizer.velocity(in: scrollView)
//        
//        if point.y > 0{
//            print("向下滑动");
//        }else{
//            print("向上");
//        }
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
