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
    var dataArray:[Any]?
    var _imgview:ImgDetailView!
    
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewSideController: viewDidLoad")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initSubview()
    }
    
    deinit {
        print("ViewSideController deinit")
    }
    
    func initSubview() {
        if _imgview == nil {
            view.backgroundColor =  UIColor.clear //kTableviewBackgroundColor
            let panges = UIPanGestureRecognizer.init(target: self, action:#selector(panGestureAction(_ :)))
            view.addGestureRecognizer(panges)
            
            let ig = UIImage (named: "illustrations_selected")
            let btn = UIButton (frame: CGRect (x: 0, y: (kCurrentScreenHeight - 100 - 64 - 49)/2.0, width: 30, height: 100))
            btn.setImage(ig, for: .normal)
            btn.addTarget(self, action: #selector(tapClick), for: .touchUpInside)
            view.addSubview(btn)
            
            let bgview = UIView (frame: CGRect (x: btn.frame.width, y: 0, width: view.frame.width - btn.frame.width, height: view.frame.height))
            bgview.backgroundColor = kTableviewBackgroundColor

            _imgview = Bundle.main.loadNibNamed("ImgDetailView", owner: nil, options: nil)?.last as! ImgDetailView
            _imgview.frame = CGRect (x: 20, y: 0, width: bgview.frame.width - 40, height: bgview.frame.height)
            _imgview.backgroundColor = UIColor.clear
            bgview.addSubview(_imgview)
            view.addSubview(bgview)
            if view_init_center == nil{
                //print("view.center:\(view.center)")
                view_init_center = view.center
            }
        }
        
    }
    
    //MARK: - UIPanGestureRecognizer
    func panGestureAction(_ gesture:UIPanGestureRecognizer) {
        let move_x = gesture.translation(in: view).x
        let vx = gesture.velocity(in: view).x

        let left = (view_init_center?.x)! - view.center.x
        if  left < 405 && vx < 0 {
            view.center = CGPoint.init(x: view.center.x + move_x, y: view.center.y)
            if left >= 200 {
                open()
            }
        }else if left > 0 && vx > 0 {
            view.center = CGPoint.init(x: view.center.x + move_x, y: view.center.y)
            if left <= 200 {
                close()
            }
        }
        
        //1214  807
        gesture.setTranslation(CGPoint.init(x: 0, y: 0), in: view)
        if (gesture.state == .ended) {
            let left = (view_init_center?.x)! - view.center.x
            if left <= 200 && vx < 0 {
                close()
            }else if left >= 200 && vx > 0 {
                open()
            }
        }
        
    }
    
    //MARK:-
    func open(_ refresh:Bool = false) {
        UIView.beginAnimations(nil, context: nil)
        view.center = CGPoint.init(x: (view_init_center?.x)! - CGFloat(405), y: view.center.y)
        UIView.commitAnimations()
        isOpen = true
        
        if refresh {
            _imgview.refreshData(dataArray!)
        }
    }
    
    func close() {
        UIView.beginAnimations(nil, context: nil)
        view.center = view_init_center!
        UIView.commitAnimations()
        isOpen = false
    }
    
    
    func tapClick() {
        if isOpen {
            close()
        }else{
            open()
        }
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
