//
//  ViewController.swift
//  CasperAlly
//
//  Created by Randy Saeks on 2/9/17.
//  Copyright © 2017 Randy Saeks. All rights reserved.
//

// Import frameworks
import UIKit
import Alamofire
import KeychainSwift
import BarcodeScanner
import SwiftOCR
import AVFoundation

// Create instances
let workingjss = JSSConfig()
let defaultsVC = UserDefaults()
let keychain = KeychainSwift()
var workingData = JSSData()
let JSSQueue = DispatchGroup()
let controller = BarcodeScannerController()
let scannedSN = SwiftOCR()
let lookupQueue = DispatchGroup()

var cameFromLostMode = false


class ViewController: UIViewController {

    //Setup connections to UI
    @IBOutlet weak var jssURLLabel: UILabel!
    @IBOutlet weak var jssGIDLabel: UILabel!
    @IBOutlet weak var jssUsernameLabel: UILabel!
    @IBOutlet weak var userToCheck: UITextField!
    @IBOutlet weak var snToCheck: UITextField!
    @IBOutlet weak var invNumToCheck: UITextField!
    @IBOutlet weak var iOSVersionLabel: UILabel!
    @IBOutlet weak var batteryLevelLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var freeSpaceLabel: UILabel!
    @IBOutlet weak var deviceIDLabel: UILabel!
    @IBOutlet weak var deviceMACLabel: UILabel!
    @IBOutlet weak var deviceIPLabel: UILabel!
    @IBOutlet weak var deviceInventorylabel: UILabel!
    @IBOutlet weak var warrantyExpiresLabel: UILabel!
    @IBOutlet weak var updateInventoryButton: UIButton!
    @IBOutlet weak var sendBlankPushButton: UIButton!
    @IBOutlet weak var removeRestritionsButton: UIButton!
    @IBOutlet weak var reapplyRestrictionsButton: UIButton!
    @IBOutlet weak var enableLostModeButton: actionButton!
    @IBOutlet weak var disableLostMode: actionButton!
    @IBOutlet weak var restartDeviceButton: UIButton!
    @IBOutlet weak var shutdownDeviceButton: UIButton!
    @IBOutlet weak var scanBarcodeButton: UIButton!
    @IBOutlet weak var batteryStatusIcon: UIImageView!
    @IBOutlet weak var freeSpaceStatusIcon: UIImageView!
    @IBOutlet weak var warrantyExpiresIcon: UIImageView!
    @IBOutlet weak var lookupUserButton: scanButton!
    @IBOutlet weak var lookupSNButton: scanButton!
    @IBOutlet weak var lookupINVNumButton: scanButton!
    @IBOutlet weak var scanSNOCRButton: scanButton!
    @IBOutlet weak var deviceModelLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var openInJSSButton: UIButton!
    
    

    override func viewDidAppear(_ animated: Bool) {
        workingData.deviceID == 0 ? nil : self.getDetails()
        updateUI()
        scanSNOCRButton.layer.borderWidth = 0
    }
    
    @IBAction func clearDataPressed(_ sender: Any) { resetUI() }
    
    
    //// ------------------------------------
    //
    // --- CODE TO PROCESS INPUTS BEGIN ---
    //
    //// ------------------------------------
        
    // Run this function when the "Lookup User" Button is pressed
    @IBAction func userToCheckPressed(_ sender: UIButton) {
        if !(userToCheck.text?.isEmpty)! {
            lookupButtonsReset()
            snToCheck.text = "looking up ..."
            invNumToCheck.text = "looking up ..."
            workingData = JSSData()
            sender.layer.borderColor = warnColor.cgColor
            workingData.user = userToCheck.text!
            lookupData(parameterToCheck: workingData.user, passedItem: "username")
            JSSQueue.notify(queue: DispatchQueue.main, execute: {
                self.displayData(theButton: sender)
                print("--- JSSQueue notify line 96 ---")
            } )
        }
        resetButtons()
    }
    
    // Run this function when the "Lookup SN" Button is pressed
    @IBAction func snToCheckPressed(_ sender: UIButton) {
        if !(snToCheck.text?.isEmpty)! {
            lookupButtonsReset()
            userToCheck.text = "looking up ..."
            invNumToCheck.text = "looking up ..."
            workingData = JSSData()
            sender.layer.borderColor = warnColor.cgColor
            workingData.deviceSN = snToCheck.text!
            lookupData(parameterToCheck: workingData.deviceSN, passedItem: "serialnumber")
            JSSQueue.notify(queue: DispatchQueue.main, execute: {
                self.displayData(theButton: sender)
                print("--- JSSQueue notify line 114 ---")
            } )
        }
        resetButtons()
    }
    
    @IBAction func lookupInventoryNumber(_ sender: UIButton) {
        if !(invNumToCheck.text?.isEmpty)! {
            lookupButtonsReset()
            userToCheck.text = "looking up ..."
            snToCheck.text = "looking up ..."
            workingData = JSSData()
            sender.layer.borderColor = warnColor.cgColor
            workingData.deviceInventoryNumber = invNumToCheck.text!
            lookupData(parameterToCheck: workingData.deviceInventoryNumber, passedItem: "assettag")
            JSSQueue.notify(queue: DispatchQueue.main, execute: {
                self.displayData(theButton: sender)
                print("--- JSSQueue notify line 131 ---")
            } )
        }
        resetButtons()
    }
    
    //// ------------------------------------
    //
    // --- CODE TO PROCESS INPUTS END ---
    //
    //// ------------------------------------
    
    //// ------------------------------------
    //
    // --- CODE TO PERFORM ACTIONS BEGINS ---
    //
    //// ------------------------------------
    
    @IBAction func updateInventoryPressed(_ sender: UIButton) {
        setupButtons(buttonWidth: 2)
        updateInventoryButton.layer.borderColor = warnColor.cgColor
            Alamofire.request(workingjss.jssURL + devAPIUpdateInventoryPath + String(workingData.deviceID), method: .post).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseString { response in
            if (response.result.isSuccess) {
                sender.layer.borderColor = successColor.cgColor
            }
            else {
                sender.layer.borderColor = failColor.cgColor
                }
        }
    }
    
    @IBAction func sendBlankPushPressed(_ sender: UIButton) {
        setupButtons(buttonWidth: 2)
        sendBlankPushButton.layer.borderColor = warnColor.cgColor
        Alamofire.request(workingjss.jssURL + devAPIBlankPushPath + String(workingData.deviceID), method: .post).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseString { response in
            if(response.result.isSuccess) {
                sender.layer.borderColor = successColor.cgColor
            }
            else {
                sender.layer.borderColor = failColor.cgColor
            }
        }
    }
    
    @IBAction func removeRestrictionsPressed(_ sender: UIButton) {
        setupButtons(buttonWidth: 2)
        removeRestritionsButton.layer.borderColor = warnColor.cgColor
        struct RawDataEncoding: ParameterEncoding {
            public static var `default`: RawDataEncoding { return RawDataEncoding() }
            public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
                var request = try urlRequest.asURLRequest()
                request.httpBody = "\(devGroupAdditionLeft)\(String(workingData.deviceID))\(devGroupAdditionRight)".data(using: String.Encoding.utf8, allowLossyConversion: false)
                return request
            }
        }
        Alamofire.request(workingjss.jssURL + devAPIPath + workingjss.exclusinGID, method: .put, encoding: RawDataEncoding.default, headers: xmlHeaders).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword)
            .responseString { response in
                if (response.result.isSuccess) {
                    sender.layer.borderColor = successColor.cgColor
                }
                else {
                    sender.layer.borderColor = failColor.cgColor
                }
        }
    }
    
    @IBAction func reapplyRestrictionsPressed(_ sender: UIButton) {
        setupButtons(buttonWidth: 2)
        reapplyRestrictionsButton.layer.borderColor = warnColor.cgColor
        struct RawDataEncoding: ParameterEncoding {
            public static var `default`: RawDataEncoding { return RawDataEncoding() }
            public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
                var request = try urlRequest.asURLRequest()
                request.httpBody = "\(devGroupDeletionLeft)\(String(workingData.deviceID))\(devGroupDeletionRight)".data(using: String.Encoding.utf8, allowLossyConversion: false)
                return request
            }
        }
        Alamofire.request(workingjss.jssURL + devAPIPath + workingjss.exclusinGID, method: .put, encoding: RawDataEncoding.default, headers: xmlHeaders).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword)
            .responseString { response in
                if (response.result.isSuccess) {
                    sender.layer.borderColor = successColor.cgColor
                }
                else {
                    sender.layer.borderColor = failColor.cgColor
                }
        }
    }
    
    @IBAction func restartDevicePressed(_ sender: UIButton) {
        setupButtons(buttonWidth: 2)
        restartDeviceButton.layer.borderColor = warnColor.cgColor
        Alamofire.request(workingjss.jssURL + devRestartPath + String(workingData.deviceID), method: .post).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseString { response in
            if(response.result.isSuccess) {
                sender.layer.borderColor = successColor.cgColor
            }
            else {
                sender.layer.borderColor = failColor.cgColor
            }
        }
    }
    
    @IBAction func shutdownDevicePressed(_ sender: UIButton) {
        setupButtons(buttonWidth: 2)
        shutdownDeviceButton.layer.borderColor = warnColor.cgColor
        Alamofire.request(workingjss.jssURL + devShutdownPath + String(workingData.deviceID), method: .post).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseString { response in
            if(response.result.isSuccess) {
                sender.layer.borderColor = successColor.cgColor
            }
            else {
                sender.layer.borderColor = failColor.cgColor
            }
        }
    }
    
    //// ------------------------------------
    //
    // --- CODE TO PERFORM ACTIONS ENDS ---
    //
    //// ------------------------------------
    
    //// ------------------------------------
    //
    // --- BARCODE SCANNING BEGIN ---
    //
    //// ------------------------------------
    
    @IBAction func scanBarCodePressed(_ sender: Any) {
        workingData = JSSData()
        controller.reset()
        controller.codeDelegate = self
        controller.errorDelegate = self
        controller.dismissalDelegate = self
        present(controller, animated: true, completion: nil)
    }
    
    //// ------------------------------------
    //
    // --- BARCODE SCANNING END ---
    //
    //// ------------------------------------
    

    @IBAction func scanSNPressed(_ sender: Any) {
//            workingData = JSSData()
//            if let myImage = UIImage(named: "sample") {
//            scannedSN.characterWhiteList = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
//            scannedSN.recognize(myImage) { result in
//            }
//        }
    }
    
    
    //// ------------------------------------
    //
    // --- LOOKUP DATA BEGIN
    //
    //// ------------------------------------
    
    func lookupData (parameterToCheck: String, passedItem: String) {
        dissmissKeyboard()
        Alamofire.request(workingjss.jssURL + matchPath + parameterToCheck, method: .get, headers: headers)
            .authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseJSON { response in
                if (response.result.isSuccess) {
                    if let outerDict = response.result.value as? Dictionary <String, AnyObject> {
                        if let mobileDevice = outerDict[workingjss.mobileDevicesKey] as? [Dictionary<String,AnyObject>] {
                            if mobileDevice.count > 0 {
                                if mobileDevice.count == 1 {
                                    if let deviceID = mobileDevice[0][workingjss.idKey] as? Int {
                                        print("One mobile device found")
                                        // Added to (hopefully) prevent crash on unique barcode
                                        //lookupQueue.enter()
                                        //print("--- lookupQueue Enter via line 298 ---")
                                        self.snToCheck.text = "looking up ..."
                                        self.invNumToCheck.text = "looking up ..."
                                        workingData.deviceID = deviceID
                                        self.getDetails()
                                    }
                                }

                                else if passedItem == "serialnumber" && mobileDevice.count > 1 {
                                    print("This isn't right ... only one serial number is allowed")
                                }
                                    
                                else if mobileDevice.count > 1 {
                                    print("Multiple mobile devices found")
                                    var IDAssetTags = [Int: String] ()
                                    var deviceIDs = [Int]()
                                    var serialNumbers = [String]()
                                    var assetTags = [String]()
                                    var deviceModels = [String]()
                                    var indexModel = [Int: String] ()
                                    var deviceNames = [Int: String]()
                                    //var testArray = [String]()
                                    lookupQueue.enter()
                                    print("--- LookupQueue Entered line 320 ---")
                                    var counter = 0
                                    for x in 0..<mobileDevice.count {
                                        deviceIDs.append(mobileDevice[x][workingjss.idKey] as! Int)
                                        serialNumbers.append(mobileDevice[x][workingjss.serialNumberKey] as! String)
                                        //print("Data for device \(x) is JSs ID number: \(mobileDevice[x][workingjss.idKey]) and serial number: \(mobileDevice[x][workingjss.serialNumberKey])")
                                        Alamofire.request(workingjss.jssURL + devAPIMatchPathID + String(deviceIDs[x]), method: .get, headers: headers).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseJSON { response in
                                            if (response.result.isSuccess) {
                                                if let outerDict = response.result.value as? Dictionary <String, AnyObject> { // Begin response JSON dict
                                                    if let mobileDeviceData = outerDict[workingjss.mobileDeviceKey] as? Dictionary <String,AnyObject> { // Begin mobile_device JSON dict
                                                        if let generalData = mobileDeviceData[workingjss.generalKey] as? Dictionary <String, AnyObject> { // Begin general JSON dict
                                                            if let model_name = generalData[workingjss.deviceModelNameKey] as? String {
//                                                                print("Got a value for model on device \(x)")
                                                                indexModel[x] = model_name
                                                            }
                                                            if let device_name = generalData[workingjss.deviceNameKey] as? String{
                                                                print("Got device name \(device_name) for device number \(x)")
                                                                deviceNames[x] = device_name
                                                            }
                                                            if let asset_tag = generalData[workingjss.inventoryKey] as? String {
                                                                if asset_tag == "" {
                                                                    //print("Asset Tag not found")
                                                                    //assetTags.append("Not Found")
                                                                    IDAssetTags[deviceIDs[x]] = "Not Found"
//                                                                    testArray.append(String(deviceIDs[x]))
//                                                                    testArray.append("Not Found")
                                                                    counter = counter + 1
                                                                    if counter == (mobileDevice.count) {
                                                                        lookupQueue.leave()
                                                                        print("--- LookupQueue left line 341 ---")
                                                                    }
                                                                }
                                                                else {
                                                                    //print("Counter value is \(counter) and Asset tag is: \(asset_tag)")
                                                                    //print("Asset tag returned for device ID: \(deviceIDs[x]) is: \(asset_tag)")
                                                                    //assetTags.append(asset_tag)
                                                                    IDAssetTags[deviceIDs[x]] = asset_tag
//                                                                    testArray.append(String(deviceIDs[x]))
//                                                                    testArray.append(asset_tag)
                                                                    counter = counter + 1
                                                                    if counter == (mobileDevice.count) {
                                                                        lookupQueue.leave()
                                                                        print("--- LookupQueue left line 354 ---")
                                                                    }
                                                                }
                                                            }
                                                        } // Close our general JSON dict
                                                    } // Close our mobile_device JSON dict
                                                } // Close our response JSON
                                            } // Close our successful result
                                        }
                                    }
                                    lookupQueue.notify(queue: DispatchQueue.main, execute: {
                                        print("--- LookupQueue notified ---")
                                        print("In lookupQueue notifier to handle multiple IDs")
                                        print(IDAssetTags)
                                        print(indexModel)
                                        print(deviceNames)
                                        //print("In loookup queue")
                                        //print(testArray)
//                                        for x in 0..<deviceIDs.count {
//                                            //print("Looking at matches for ID array at index \(x)")
//                                            for y in 0..<deviceIDs.count {
//                                                //print("Looking for match in tempArray at index \(y)")
//                                                if String(deviceIDs[x]) == testArray[y*2] {
//                                                    //print("Found match at position: \(y)")
//                                                    //print("Value is: \(testArray[(2*y) + 1])")
//                                                    assetTags.append(testArray[(2*y) + 1])
//                                                }
//                                            }
//                                        }
                                        
                                        let selectVC: multipleSelect = multipleSelect()
                                        selectVC.selectDeviceIDs = deviceIDs
                                        selectVC.selectSerialNumbers = serialNumbers
                                        selectVC.selectAssetTags = assetTags
                                        selectVC.selectIDAssetTags = IDAssetTags
                                        selectVC.selectParameterToCheck = parameterToCheck
                                        selectVC.selectModel = deviceModels
                                        selectVC.selectindexModel = indexModel
                                        selectVC.selectDeviceName = deviceNames
                                        
                                        self.snToCheck.text = ""
                                        self.invNumToCheck.text = ""
                                        self.present(selectVC, animated: true, completion: nil)
                                    } )
                                }
                                
                            }
                            else {
                                self.notFound(notFoundItem: parameterToCheck, ItemType: passedItem)
                            }
                        }
                    }
                }
        }
    }
    
    func getDetails() {
        Alamofire.request(workingjss.jssURL + devAPIMatchPathID + String(workingData.deviceID), method: .get, headers: headers).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseJSON { response in
            if (response.result.isSuccess) {
                if let outerDict = response.result.value as? Dictionary <String, AnyObject> { // Begin response JSON dict
                    if let mobileDeviceData = outerDict[workingjss.mobileDeviceKey] as? Dictionary <String,AnyObject> { // Begin mobile_device JSON dict
                        if let generalData = mobileDeviceData[workingjss.generalKey] as? Dictionary <String, AnyObject> { // Begin general JSON dict
                            if let ip_address = generalData[workingjss.ipAddressKey] as? String {
                                workingData.deviceIPAddress = ip_address
                            }
                            if let epochTime = generalData[workingjss.epochInventroryTimekey] as? Double {
                                workingData.lastInventoryEpoc = epochTime/1000
                                let date = Date(timeIntervalSince1970: workingData.lastInventoryEpoc)
                                let dateFormat = DateFormatter()
                                dateFormat.dateFormat = "E MM/dd/YY HH:mm a"
                                dateFormat.timeZone = TimeZone.current
                                workingData.lastInventoryEpocFormatted = dateFormat.string(from: date)
                            }
                            if let model_name = generalData[workingjss.deviceModelNameKey] as? String {
//                                print("Found device Model: \(model_name)")
                                workingData.deviceModel = model_name
                            }
//                            if let device_name = generalData[workingjss.deviceNameKey] as? String {
//                                workingData.deviceName = device_name
//                            }
                            
                            if let asset_tag = generalData[workingjss.inventoryKey] as? String {
                                (workingData.deviceInventoryNumber, self.invNumToCheck.text) = (asset_tag, asset_tag)
                            }
                            if let deviceName = generalData[workingjss.deviceNameKey] as? String {
                                workingData.deviceName = deviceName
                            }
                            if let deviceSN = generalData[workingjss.serialNumberKey] as? String {
                                (workingData.deviceSN, self.snToCheck.text) = (deviceSN, deviceSN)
                            }
                            if let deviceMAC = generalData[workingjss.MACAddressKey] as? String {
                                workingData.deviceMAC = deviceMAC
                            }
                            if let deviceID = generalData[workingjss.idKey] as? Int {
                                workingData.deviceID = deviceID
                            }
                            if let iOSVersion = generalData[workingjss.osVersionKey] as? String {
                                workingData.iOSVersion = iOSVersion
                            }
                            if let batteryLevel = generalData[workingjss.batteryLevelKey] as? Int {
                                workingData.batteryLevel = batteryLevel
                            }
                            if let freeSpace = generalData[workingjss.freeSpaceKey] as? Int {
                                workingData.freeSpace = freeSpace
                            }
                            if let percentUsed = generalData[workingjss.percentUsedKey] as? Int {
                                workingData.percentUsed = percentUsed
                            }
                        } // Close our general JSON dict
                        if let location = mobileDeviceData[workingjss.locationKey] as? Dictionary <String, AnyObject> { // Begin location JSON dict
                            if let username = location[workingjss.usernameKey] as? String {
                                (workingData.user, self.userToCheck.text) = (username, username)
                            }
                            if let fullName = location[workingjss.realNameKey] as? String {
                                workingData.realName = fullName
                            }
                        } // Close our location JSON dict
                        if let purchasing = mobileDeviceData[workingjss.purchasingKey] as? Dictionary <String, AnyObject> { // Begin purchasing JSON
                            if let warrantyExpires = purchasing[workingjss.epochWarrantyExpiresKey] as? Double {
                                workingData.warrantyExpiresEpoch = warrantyExpires / 1000
                                let warrantyDate = Date(timeIntervalSince1970: workingData.warrantyExpiresEpoch)
                                let warrantyDateFormat = DateFormatter()
                                warrantyDateFormat.dateFormat = "E MM/dd/YY"
                                warrantyDateFormat.timeZone = TimeZone.current
                                workingData.warrantyExpiresEpochFormatted = warrantyDateFormat.string(from: warrantyDate)
                            }
                        } // Close our purchasing JSON
                    } // Close our mobile_device JSON dict
                } // Close our response JSON
                ///
                ///
                ///
                print("Finished Getting details ... now to test if we came from lost mode screen" )
                if !cameFromLostMode  {
                    print("Did not come from lost mode screen")
                    JSSQueue.leave()
                    print("--- JSSQueue left line 476 ---")
                    cameFromLostMode = false
                }
                else {
                    print("Came from lost mode VC")
                    //print("Resetting to false")
                    cameFromLostMode = false
                }
            } // Close our successful result
            else {
                JSSQueue.leave()
                print("--- JSSQueue left line 487 ---")
            }
        }
    }
    
    func notFound(notFoundItem: String, ItemType: String) {
        var message: String = ""
        switch ItemType {
        case "username":
            message = userNameNotFound
            lookupUserButton.layer.borderColor = failColor.cgColor
        case "serialnumber":
            message = deviceSNNotFound
            lookupSNButton.layer.borderColor = failColor.cgColor
        case "assettag":
            message = inventoryNumNotFound
            lookupINVNumButton.layer.borderColor = failColor.cgColor
        default:
            message = "Other uncaught error occured"
        }
        let notFoundDialog = UIAlertController(title: "Not Found", message: "\(notFoundItem)\(message) ", preferredStyle: UIAlertControllerStyle.alert)
        notFoundDialog.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(notFoundDialog, animated: true)
        JSSQueue.leave()
        print("--- JSSQueue left line 510 ---")
    }
    
    //// ------------------------------------
    //
    // --- LOOKUP DATA END
    //
    //// ------------------------------------
    
    //// ------------------------------------
    //
    // --- UI RELATED FUNCTIONS BEGIN
    //
    //// ------------------------------------
    
    func dissmissKeyboard () {
        JSSQueue.enter()
        print("--- JSSQueue entered line 527 ---")
        view.endEditing(true)
    }
    
    func displayData(theButton: UIButton) {
        print("Entering display data function on line 529")
        batteryStatusIcon.image = nil
        freeSpaceStatusIcon.image = nil
        warrantyExpiresIcon.image = nil
        deviceIDLabel.text = String(workingData.deviceID)
        iOSVersionLabel.text = workingData.iOSVersion
        deviceMACLabel.text = workingData.deviceMAC
       
        if workingData.batteryLevel != 101 {
            theButton.layer.borderColor = successColor.cgColor
        }
        
        // Print & Format coloring of our battery level
        batteryLevelLabel.text = String(workingData.batteryLevel) + " %"
        if (workingData.batteryLevel <= Settings.shared.battCritLevel) {
            batteryStatusIcon.isHidden = false
            batteryStatusIcon.image = #imageLiteral(resourceName: "red")
        }
        else if (workingData.batteryLevel <= Settings.shared.battWarnLevel) {
            batteryStatusIcon.isHidden = false
            batteryStatusIcon.image = #imageLiteral(resourceName: "orange")
        }
        
        // Determine color of Free Space text based on percent used
        if (workingData.percentUsed >= Settings.shared.freespaceCritLevel) {
            freeSpaceStatusIcon.isHidden = false
            freeSpaceStatusIcon.image = #imageLiteral(resourceName: "red")
        }
        else if (workingData.percentUsed >= Settings.shared.freespaceWarnLevel) {
            freeSpaceStatusIcon.isHidden = false
            freeSpaceStatusIcon.image = #imageLiteral(resourceName: "orange")
        }
        
        // Display free space as either GB or MB
        if (workingData.freeSpace % 1024 > 1) { freeSpaceLabel.text = String.localizedStringWithFormat("%.2f %@", Float(workingData.freeSpace) / Float(1024), " GB") }
        else { freeSpaceLabel.text = "\(workingData.freeSpace) MB" }
        
        fullNameLabel.text = workingData.realName
        snToCheck.text = workingData.deviceSN
        userToCheck.text = workingData.user
        deviceIPLabel.text = workingData.deviceIPAddress
        deviceInventorylabel.text = workingData.lastInventoryEpocFormatted
        warrantyExpiresLabel.text = workingData.warrantyExpiresEpochFormatted
        deviceModelLabel.text = workingData.deviceModel
        deviceNameLabel.text = workingData.deviceName
        openInJSSButton.isHidden = false
        
//        let urlToDevice = NSMutableAttributedString(string:workingData.deviceName)
//        urlToDevice.addAttribute(.link, value: "\(workingjss.jssURL)/mobileDevices.html?id=\(workingData.deviceID)&o=r", range: NSRange(location: 0, length: workingData.deviceName.count))
//
//
//        print("Creating URL to the device")
//        print("\(workingjss.jssURL)/mobileDevices.html?id=\(workingData.deviceID)&o=r")
//
        //deviceNameLabel.attributedText = urlToDevice
        //deviceNameLabel.isUserInteractionEnabled = true

        
        
        if (workingData.warrantyExpiresEpoch == 0.0) {
            warrantyExpiresLabel.text = "Not provided in JSS"
        }
        else if (Date().timeIntervalSince1970 > workingData.warrantyExpiresEpoch) {
            warrantyExpiresIcon.isHidden = false
            warrantyExpiresIcon.image = #imageLiteral(resourceName: "red")
        }
        else if ((workingData.warrantyExpiresEpoch - Date().timeIntervalSince1970) < 2678400) {
            warrantyExpiresIcon.isHidden = false
            warrantyExpiresIcon.image = #imageLiteral(resourceName: "orange")
        }
        enableButtons()
    }
    
    func enableButtons() {
        updateInventoryButton.isEnabled = true
        sendBlankPushButton.isEnabled = true
        if jssGIDLabel.text == "JSS GID HERE" || jssGIDLabel.text == "" {
            removeRestritionsButton.isEnabled = false
            reapplyRestrictionsButton.isEnabled = false
        }
        else {
            removeRestritionsButton.isEnabled = true
            reapplyRestrictionsButton.isEnabled = true
        }
//        removeRestritionsButton.isEnabled = true
//        reapplyRestrictionsButton.isEnabled = true
        restartDeviceButton.isEnabled = true
        shutdownDeviceButton.isEnabled = true
        enableLostModeButton.isEnabled = true
        disableLostMode.isEnabled = true
        setupButtons(buttonWidth: 2)
    }
    
    func disableButtons() {
        updateInventoryButton.isEnabled = false
        sendBlankPushButton.isEnabled = false
        removeRestritionsButton.isEnabled = false
        reapplyRestrictionsButton.isEnabled = false
        restartDeviceButton.isEnabled = false
        shutdownDeviceButton.isEnabled = false
        enableLostModeButton.isEnabled = false
        disableLostMode.isEnabled = false
        setupButtons(buttonWidth: 0)
    }
    
    func resetButtons() {
        updateInventoryButton.layer.borderColor = UIColor.lightGray.cgColor
        sendBlankPushButton.layer.borderColor = UIColor.lightGray.cgColor
        removeRestritionsButton.layer.borderColor = UIColor.lightGray.cgColor
        reapplyRestrictionsButton.layer.borderColor = UIColor.lightGray.cgColor
        restartDeviceButton.layer.borderColor = UIColor.lightGray.cgColor
        shutdownDeviceButton.layer.borderColor = UIColor.lightGray.cgColor
        enableLostModeButton.layer.borderColor = UIColor.lightGray.cgColor
        disableLostMode.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func setupButtons(buttonWidth: Int) {
        updateInventoryButton.layer.borderWidth = CGFloat(buttonWidth)
        sendBlankPushButton.layer.borderWidth = CGFloat(buttonWidth)
        removeRestritionsButton.layer.borderWidth = CGFloat(buttonWidth)
        reapplyRestrictionsButton.layer.borderWidth = CGFloat(buttonWidth)
        restartDeviceButton.layer.borderWidth = CGFloat(buttonWidth)
        shutdownDeviceButton.layer.borderWidth = CGFloat(buttonWidth)
        enableLostModeButton.layer.borderWidth = CGFloat(buttonWidth)
        disableLostMode.layer.borderWidth = CGFloat(buttonWidth)
    }
    
    func updateUI() {
        let testURL = defaultsVC.string(forKey: "savedJSSURL")
        let testExclusionGID = defaultsVC.string(forKey: "savedExclusionGID")
        let testJSSUsername = defaultsVC.string(forKey: "savedJSSUsername")
        let testJSSPassword = keychain.get("savedJSSPassword")
        
        if testURL != nil {
            (workingjss.jssURL, jssURLLabel.text) = (testURL!, testURL!)
        }
        if testExclusionGID != nil {
            (workingjss.exclusinGID, jssGIDLabel.text)  = (testExclusionGID!, testExclusionGID!)
        }
        if testJSSUsername != nil {
            (workingjss.jssUsername, jssUsernameLabel.text) = (testJSSUsername!, testJSSUsername!)
        }
        if testJSSPassword != nil {
            workingjss.jssPassword = testJSSPassword!
        }
        if Settings.shared.snToCheck != nil {
            snToCheck.text = Settings.shared.snToCheck
        }
    }
    
    func resetUI () {
        resetButtons()
        userToCheck.text = ""
        snToCheck.text = ""
        invNumToCheck.text = ""
        deviceIDLabel.text = "Device ID"
        deviceMACLabel.text = "Device MAC"
        batteryLevelLabel.text = "Battery %"
        fullNameLabel.text = "Full Name"
        deviceIPLabel.text = "Device IP"
        deviceInventorylabel.text = "Last Inventory"
        Settings.shared.snToCheck = ""
        iOSVersionLabel.text = "iOS Version"
        warrantyExpiresLabel.text = "Warranty Expires"
        freeSpaceLabel.text = "Free Space"
        batteryLevelLabel.text = "Battery %"
        deviceNameLabel.text = "Device Name"
        disableButtons()
        batteryLevelLabel.textColor = UIColor.black
        freeSpaceLabel.textColor = UIColor.black
        warrantyExpiresLabel.textColor = UIColor.black
        batteryStatusIcon.image = nil
        freeSpaceStatusIcon.image = nil
        warrantyExpiresIcon.image = nil
        openInJSSButton.isHidden = true
        workingData = JSSData()
        lookupButtonsReset()
    }
    
    func lookupButtonsReset() {
        lookupUserButton.layer.borderColor = UIColor.lightGray.cgColor
        lookupSNButton.layer.borderColor = UIColor.lightGray.cgColor
        lookupINVNumButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @IBAction func enableLostModePressed(_ sender: UIButton) {
        performSegue(withIdentifier: "lostModVCSeg", sender: self)
    }

    
    @IBAction func showDeviceInJSSTapped(_ sender: Any) {
        print("Tapped Button to show in JSS")
        self.view.endEditing(true)
        if let deviceURL = URL(string: "\(workingjss.jssURL)/mobileDevices.html?id=\(workingData.deviceID)&o=r")
        {
            UIApplication.shared.open(deviceURL)
        }
    }
    
    
    @IBAction func disableLostModePressed(_ sender: UIButton) {
        print("Disable Lost mode pressed for device ID: \(workingData.deviceID)")
        sender.layer.borderColor = warnColor.cgColor
        let headers = [ "Content-Type":"application/xml" ]
        // Custom Body Encoding
        struct RawDataEncoding: ParameterEncoding {
            public static var `default`: RawDataEncoding { return RawDataEncoding() }
            public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
                var request = try urlRequest.asURLRequest()
                request.httpBody = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><mobile_device_command><general><command>DisableLostMode</command></general><mobile_devices><mobile_device><id>\(workingData.deviceID)</id></mobile_device></mobile_devices></mobile_device_command>".data(using: String.Encoding.utf8, allowLossyConversion: false)
                return request
            }
        }
        // Fetch Request
        Alamofire.request(workingjss.jssURL + devLostModePath, method: .post, encoding: RawDataEncoding.default, headers: headers)
            .authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword)
            .validate(statusCode: 200..<300)
            .responseString { response in
                if (response.result.error == nil) {
                    sender.layer.borderColor = successColor.cgColor
                    print("Successful Command")
                    //debugPrint("HTTP Response Body: \(response.data)")
                }
                else {
                    sender.layer.borderColor = failColor.cgColor
                    print("Failed Command")
                    //debugPrint("HTTP Request failed: \(response.result.error)")
                }
        }
    }
}



    
    
    //// ------------------------------------
    //
    // --- UI RELATED FUNCTIONS END
    //
    //// ------------------------------------

////
//
// Barcode Scanning extensions
//
////
extension ViewController: BarcodeScannerCodeDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
        workingData.deviceInventoryNumber = code
        self.invNumToCheck.text = workingData.deviceInventoryNumber
        //userToCheck.text = "looking up ..."
        //snToCheck.text = "looking up ..."
        controller.dismiss(animated: true, completion: nil)
        resetButtons()
        //lookupINVNumButton.layer.borderColor = warnColor.cgColor
        //ookupData(parameterToCheck: workingData.deviceInventoryNumber, passedItem: "assettag")
        JSSQueue.notify(queue: DispatchQueue.main, execute: {
            //self.displayData(theButton: self.lookupINVNumButton)
            print("--- JSSQueue notified line 750 ---")
        } )
    }
}

extension ViewController: BarcodeScannerErrorDelegate {
    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
        print(error)
    }
}

extension ViewController: BarcodeScannerDismissalDelegate {
    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
