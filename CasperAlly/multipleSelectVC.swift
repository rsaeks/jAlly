//
//  multipleSelectVC.swift
//  jAlly
//
//  Created by Randy Saeks on 11/12/17.
//  Copyright © 2017 Randy Saeks. All rights reserved.
//

import Foundation
import UIKit

class multipleSelect: UITableViewController {
    
    var selectDeviceIDs = [Int]()
    var selectSerialNumbers = [String]()
    var selectAssetTags = [String]()
    var returnedDevice = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "deviceCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectDeviceIDs.count + 1
        // Add one to index to allow for a blank first cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath)
        if indexPath.row == 0 {
            // Setup our custom header with the following parameters
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textAlignment = .center
            cell.backgroundColor = UIColor(red:0.18, green:0.25, blue:0.34, alpha:1.0)
            cell.textLabel?.textColor = UIColor(red:0.76, green:0.81, blue:0.87, alpha:1.0)
            cell.textLabel?.font = UIFont(name: "Avenir", size: 16)
            cell.textLabel?.text = "Multiple Devices found.\nPlease select the device from the list below. \n Tap this box to return without selecting a device"
            return cell
        }
        else {
            // Alternate row colors
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = UIColor(red:0.76, green:0.78, blue:0.81, alpha:0.5)
                cell.textLabel?.shadowColor = UIColor.lightGray
            }
            else {
                cell.backgroundColor = UIColor(red:0.46, green:0.53, blue:0.67, alpha:0.5)
                cell.textLabel?.shadowColor = UIColor.lightGray
            }
            cell.textLabel?.text = "Asset Tag: \(selectAssetTags[indexPath.row - 1]) SN: \(selectSerialNumbers[indexPath.row - 1]) "
        return cell
      }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            dismiss(animated: true, completion: nil)
        }
        else {
            workingData.deviceID = selectDeviceIDs[indexPath.row - 1]
            dismiss(animated: true, completion: nil)
        }
    }
}
