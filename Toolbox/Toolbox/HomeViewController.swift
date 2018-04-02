//
//  HomeViewController.swift
//  Toolbox
//
//  Created by gener on 2018/3/14.
//  Copyright © 2018年 Light. All rights reserved.
//     //http://192.168.3.72:82/share/airbus/wyg5/CCA/

import UIKit
import Alamofire

let kNormalBgColor = UIColor (red: 0/255.0, green: 154/255.0, blue: 220/255.0, alpha: 1)
let ds_plist_download = LibraryPath.appending("/Application data/downloadqueuelist.plist")



class HomeViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    override var prefersStatusBarHidden: Bool {
        get {
            return true;
        }
    }
    
    @IBOutlet weak var _tableView: UITableView!
    @IBOutlet weak var enterBtn: UIButton!
    @IBAction func enterBtnAction(_ sender: UIButton) {
        
        if sender.tag == 1 {
            let tabBarController = BaseTabbarController()
            UIApplication.shared.keyWindow?.rootViewController = tabBarController
        }else {
            let ds = DataSourceManager.default
            ds.startDownload()

            _timer.fireDate = Date.distantPast

            enterBtn.isEnabled = false
            enterBtn.setTitle("更新中", for: .normal)
            enterBtn.backgroundColor = kTableviewBackgroundColor

        }
    }
    
    @IBAction func deleteAll(_ sender: AnyObject) {
        
        let vc = UIAlertController.init(title: "清空本地全部数据?",message: nil, preferredStyle: .alert)
        let action = UIAlertAction.init(title:"取消", style: .default)
        let action2 = UIAlertAction.init(title: "确定", style: .default) { (action) in
            DispatchQueue.main.async{ [weak self]  in
                guard let strongSelf = self else { return }
                HUD.show()
                Model.getUsingLKDBHelper().dropAllTable()
                
                FILESManager.default.deleteFileAt(path: ds_plist_download)
                
                //checkConnectAirplaneNet()
                strongSelf._tableView.reloadData()
                
                HUD.show(successInfo: "已全部清空")
            }

        }
        
        vc.addAction(action)
        vc.addAction(action2)
        self.navigationController?.present(vc, animated: true, completion: nil);
    }
    
    var _severVersoinInfoArr = [[String:String]]()
    var _progeresslable:UILabel = UILabel()
    var _totalNumberWillUpdate = 0//全部待更新的手册数
    var _hasProgressNumber = 0//已经完成的数
    var _timer:Timer!
    
    deinit {
        print("HomeViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         UIApplication.shared.isIdleTimerDisabled = true
        
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItems = nil
        navigationItem.title = "手册管理中心"
        
        _init();
        
        _progeresslable.frame = CGRect (x: 0, y: 0, width: 0, height: enterBtn.frame.height)
        _progeresslable.backgroundColor = kNormalBgColor
        enterBtn.addSubview(_progeresslable)
        
        //////
        _timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        _timer.fireDate = Date.distantFuture
    
    }

    func timerAction()  {

        guard _progeresslable.frame.width < enterBtn.frame.width  else {return }
        
        let _s = CGFloat.init(_hasProgressNumber) / CGFloat.init(_totalNumberWillUpdate)
        
        let old_width = _progeresslable.frame.size.width
        let real = enterBtn.frame.size.width * _s
        
        var new:CGFloat = old_width
        
        if old_width < real {
            new = real
        }else if old_width < enterBtn.frame.size.width * 0.85 {
            new =  new + 1;
        }
        
        
        UIView.animate(withDuration: 0.8) {[weak self] in
            guard let strongSelf = self else {return }
            strongSelf._progeresslable.frame.size.width = new
        }
        
    }
    
    
    
    
    
    func _init()  {
        _tableView.layer.borderWidth = 1
        _tableView.layer.borderColor = kTableviewBackgroundColor.cgColor
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.register(UINib (nibName: "HomeVersionCell", bundle: nil), forCellReuseIdentifier: "HomeVersionCellIdentifier")
        _tableView.tableFooterView = UIView()
        _tableView.rowHeight = 60
        
        _tableView.isHidden = true
        enterBtn.isHidden = true
        
        checkConnectAirplaneNet()


        NotificationCenter.default.addObserver(self, selector: #selector(startParsebook(_:)), name: NSNotification.Name (rawValue: "kNotification_start_update"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(allbookupdatecomplete(_:)), name: NSNotification.Name (rawValue: "kNotification_allbooksupdate_complete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatefileFinish(_:)), name: NSNotification.Name (rawValue: "kNotification_book_update_complete"), object: nil)
    }
    
    func checkConnectAirplaneNet()  {
        guard kDataSourceLocations.count > 0 ,Tools.isReachable() else { _Test_Show("请先在设置中连接飞机网络!");return}
        
        HUD.show(withStatus: "正在连接...")
        let url = kDataSourceLocations[0] + "apInfo.json"
        Alamofire.request(url).responseJSON(completionHandler: { (response) in
            DispatchQueue.main.async { [weak self]  in
                guard let strongSelf = self else { return }
                
                if let value = response.result.value as? [String:Any] {
                    kCurrent_connected_airplane = value
                   
                    UserDefaults.standard.setValue(value["airplaneId"]!, forKey: "the_last_connected_airplaneId");
                    UserDefaults.standard.synchronize()
                    strongSelf.navigationItem.title = "已连接到飞机:\(kCurrent_connected_airplane["airplaneRegistry"]!)";
                    
                    strongSelf.checkVersoinInfo()
                }else if response.result.isFailure {
                    print("Request Error:\(String(describing: response.result.error?.localizedDescription))")
                    HUD.show(info: "请求服务器超时!")
                }
            }
            
        })
    
    }
    
    func checkVersoinInfo()  {
        let url = kDataSourceLocations[0] + ksync_manifest
        
        let req = URLRequest.init(url: URL.init(string: url)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60)
        
        Alamofire.SessionManager.default.request(req).responseJSON { (response) in
            HUD.dismiss()
            
            DispatchQueue.main.async{ [weak self]  in
                guard let value = response.result.value as? [[String:String]] else {return}
                guard let strongSelf = self else { return }
                
                strongSelf._severVersoinInfoArr = value
                strongSelf._checkCompletedHandler(value)
            }

        }
        
        
        
        
        /*Alamofire.request(url).responseJSON(completionHandler: {(response) in
            HUD.dismiss()
            
            DispatchQueue.main.async{ [weak self]  in
                guard let value = response.result.value as? [[String:String]] else {return}
                guard let strongSelf = self else { return }
                
                strongSelf._severVersoinInfoArr = value
                strongSelf._checkCompletedHandler(value)
            }
        })*/
    }
    
    
    func _checkCompletedHandler(_ value:[[String:String]])  {
        _tableView.isHidden = false
        enterBtn.isHidden = false

        _tableView.reloadData()
        _tableView.layoutIfNeeded()
        
        let ds = DataSourceManager.default
        ds.compareJsonInfoFromLocal(kDataSourceLocations[0], info: ["sync_manifest.json":value])
        
        let plist = ds.ds_download_queue_path
        if let downloadfiles = NSKeyedUnarchiver.unarchiveObject(withFile: plist) as? [String:[String]] {
            if downloadfiles.count > 0 {//有需要下载更新的
                enterBtn.tag = 2;
                enterBtn.setTitle("更新到最新版本", for: .normal)
            }
        }
    }
    
    func _Test_Show(_ msg:String) {
        let ac = UIAlertController.init(title: msg, message: nil, preferredStyle: .alert)
        UIApplication.shared.keyWindow?.rootViewController?.present(ac, animated: false, completion: nil)
    }

    
    //MARK:-
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _severVersoinInfoArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeVersionCellIdentifier", for: indexPath) as! HomeVersionCell
        let d = _severVersoinInfoArr[indexPath.row]

        
        cell.fillCell(server: d)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = Bundle.main.loadNibNamed("HomeVersionHeaderView", owner: nil, options: nil)?.first as! UIView
        v.frame = CGRect (x: 0, y: 0, width: tableView.frame.width, height: 30)
        
        return v;
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    
    //MARK: -
    func startParsebook(_ noti:Notification) {
        print("+++++++++++ startParsebook");//return
        if let num = noti.userInfo?["filesnumber"] as?Int {
            _totalNumberWillUpdate = num
            //showUpdateVC(num)
        }
        
    }
    
    func showUpdateVC(_ num:Int = 0,type:Int = 0) {
        let rect = CGRect (x: 0, y: 0, width: 500, height: 180)
        let vc :UpdateBookViewController = UpdateBookViewController.init(nibName: "UpdateBookViewController", bundle: nil)
        vc.view.frame = rect
        vc.modalPresentationStyle = .formSheet
        vc.preferredContentSize = rect.size
        vc.totalBookssnumber = num
        vc.type = type
        self.present(vc, animated: false, completion: nil)
    }

    
    func allbookupdatecomplete(_ noti:Notification)  {
        
        _timer.invalidate()
        _timer = nil
        
        enterBtn.isEnabled = true
        
        if let arr = UserDefaults.standard.value(forKey: "willdelete_bookid") as? [String] {
            DS_Delegate().ds_deleteBooksWithId(arr);
            Model.getUsingLKDBHelper().executeSQL("VACUUM", arguments: nil)
        }
        
        self.enterBtn.tag = 1;
        self.enterBtn.setTitle("进入", for: .normal)
        self.enterBtn.backgroundColor = kNormalBgColor
        
        _progeresslable.removeFromSuperview()
        
        _tableView.reloadData()
    }
    
    
    func updatefileFinish(_ noti:Notification) {
        _hasProgressNumber = _hasProgressNumber + 1

        if  _hasProgressNumber == _totalNumberWillUpdate {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                NotificationCenter.default.post(Notification.init(name: NSNotification.Name (rawValue: "kNotification_allbooksupdate_complete"),object: nil,userInfo: ["type":0]))
                
            })
        }
    }

    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
