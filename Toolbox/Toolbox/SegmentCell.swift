//
//  SegmentCell.swift
//  Toolbox
//
//  Created by gener on 17/7/21.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

let indentValueArray = [0,5,15,35,50]
let kBaseValue:CGFloat = 80.0

let kcellSelectedColor = UIColor (red: 42/255.0, green: 78/255.0, blue: 115/255.0, alpha: 1)
let kcellDefaultColor = UIColor.black
class SegmentCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var headTitleLable: UILabel!
    @IBOutlet weak var detailLable: UILabel!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var headIndentValue: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        headIndentValue.constant = kBaseValue
        detailLable.layer.cornerRadius = 5
        detailLable.layer.masksToBounds = true
        detailLable.backgroundColor = UIColor.init(red: 114/255.0, green: 50/255.0, blue: 119/255.0, alpha: 1)
        detailLable.textColor = UIColor.white
    }

    func cellIsSelected(_ b:Bool){
        headTitleLable.textColor = b ?  kcellSelectedColor :kcellDefaultColor
        titleLable.textColor = b ?  kcellSelectedColor :kcellDefaultColor
    }
    
    func fillCell(model:SegmentModel) {
        headTitleLable.text = (model.original_tag).uppercased() + " \(model.toc_code!)"
        detailLable.text = model.tocdisplayeff
        titleLable.text = model.title
        
        headIndentValue.constant = headIndentValue.constant + CGFloat( model.nodeLevel - 1) * 15

        //effrg
        guard Int(model.is_leaf)==1 ,Int(model.is_visible)==1 else {
            return
        }
        let msn:Int! = Int((kSelectedAirplane?.customerEffectivity)!)
        let eff:String = model.effrg
        if  eff.characters.count > 0{
            var b = false
            let arr = eff.components(separatedBy: " ")
            for e in arr {
                let s1 = e.substring(to: e.index(e.startIndex, offsetBy: 3))
                let s2 = e.substring(from: s1.endIndex)
                if msn >= Int(s1)! && msn <= Int(s2)!  {
                    b = true;break
                }
            }
        
            if !b {
                self.backgroundView = UIImageView.init(image: UIImage (named: "hashrow"))
            }
        }
        
    }
    
    override func prepareForReuse() {
        headIndentValue.constant = kBaseValue
        headTitleLable.textColor = kcellDefaultColor
        titleLable.textColor = kcellDefaultColor
        
        self.backgroundView = nil;
//        backgroundColor = kCellDefaultBgColor
    }
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
//        backgroundColor = kCellSelectedBgColor
        
    }
    
}
