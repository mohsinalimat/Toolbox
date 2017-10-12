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
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

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
        _largeflowlayout.itemSize = CGSize (width: 370, height: 420)
        largeImgCollectionView.collectionViewLayout  = _largeflowlayout
        largeImgCollectionView.delegate = self
        largeImgCollectionView.dataSource = self
        largeImgCollectionView.register(UINib (nibName: "ImgCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImgCollectionViewCellReuseId")
        largeImgCollectionView.backgroundColor = kTableviewBackgroundColor
        largeImgCollectionView.isPagingEnabled = true
        largeImgCollectionView.showsHorizontalScrollIndicator = false
        
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.minimumLineSpacing = 5
        flowlayout.scrollDirection = .horizontal
        flowlayout.itemSize = CGSize (width: 100, height: 100)
        samllImgCollectionView.collectionViewLayout  = flowlayout
        samllImgCollectionView.delegate = self
        samllImgCollectionView.dataSource = self
        samllImgCollectionView.register(UINib (nibName: "ImgCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImgCollectionViewCellReuseId")
        samllImgCollectionView.backgroundColor = kTableviewBackgroundColor
        samllImgCollectionView.isPagingEnabled = true
        samllImgCollectionView.showsHorizontalScrollIndicator = false


    }
    
    
    //MARK: - 
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImgCollectionViewCellReuseId, for: indexPath)
        
        return cell
    }
    
    
    
    
    
    
    
    
}
