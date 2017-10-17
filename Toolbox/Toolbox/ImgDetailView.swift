//
//  ImgDetailView.swift
//  Toolbox
//
//  Created by gener on 17/10/12.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class ImgDetailView: UIView,UICollectionViewDelegate,UICollectionViewDataSource {

    @IBOutlet weak var titleLab: UILabel!
    
    @IBOutlet weak var subtitleLab: UILabel!
    
    @IBOutlet weak var largeImgCollectionView: UICollectionView!
    
    @IBOutlet weak var samllImgCollectionView: UICollectionView!
    
    let ImgCollectionViewCellReuseId = "ImgCollectionViewCellReuseId"
    let ImgSmallCellReuseId = "ImgSmallCellReuseId"
    
    var dataArray:[Any]?
    var smallIgSelectedIndex:Int = 0
    
    let large_size = CGSize(width: 370, height: kCurrentScreenHeight - 114 - 205)
    let small_size = CGSize(width: 100, height: 100)
    
    //MARK:
    override init(frame: CGRect) {
        super.init(frame: frame)        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print(#function)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func awakeFromNib() {
        _init()
    }
    
    func _init() {
        let _largeflowlayout = UICollectionViewFlowLayout()
        _largeflowlayout.minimumLineSpacing = 0
        _largeflowlayout.scrollDirection = .horizontal
        _largeflowlayout.itemSize = large_size
        largeImgCollectionView.collectionViewLayout  = _largeflowlayout
        largeImgCollectionView.delegate = self
        largeImgCollectionView.dataSource = self
        largeImgCollectionView.register(UINib (nibName: "ImgCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ImgCollectionViewCellReuseId)
        largeImgCollectionView.backgroundColor = kTableviewBackgroundColor
        largeImgCollectionView.isPagingEnabled = true
        largeImgCollectionView.showsHorizontalScrollIndicator = false
        
        let _smallflowlayout = UICollectionViewFlowLayout()
        _smallflowlayout.minimumLineSpacing = 5
        _smallflowlayout.scrollDirection = .horizontal
        _smallflowlayout.itemSize = small_size
        samllImgCollectionView.collectionViewLayout  = _smallflowlayout
        samllImgCollectionView.delegate = self
        samllImgCollectionView.dataSource = self
        samllImgCollectionView.register(UINib (nibName: "ImgSmallCell", bundle: nil), forCellWithReuseIdentifier: ImgSmallCellReuseId)
        samllImgCollectionView.backgroundColor = kTableviewBackgroundColor
        samllImgCollectionView.isPagingEnabled = true
        samllImgCollectionView.showsHorizontalScrollIndicator = false

        
        NotificationCenter.default.addObserver(self, selector: #selector(indexChanged(_ :)), name: NSNotification.Name (rawValue: "notification_largepic_index_changed"), object: nil)
    }
    
    func indexChanged(_ noti:Notification) {
        if let index = noti.userInfo?["index"] as? Int{
            largeImgCollectionView.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .left, animated: true)
            smallIgSelectedIndex = index
            displayTitle(smallIgSelectedIndex)
        }
    }
    
    
    //MARK:
    func refreshData(_ data:[Any]) {
        dataArray = data
        
        //第一次进入刷新数据默认显示第一个图片及信息
        largeImgCollectionView.reloadData()
        displayTitle(smallIgSelectedIndex)
    }
    
    func displayTitle(_ atIndex:Int) {
        let m = dataArray?[atIndex] as? SegmentModel
        guard let _m = m else{return}
        titleLab.text =  "Figure " + _m.toc_code //+ (_m.title == "" ? "" : ("\(_m.title)"))
        subtitleLab.text = _m.toc_code
        
        samllImgCollectionView.reloadData()
        if  atIndex > 2 {
            samllImgCollectionView.scrollToItem(at: IndexPath.init(row: atIndex - 2, section: 0), at: .left, animated: true)
        }else{
            samllImgCollectionView.scrollToItem(at: IndexPath (row: 0, section: 0), at: .left, animated: true)
        }
        
    }
    
    
    //MARK: - 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let dataArray = dataArray {
            return dataArray.count
        }
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == largeImgCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImgCollectionViewCellReuseId, for: indexPath) as! ImgCollectionViewCell
            let m = dataArray?[indexPath.row] as! SegmentModel
            cell.fillCellWith(m)            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImgSmallCellReuseId, for: indexPath) as! ImgSmallCell
            let m = dataArray?[indexPath.row] as! SegmentModel
            cell.fillCellWith(m)
            cell._isSelected(smallIgSelectedIndex == indexPath.row)
            return cell
        }

    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if samllImgCollectionView == collectionView {
            smallIgSelectedIndex = indexPath.row
            displayTitle(indexPath.row)
            largeImgCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        }else{//显示大图
            let vc = LargePicViewController()
            vc.view.backgroundColor = UIColor.black
            vc.dataArray = dataArray!
            vc.index = indexPath.row
            let nav = BaseNavigationController(rootViewController:vc)
            nav.navigationBar.barTintColor = UIColor.black
            nav.navigationBar.setBackgroundImage(nil, for: .default)
            UIApplication.shared.keyWindow?.rootViewController?.present(nav, animated: true, completion: nil)
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == largeImgCollectionView else {
            return
        }
        let offset = scrollView.contentOffset
        let _v = scrollView as! UICollectionView
        guard let indexpath = _v.indexPathForItem(at: offset) else{return}
        //更新其他数据
        displayTitle(indexpath.row)
        smallIgSelectedIndex = indexpath.row
    }

    
    
    
}
