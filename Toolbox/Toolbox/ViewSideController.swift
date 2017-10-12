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
    
    var view_init_center:CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewSideController: viewDidLoad")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initSubview()
    }
    
    func initSubview() {
        view.backgroundColor =  UIColor.clear //kTableviewBackgroundColor
        /*let imgv = UIImageView (frame: CGRect (x: -25, y: (kCurrentScreenHight - 100 - 64 - 49)/2.0, width: 30, height: 100))
        imgv.image =  UIImage (named: "illustrations_selected")
        imgv.isUserInteractionEnabled = true*/
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapClick))
        //view.addGestureRecognizer(tap)
        
        let panges = UIPanGestureRecognizer.init(target: self, action:#selector(panGestureAction(_ :)))
        view.addGestureRecognizer(panges)
        
        let ig = UIImage (named: "illustrations_selected")
        let btn = UIButton (frame: CGRect (x: 0, y: (kCurrentScreenHight - 100 - 64 - 49)/2.0, width: 30, height: 100))
        btn.setImage(ig, for: .normal)
        btn.addTarget(self, action: #selector(tapClick), for: .touchUpInside)
        view.addSubview(btn)
        
        let bgview = UIView (frame: CGRect (x: btn.frame.width, y: 0, width: view.frame.width - btn.frame.width, height: view.frame.height))
        bgview.backgroundColor = kTableviewBackgroundColor

        let _v = Bundle.main.loadNibNamed("ImgDetailView", owner: nil, options: nil)?.last as! ImgDetailView
        _v.frame = CGRect (x: 20, y: 0, width: bgview.frame.width - 40, height: bgview.frame.height)
        _v.backgroundColor = UIColor.clear
        bgview.addSubview(_v)
        view.addSubview(bgview)

        if view_init_center == nil{
            print("view.center:\(view.center)")
            view_init_center = view.center
        }
        
    }
    
    
    func panGestureAction(_ gesture:UIPanGestureRecognizer) {
        let move_x = gesture.translation(in: view).x
        let vx = gesture.velocity(in: view).x
        
        //print(vx)
        
        let left = (view_init_center?.x)! - view.center.x
        if  left <= 405 && vx < 0 {
            view.center = CGPoint.init(x: view.center.x + move_x, y: view.center.y)
            if left < 300 {
                UIView.beginAnimations(nil, context: nil)
                view.center = CGPoint.init(x: (view_init_center?.x)! - CGFloat(405), y: view.center.y)
                UIView.commitAnimations()
                isOpen = true
            }
        }else if left > 0 && vx > 0 {
            view.center = CGPoint.init(x: view.center.x + move_x, y: view.center.y)
            if left < 300 {
                UIView.beginAnimations(nil, context: nil)
                view.center = view_init_center!
                UIView.commitAnimations()
                isOpen = false
            }
        }
        
        //1214  807
        gesture.setTranslation(CGPoint.init(x: 0, y: 0), in: view)
        if (gesture.state == .ended) {
            print("end")
            print(view.center)
            let left = (view_init_center?.x)! - view.center.x
            if left < 200 && vx < 0 {
                UIView.beginAnimations(nil, context: nil)
                view.center = view_init_center!
                UIView.commitAnimations()
                isOpen = false
            }else if left > 200 && vx > 0 {
                UIView.beginAnimations(nil, context: nil)
                view.center = CGPoint.init(x: (view_init_center?.x)! - CGFloat(405), y: view.center.y)
                UIView.commitAnimations()
                isOpen = true
            }
        }
        
    }
    
    
    
    func tapClick() {
        print("tap....")
        
        if isOpen {
            isOpen = false
            UIView.beginAnimations(nil, context: nil)
            view.center = view_init_center!
            UIView.commitAnimations()
        }else{
            isOpen = true
            UIView.beginAnimations(nil, context: nil)
            view.center = CGPoint.init(x: (view_init_center?.x)! - CGFloat(405), y: view.center.y)
            UIView.commitAnimations()
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
