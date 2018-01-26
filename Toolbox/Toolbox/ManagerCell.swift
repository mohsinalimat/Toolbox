//
//  ManagerCell.swift
//  Toolbox
//
//  Created by gener on 17/6/30.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class ManagerCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var colorFlagLable: UILabel!
    @IBOutlet weak var titleLable: UILabel!
    
    @IBOutlet weak var stitleLable: UILabel!
    @IBOutlet weak var sownerLable: UILabel!
    @IBOutlet weak var smodelLable: UILabel!
    @IBOutlet weak var sdocLable: UILabel!
    @IBOutlet weak var srevLable: UILabel!
    @IBOutlet weak var sdateLable: UILabel!
    @IBOutlet weak var openButton: UIButton!
    
    @IBOutlet weak var hide_width: NSLayoutConstraint!
    
    @IBOutlet weak var updateLable: UILabel!
    
    @IBOutlet weak var update_dateLable: UILabel!
    
    var selectedInEdit:Bool = false
    var imgv : UIImageView?
    
    var cellOpenButtonClickedHandler:((Void) -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        layer.borderColor = UIColor (red: 212/255.0, green: 212/255.0, blue: 212/255.0, alpha: 0.8).cgColor
        layer.borderWidth = 0.5
        
        titleLable.backgroundColor = UIColor (red: 43/255.0, green: 123/255.0, blue: 181/255.0, alpha: 0.7)
        
        updateLable.isHidden = true
        update_dateLable.isHidden = true
    }

    @IBAction func openBtnAction(_ sender: UIButton) {
        if let handler = cellOpenButtonClickedHandler {
            handler();
        }
        
        
    }
    
    
    override func prepareForReuse() {
        _init()
    }
    
    func fillCell(model:PublicationsModel,section:Int ,title:String = "airplaneRegistry") {
        if section == 0 {
            openButton.setImage(UIImage (named: "bookmark_note"), for: .normal)
            
            updateLable.isHidden = false
            update_dateLable.isHidden = false

        }else{
            openButton.setImage(UIImage (named: "cheveron-normal_gry"), for: .normal);
        }
        
        
        titleLable.text = model.display_title
        stitleLable.text = model.display_title
        sownerLable.text = model.document_owner
        smodelLable.text = model.model
        sdocLable.text = model.doc_number
        srevLable.text = model.revision_number
        sdateLable.text = model.revision_date
        
        let docabbr = model.doc_abbreviation
        guard let type = docabbr else {
            return
        }
        
        colorFlagLable.backgroundColor = kDOCTYPEColor[type]
    }

    func setSelectInEdit(_ b : Bool) {
        selectedInEdit = b
        let name = selectedInEdit ? "checked" : "unchecked"
        if let imgv = imgv{
            imgv.image = UIImage (named: name)
        }
        
    
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard self.isEditing else {
            let v = self.viewWithTag(500)
            v?.removeFromSuperview()
            return
        }
        
        for _c in self.subviews{
            if _c.isMember(of: NSClassFromString("UITableViewCellEditControl")!)  {//UITableViewCellEditControl
                let v = _c
                v.frame = CGRect (x: 0, y: 0, width: 30, height: v.frame.height)
                v.backgroundColor = UIColor.red
                v.removeFromSuperview()
                
                let new_v = UIView (frame: CGRect(x: 0, y: 0, width: 60, height: v.frame.height))
                //new_v.backgroundColor = UIColor.blue
                new_v.tag = 500
                self.addSubview(new_v)
                let _imgv = UIImageView (frame: CGRect (x: (new_v.frame.width - 27)/2.0, y: (new_v.frame.height - 27)/2.0, width: 27, height: 27))
                imgv = _imgv
                
                new_v.addSubview(_imgv)
            }
            
            if _c.isMember(of: NSClassFromString("UITableViewCellContentView")!)  {
                let v = _c
                v.frame = CGRect (x: 60, y: 0, width: v.frame.width + 120, height: v.frame.height)
               // hide_width.constant = 40
            }
  
        }
        
    }
    
    
    func _init() {
        bgView.backgroundColor = UIColor.white
        layer.borderWidth = 0.5
        openButton.isSelected = false
        
        let textColor = UIColor.black
        stitleLable.textColor = textColor
        sownerLable.textColor = textColor
        smodelLable.textColor = textColor
        sdocLable.textColor = textColor
        srevLable.textColor = textColor
        sdateLable.textColor = textColor
 
        updateLable.isHidden = true
        update_dateLable.isHidden = true

    }
    
    func cellIsSelected(_ selected : Bool) {
        if selected {
            //bgView.backgroundColor = kAirplaneCell_head_selected_color //UIColor (red: 43/255.0, green: 123/255.0, blue: 181/255.0, alpha: 0.7)
            layer.borderWidth = 0
            openButton.isSelected = true
            
            let textColor = kAirplaneCell_head_selected_color
            stitleLable.textColor = textColor
            sownerLable.textColor = textColor
            smodelLable.textColor = textColor
            sdocLable.textColor = textColor
            srevLable.textColor = textColor
            sdateLable.textColor = textColor
        }
        else
        {
            _init()
        }
    }

    

    
}
