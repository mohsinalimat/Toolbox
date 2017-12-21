//
//  SetterViewController.swift
//  Toolbox
//
//  Created by gener on 17/8/4.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

class SetterViewController: UITableViewController {
    
    let sectionHeadTitle:[String] = ["TOOLBOX LIBRARY","PREFERENCES",/*"DISPLAY & BRIGHTNESS"*/];
    let dataArray:[[String]] = [["Version","Copyright"],
                               ["Airplane Identifier",/*"Ghost Hand"*/],
                               //["Brightness",/*"Night Theme"*/]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        title = "关于"
        
//        print(Bundle.main.infoDictionary?["CFBundleShortVersionString"])
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return dataArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataArray[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier: "reuseIdentifier")
        }
        // Configure the cell...
        let title = dataArray[indexPath.section][indexPath.row]
        cell?.textLabel?.text = title;
        
        var detailStr = ""
        switch (indexPath.section,indexPath.row) {
        case (0,0):
            if let info = Bundle.main.infoDictionary {
                let appversion = info["CFBundleShortVersionString"]
                let buildno = info["CFBundleVersion"]
                detailStr = "\(appversion!)(build\(buildno!))"
            }

            break
        case (0,1):
            detailStr = "Copyright@2017.All rights reserved"
            break
        case (1,0):
            detailStr = kAIRPLANE_SORTEDOPTION_KEY
            break
        case (1,1):
            detailStr = kAIRPLANE_SORTEDOPTION_KEY
            break
            
        default: break
            
        }
        cell?.detailTextLabel?.text = detailStr
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
        cell?.selectionStyle = .none
        
        return cell!
    }
    

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeadTitle[section]
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
