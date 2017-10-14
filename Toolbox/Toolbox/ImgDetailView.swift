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

    //MARK:
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print(#function)
    }
    
    override func awakeFromNib() {
        print(#function)
        
        _init()
    }
    
    func _init() {
        let _largeflowlayout = UICollectionViewFlowLayout()
        _largeflowlayout.minimumLineSpacing = 0
        _largeflowlayout.scrollDirection = .horizontal
        _largeflowlayout.itemSize = CGSize (width: 370, height: kCurrentScreenHight - 114 - 205)
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
        _smallflowlayout.itemSize = CGSize (width: 100, height: 100)
        samllImgCollectionView.collectionViewLayout  = _smallflowlayout
        samllImgCollectionView.delegate = self
        samllImgCollectionView.dataSource = self
        samllImgCollectionView.register(UINib (nibName: "ImgSmallCell", bundle: nil), forCellWithReuseIdentifier: ImgSmallCellReuseId)
        samllImgCollectionView.backgroundColor = kTableviewBackgroundColor
        samllImgCollectionView.isPagingEnabled = true
        samllImgCollectionView.showsHorizontalScrollIndicator = false

    }
    
    //MARK:
    func refreshData(_ data:[Any]) {
        dataArray = data
        
        //每次进入刷新数据默认显示第一个图片及信息
        largeImgCollectionView.reloadData()
        samllImgCollectionView.reloadData()
    
        displayTitle(0)
    }
    
    func displayTitle(_ atIndex:Int) {
        let m = dataArray?[atIndex] as? SegmentModel
        guard let _m = m else{return}
        titleLab.text =  "Figure " + _m.toc_code //+ (_m.title == "" ? "" : ("\(_m.title)"))
        subtitleLab.text = _m.toc_code
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
            //let m = dataArray?[indexPath.row] as! SegmentModel
            //cell.fillCellWith(m)
            
            return cell
        }
        
        

    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset_x = scrollView.contentOffset
        print(offset_x)

        let _v = scrollView as! UICollectionView
        guard let indexpath = _v.indexPathForItem(at: offset_x) else{return}
        //更新其他数据
        displayTitle(indexpath.row)
    }

    
    
    
}
