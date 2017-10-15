//
//  LargePicViewController.swift
//  Toolbox
//
//  Created by wyg on 2017/10/14.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class LargePicViewController: BaseViewControllerWithTable,UIWebViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    var webview:UIWebView!
    var loveBtn:UIButton!
    var largeImgCollectionView : UICollectionView!
    let ImgCollectionViewCellReuseId = "LargePicCellReuseId"
    
    var _title_1:UILabel!
    var _title_2:UILabel!
    var _title_3:UILabel!
    var index:Int = 0
    
    var pageCtr:UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBarItem()

        _init()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let v = navigationItem.titleView {
            let _l = v.viewWithTag(222) as? UILabel
            if let _l = _l {
                _l.text =  "Graphic Viewer" + " (\(titleViewValue(title: kAIRPLANE_SORTEDOPTION_KEY)))"
            }
        }
        
        pageCtr.numberOfPages = dataArray.count
        largeImgCollectionView.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .left, animated: true)
        
        displayTitle(index)
    }
    
    
    func _init() {
        let _largeflowlayout = UICollectionViewFlowLayout()
        _largeflowlayout.minimumLineSpacing = 0
        _largeflowlayout.scrollDirection = .horizontal
        _largeflowlayout.itemSize = CGSize (width: kCurrentScreenWidth, height: kCurrentScreenHeight - 64 - 40)
        largeImgCollectionView = UICollectionView.init(frame: CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: kCurrentScreenHeight - 64 - 40), collectionViewLayout: _largeflowlayout)
        largeImgCollectionView.delegate = self
        largeImgCollectionView.dataSource = self
        largeImgCollectionView.register(UINib (nibName: "LargePicCell", bundle: nil), forCellWithReuseIdentifier: ImgCollectionViewCellReuseId)
        largeImgCollectionView.backgroundColor = UIColor.black //kTableviewBackgroundColor
        largeImgCollectionView.isPagingEnabled = true
        largeImgCollectionView.showsHorizontalScrollIndicator = false
        view.addSubview(largeImgCollectionView)
        
        bottomBackgroundView()
        
        pageCtr = UIPageControl.init(frame: CGRect (x: (kCurrentScreenWidth - 200)/2, y: largeImgCollectionView.frame.maxY, width: 200, height: 40))
        pageCtr.pageIndicatorTintColor = UIColor (colorLiteralRed: 210/255.0, green: 210/255.0, blue: 210/255.0, alpha: 0.3)
        pageCtr.currentPageIndicatorTintColor = UIColor.white
        pageCtr.currentPage = 0
        view.addSubview(pageCtr)
    }
    
    func bottomBackgroundView() {
        let bottomBg = UIView (frame: CGRect (x: 0, y: largeImgCollectionView.frame.maxY - 100, width: kCurrentScreenWidth, height: 100))
        bottomBg.backgroundColor = UIColor.black
        bottomBg.alpha = 0.7
        view.addSubview(bottomBg)
        
        let title_1 = UILabel()
        title_1.translatesAutoresizingMaskIntoConstraints = false
        title_1.textAlignment = .center
        title_1.textColor = UIColor.white
        bottomBg.addSubview(title_1)
        
        let title_2 = UILabel()
        title_2.translatesAutoresizingMaskIntoConstraints = false
        title_2.textAlignment = .center
        title_2.textColor = UIColor.white
        bottomBg.addSubview(title_2)
        
        let title_3 = UILabel()
        title_3.translatesAutoresizingMaskIntoConstraints = false
        title_3.textAlignment = .left
        title_3.textColor = UIColor.white
        bottomBg.addSubview(title_3)
        _title_1 = title_1
        _title_2 = title_2
        _title_3 = title_3

        let dic = ["title_1":title_1,"title_2":title_2,"title_3":title_3]
        let con_h1 = NSLayoutConstraint.constraints(withVisualFormat: "H:|[title_1]|", options: .alignAllLeading, metrics: nil, views: dic)
        let con_h2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|[title_2]|", options: .alignAllLeading, metrics: nil, views: dic)
        let con_h3 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(30)-[title_3]", options: .alignAllLeading, metrics: nil, views: dic)
        let con_v = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[title_1(30)][title_2(30)][title_3(30)]", options: .alignAllCenterX, metrics: nil, views: dic)
        
        bottomBg.addConstraints(con_h1)
        bottomBg.addConstraints(con_h2)
        bottomBg.addConstraints(con_h3)
        bottomBg.addConstraints(con_v)
    }
    
    func displayTitle(_ atIndex:Int) {
        guard dataArray.count > 0 else {return}
        let m = dataArray[atIndex] as? SegmentModel
        guard let _m = m else{return}
        _title_1.text =  _m.toc_code //+ (_m.title == "" ? "" : ("\(_m.title)"))
        _title_2.text = "Figure " +  _m.toc_code
        
        //显示有效性（可能有多个值）
        if let cus_code = kSelectedPublication?.customer_code,let eff = _m.effrg{
            var eff_str:String = ""
            if  eff.characters.count > 0{
                let arr = eff.components(separatedBy: " ")
                for e in arr {
                    let s1 = e.substring(to: e.index(e.startIndex, offsetBy: 3))
                    let s2 = e.substring(from: s1.endIndex)
                    eff_str = eff_str + " " + "\(s1)-\(s2)"
                }
            }

            _title_3.text = "EFF:" + cus_code + eff_str
        }
        
        //小圆点索引
        pageCtr.currentPage = atIndex
    }
    
    
    //MARK: -
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImgCollectionViewCellReuseId, for: indexPath) as! LargePicCell
        let m = dataArray[indexPath.row] as! SegmentModel
        cell.fillCellWith(m)
        return cell
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        let _v = scrollView as! UICollectionView
        guard let indexpath = _v.indexPathForItem(at: offset) else{return}
        //更新其他数据
        displayTitle(indexpath.row)
        
        NotificationCenter.default.post(name: NSNotification.Name (rawValue: "notification_largepic_index_changed"), object: nil, userInfo: ["index":indexpath.row])
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
        navigationItem.rightBarButtonItems = [ritem_1]//,ritem_2
        //loveBtn = btn
        
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
