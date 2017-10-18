//
//  ViewerController.swift
//  Toolbox
//
//  Created by gener on 17/6/26.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit
import SSZipArchive

class ViewerController: BaseViewControllerWithTable ,SSZipArchiveDelegate,UIWebViewDelegate{
    var currenthtml_url:String?
    var webview:UIWebView!
    var sideViewController:ViewSideController?
    var loveBtn:UIButton!
    var hasloved:Bool = false
    let SIDER_WIDTH:CGFloat = 460

    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(recnotification(_:)), name: knotification_airplane_changed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recnotification(_:)), name: knotification_publication_changed, object: nil)
        
        URLProtocol.registerClass(TestURLProtocol.self)
        
        initNavigationBarItem()
        webview = UIWebView.init(frame:  CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: kCurrentScreenHeight - 64 - 49))
        webview.delegate = self
        webview.backgroundColor = kTableviewBackgroundColor
        view.addSubview(webview)
    }

    func recnotification(_ noti:Notification)  {
        kSelectedSegment = nil
        currenthtml_url = nil
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard var urlStr = getFilePath() else {
            if currenthtml_url == nil {
                webview.isHidden = true
                loveBtn.isHidden = true
                getTapNodata();
            }else{
                hasloved = BookmarkModel.search(with: "seg_primary_id='\((kSelectedSegment?.primary_id!)!)'", orderBy: nil).count > 0
                loveBtn.isSelected = hasloved;
            }
            return
        }

        if !view.isUserInteractionEnabled {
            view.isUserInteractionEnabled = true
        }
        if webview.isHidden {
            webview.isHidden = false
            loveBtn.isHidden = false
        }
        
        for v in view.subviews {
            if v is UILabel
            {
                v.removeFromSuperview();
            }
        }
        
        Loading()
        urlStr =  urlStr.replacingOccurrences(of: " ", with: "%20")
        /*let key:String! = kAirplaneKeyValue[kAIRPLANE_SORTEDOPTION_KEY]
        let value:String! = kSelectedAirplane?.value(forKey: key) as! String!*/
        let key:String = "cec"
        let value:String! = kSelectedAirplane?.value(forKey: "customerEffectivity") as! String
        let newurl = urlStr.appending("?airplane=\(value!)&idType=\(key)")
        webview.loadRequest(URLRequest.init(url: URL.init(string: newurl)!))
        hasloved = BookmarkModel.search(with: "seg_primary_id='\((kSelectedSegment?.primary_id!)!)'", orderBy: nil).count > 0
        loveBtn.isSelected = hasloved
        addModel(m: model())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let pub_url = kSelectedPublication?.booklocalurl,let seg_url = kSelectedSegment?.content_location else {return}
        
        let htmlurl = pub_url + seg_url
        guard currenthtml_url == htmlurl else {return }
        if dataArray.count > 0 {
            print("需要显示图片")
            if sideViewController == nil{
                sideViewController = ViewSideController()
                sideViewController?.view.frame = CGRect (x: kCurrentScreenWidth - 40, y: 0, width: SIDER_WIDTH, height: kCurrentScreenHeight - 49 - 64)
                self.addChildViewController(sideViewController!)
                view.addSubview((sideViewController?.view)!)
            }
            sideViewController?.dataArray = dataArray
            sideViewController?.open(true)
        }else{
            print("不需要显示图片")
            if let vc = sideViewController {
                vc.view.removeFromSuperview()
                vc.removeFromParentViewController()
                sideViewController = nil
                vc.view.frame = CGRect (x: kCurrentScreenWidth, y: 0, width: SIDER_WIDTH, height: kCurrentScreenHeight - 49)
            }
        }
    }
    
    
    //提示无内容
    func getTapNodata() {
        let lab = UILabel.init(frame: CGRect (x: 0, y: 0, width: kCurrentScreenWidth, height: 70))
        lab.text = "NO TOC SELECTED"
        lab.textAlignment = .center
        lab.font = UIFont.boldSystemFont(ofSize: 15)
        lab.tag = 100
        lab.isUserInteractionEnabled = false
        view.backgroundColor = kTableviewBackgroundColor
        view.isUserInteractionEnabled = false
        view.addSubview(lab)
    }
    
    //MARK: -
    func initNavigationBarItem(){
        var itemArr = navigationItem.rightBarButtonItems;
        let btn = UIButton (frame: CGRect (x: 0, y: 0, width: 40, height: 40))//14 * 16
        btn.setImage(UIImage (named: "bookmarkOff"), for: .normal)
        btn.setImage(UIImage (named: "bookmark_on"), for: .selected)
        btn.addTarget(self, action: #selector(buttonClickedAction(_:)), for: .touchUpInside)
        btn.tag = 100
        
        let ritem = UIBarButtonItem (customView: btn)
        itemArr?.append(ritem)
        navigationItem.rightBarButtonItems = itemArr
        loveBtn = btn
        
        let lbtn_1 = UIButton (frame: CGRect (x: 0, y: 0, width: 40, height: 40))//19 * 19
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
        
        navigationItem.leftBarButtonItems = [fixed, litem_1,fixed,fixed,litem_2]
    }
    
    
    func buttonClickedAction(_ btn:UIButton){
        if webview.isLoading {
            print("webview loading");return
        }
        
        switch btn.tag {
            case 100:
                btn.isSelected = !btn.isSelected
                
                //是否已收藏
                let hasloved = BookmarkModel.search(with: "seg_primary_id='\((kSelectedSegment?.primary_id!)!)'", orderBy: nil).count > 0
                if !hasloved {
                    let dic = getBaseData()
                    BookmarkModel.saveToDb(with: dic)
                    HUD.show(successInfo: "添加书签")
                }else{
                    //删除记录
                  let ret = BookmarkModel.delete(with: "seg_primary_id='\((kSelectedSegment?.primary_id!)!)'")
                    if ret {
                        HUD.show(successInfo: "取消书签")
                    }
                }
            
            case 101:print("back")
            
            case 102:print("forward")
            default: break
        }
        
    }
    
    func getBaseData() -> [String:Any] {
        var dic = [String:Any]()
        dic["seg_primary_id"] = kSelectedSegment?.primary_id
        dic["seg_original_tag"] = kSelectedSegment?.original_tag
        dic["seg_toc_code"] = kSelectedSegment?.toc_id
        dic["seg_title"] = kSelectedSegment?.title
        dic["seg_content_location"] = kSelectedSegment?.content_location
        dic["pub_book_uuid"] = kSelectedPublication?.book_uuid
        dic["pub_booklocalurl"] = kSelectedPublication?.booklocalurl
        dic["pub_doc_abbreviation"] = kSelectedPublication?.doc_abbreviation
        dic["pub_document_owner"] = kSelectedPublication?.document_owner
        dic["pub_model"] = kSelectedPublication?.model
        dic["airplaneId"] = kSelectedAirplane?.airplaneId
        dic["mark_content"] = ""
        
        do{
            var tmp:[String] = []
            for m in kseg_parentnode_arr {
                tmp.append(m.primary_id)
            }
            
            let ret =  JSONSerialization.isValidJSONObject(tmp)
            guard ret == true else {
                return dic
            }
            
            let str = try JSONSerialization.data(withJSONObject: tmp, options: .prettyPrinted).base64EncodedString()
            dic["seg_parents"] = str
        }catch{
            print(error)
        }
                
        return dic
    }
    
    func model() -> BookmarkModel {
        let m = BookmarkModel()
        return m.model(with: getBaseData())
    }
    
    func addModel(m:BookmarkModel) {
        for (index,seg) in kseg_hasopened_arr.enumerated() {
            if m.seg_primary_id == seg.seg_primary_id {
                kseg_hasopened_arr.remove(at: index);break
            }
        }
        kseg_hasopened_arr.insert(m, at: 0)
    }
    
    
    //MARK: - 获取文件路径
    func getFilePath() -> String? {
        guard let pub_url = kSelectedPublication?.booklocalurl,let seg_url = kSelectedSegment?.content_location else {
            return nil
        }
        let htmlurl = pub_url + seg_url
        if let currenthtml_url = currenthtml_url {
            guard currenthtml_url != htmlurl else {return nil}
        }
        currenthtml_url = htmlurl
        getNewData(modelId: (kSelectedSegment?.primary_id)!)
        
        /*
         /var/mobile/Containers/Data/Application/3DE63D99-03B4-40D6-8CA5-581FD04C1AF1/Library/TDLibrary
         /CCA/CCAA320CCAAIPC20161101/aipc
         /75/EN75244880B.html
        */
        let s1 = ROOTPATH
        let s2 = pub_url
        let s3 = seg_url
        let htmlfullpath = s1 + s2 + s3
        let htmlzippath = htmlfullpath + ".zip"
        let htmldirpath = s1 + s2 + s3.substring(to: (s3.index((s3.startIndex), offsetBy: 3)))
        let fileExist = FileManager.default.fileExists(atPath: htmlfullpath)
        if !fileExist
        {
            print("file：\(htmlfullpath) 不存在！");
            let zipExist = FileManager.default.fileExists(atPath: htmlzippath)
            if !zipExist
            {
                print("zip路径：\(htmlzippath) 不存在！"); return nil
            }else{
                
                SSZipArchive.unzipFile(atPath: htmlzippath, toDestination: htmldirpath, delegate: self)
            }
            
        }
        
        return htmlfullpath
    }
    
    /// - parameter modelId:  当前model的主键-primary_id
    /// - parameter flushDir: 标记为是否需要清空已展开的目录数据
    func getNewData(modelId:String,flushDir:Bool? = false){
        dataArray.removeAll()
        var key_arr:[String] = [String]()
        
        //向下遍历子孙节点
        let arr:[SegmentModel] = { id in
            var tmpArr = [SegmentModel]()
            func _search(_ id:String){
                let chapter:[SegmentModel] = SegmentModel.search(with: "parent_id='\(id)'", orderBy: "toc_code asc") as! [SegmentModel]
                for m in chapter {
                    if Int(m.is_visible) == 0 && Int(m.has_content) == 0{
                        //不可见
                        _search(m.primary_id)
                    }else{
                        if !key_arr.contains(m.primary_id){
                            key_arr.append(m.primary_id)
                            tmpArr.append(m)
                        }
                    }
                }
            }
            
            _search(id)
            return tmpArr
        }(modelId)
        
        dataArray = dataArray + arr

    }
    
    
    //MARK:-
    func zipArchiveWillUnzipArchive(atPath path: String, zipInfo: unz_global_info) {
        print("zipArchiveWillUnzipArchive")
    }
    
    func zipArchiveDidUnzipArchive(atPath path: String, zipInfo: unz_global_info, unzippedPath: String) {
        print("zipArchiveDidUnzipArchive")
        
        if FileManager.default.isDeletableFile(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            }catch{
                print(error)
            }
        }else {
            print("文件删除失败")
        }

    }
    
    
    //MARK:- UIWebViewDelegate
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url  = request.url
        let fm = FileManager.default
        if let url = url {
            if url.scheme == "mpAjaxHandler" {
                print("-------------- :\(url)")
                //return false
            }
            
            let path = "\(url.path)"
            let exist = fm.fileExists(atPath: path)
            if !exist {
                let zip = path + ".zip"
                let exist = fm.fileExists(atPath: zip)
                if exist {
                    guard let des = (URL(string: path)?.deletingLastPathComponent().absoluteString) else {
                        return false
                    }
                    SSZipArchive.unzipFile(atPath: zip, toDestination: des, delegate: self)
                }
            }
        }
        
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
    
//        if let url = Bundle.main.url(forResource: "ajax_handler", withExtension:"js"){
//            do{
//                let str : String = try String.init(contentsOf: url, encoding: String.Encoding.utf8)
//                webView.stringByEvaluatingJavaScript(from: str)
//                webView.stringByEvaluatingJavaScript(from: str)
//            }catch{
//                print(error)
//            }
//            
//        }

    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("\(#function)-error：\(error.localizedDescription)")
        Dismiss()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("\(#function)")

        Dismiss()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

