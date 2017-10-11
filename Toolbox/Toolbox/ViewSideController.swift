//
//  ViewSideController.swift
//  Toolbox
//
//  Created by gener on 17/10/11.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class ViewSideController: BaseViewController {

    var isOpen:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initSubview()
    }

    func initSubview() {
        view.backgroundColor =  UIColor.clear //kTableviewBackgroundColor
        
        /*let imgv = UIImageView (frame: CGRect (x: -25, y: (kCurrentScreenHight - 100 - 64 - 49)/2.0, width: 30, height: 100))
        imgv.image =  UIImage (named: "illustrations_selected")
        imgv.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapClick))
        imgv.addGestureRecognizer(tap)*/
        
        let ig = UIImage (named: "illustrations_selected")
        let btn = UIButton (frame: CGRect (x: 0, y: (kCurrentScreenHight - 100 - 64 - 49)/2.0, width: 30, height: 100))
        btn.setImage(ig, for: .normal)
        btn.addTarget(self, action: #selector(tapClick), for: .touchUpInside)
        view.addSubview(btn)
        
        let bgview = UIView (frame: CGRect (x: btn.frame.width, y: 0, width: view.frame.width, height: view.frame.height - 60))
        bgview.backgroundColor = kTableviewBackgroundColor
        view.addSubview(bgview)
        
    }
    
    
    
    func tapClick() {
        print("tap....")
        
        if isOpen {
            isOpen = false
            view.transform = CGAffineTransform (translationX: 0, y: 0)
        }else{
            isOpen = true
            view.transform = CGAffineTransform (translationX: -200, y: 0)
        }
        
        
        
        
        return
        let vc = BaseViewController()
        vc.view.backgroundColor = UIColor.black
        let nav = BaseNavigationController(rootViewController:vc)
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print(#function)
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
