//
//  LargePicViewController.swift
//  Toolbox
//
//  Created by wyg on 2017/10/14.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class LargePicViewController: BaseViewControllerWithTable,UIWebViewDelegate {

    var webview:UIWebView!
    var loveBtn:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBarItem()
        webview = UIWebView.init(frame:  CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: kCurrentScreenHight - 64 - 49))
        webview.delegate = self
        webview.backgroundColor = kTableviewBackgroundColor
        view.addSubview(webview)
        
    }

    
    //MARK: -
    func initNavigationBarItem(){
        let closebtn = UIButton (frame: CGRect (x: 0, y: 0, width: 60, height: 40))
         closebtn.setTitle("Close", for: .normal)
         closebtn.addTarget(self, action: #selector(buttonClickedAction(_:)), for: .touchUpInside)
         closebtn.tag = 100
        let ritem_1 = UIBarButtonItem (customView: closebtn)
 
        let btn = UIButton (frame: CGRect (x: 0, y: 0, width: 40, height: 40))//14 * 16
        btn.setImage(UIImage (named: "bookmarkOff"), for: .normal)
        btn.setImage(UIImage (named: "bookmark_on"), for: .selected)
        btn.addTarget(self, action: #selector(buttonClickedAction(_:)), for: .touchUpInside)
        btn.tag = 101
        
        let ritem_2 = UIBarButtonItem (customView: btn)
        navigationItem.rightBarButtonItems = [ritem_1,ritem_2]
        loveBtn = btn
        
        /*let lbtn_1 = UIButton (frame: CGRect (x: 0, y: 0, width: 40, height: 40))//19 * 19
        lbtn_1.setImage(UIImage (named: "back_arrow"), for: .normal)
        lbtn_1.addTarget(self, action: #selector(buttonClickedAction(_:)), for: .touchUpInside)
        lbtn_1.tag = 101
        let litem_1 = UIBarButtonItem (customView: lbtn_1)
        
        let lbtn_2 = UIButton (frame: CGRect (x: 0, y: 0, width: 40, height: 40))
        lbtn_2.setImage(UIImage (named: "forward_arrow"), for: .normal)
        lbtn_2.addTarget(self, action: #selector(buttonClickedAction(_:)), for: .touchUpInside)
        lbtn_2.tag = 102
        let litem_2 = UIBarButtonItem (customView: lbtn_2)
        let fixed = UIBarButtonItem (barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixed.width = 8
        
        //....
        litem_1.isEnabled = false
        litem_2.isEnabled = false
        navigationItem.leftBarButtonItems = [fixed, litem_1,fixed,fixed,litem_2]*/
    }
    
    func buttonClickedAction(_ btn:UIButton){
        switch btn.tag {
        case 100:
        self.navigationController?.dismiss(animated: true, completion: nil)
            break
            
        case 101:
            btn.isSelected = !btn.isSelected
            
            //是否已收藏
            let hasloved = BookmarkModel.search(with: "seg_primary_id='\((kSelectedSegment?.primary_id!)!)'", orderBy: nil).count > 0
            if !hasloved {
//                let dic = getBaseData()
//                BookmarkModel.saveToDb(with: dic)
//                HUD.show(successInfo: "添加书签")
            }else{
                //删除记录
                let ret = BookmarkModel.delete(with: "seg_primary_id='\((kSelectedSegment?.primary_id!)!)'")
                if ret {
                    HUD.show(successInfo: "取消书签")
                }
            }
            break

        default: break
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
