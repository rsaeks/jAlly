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
        //print("Device IDs: \(selectDeviceIDs)")
        //print("Serial #s: \(selectSerialNumbers)")
        //print("Asset Tags: \(selectAssetTags)")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectDeviceIDs.count + 2
        // Add one to index to allow for a blank first cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.minimumScaleFactor = 0.1
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.darkGray.cgColor
        if indexPath.row == 0 {
            // Setup our custom header with the following parameters
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textAlignment = .center
            cell.backgroundColor = UIColor(red:0.18, green:0.25, blue:0.34, alpha:1.0)
            cell.textLabel?.textColor = UIColor(red:0.76, green:0.81, blue:0.87, alpha:1.0)
            cell.textLabel?.font = UIFont(name: "Avenir", size: 18)
            cell.textLabel?.text = "Multiple Devices found.\nPlease select the device from the list below."
            return cell
        }
        else if indexPath.row == 1 {
            cell.textLabel?.numberOfLines = 1
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = UIColor.black
            cell.textLabel?.font = UIFont(name: "Avenir-Heavy", size: 18)
            cell.textLabel?.text = "Tap here to return without selecting a device"
            cell.backgroundColor = UIColor(red:0.84, green:0.26, blue:0.26, alpha:0.75)
            return cell
        }
        else {
            // Alternate row colors
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = UIColor(red:0.76, green:0.78, blue:0.81, alpha:0.5)
            }
            else {
                cell.backgroundColor = UIColor(red:0.46, green:0.53, blue:0.67, alpha:0.5)
            }
            cell.textLabel?.text = "Asset Tag: \(selectAssetTags[indexPath.row - 2])\t\tSN: \(selectSerialNumbers[indexPath.row - 2]) "
        return cell
      }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {}
        else if indexPath.row == 1 {
            dismiss(animated: true, completion: nil)
        }
        else {
            workingData.deviceID = selectDeviceIDs[indexPath.row - 2]
            dismiss(animated: true, completion: nil)
        }
    }
}
