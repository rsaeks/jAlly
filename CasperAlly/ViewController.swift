//
//  ViewController.swift
//  CasperAlly
//
//  Created by Randy Saeks on 2/9/17.
//  Copyright © 2017 Randy Saeks. All rights reserved.
//

// Import frameworks
import UIKit
import KeychainSwift
import Alamofire
import BarcodeScanner
import SwiftOCR

// Create instances
let workingjss = JSSConfig()
let defaultsVC = UserDefaults()
let keychain = KeychainSwift()
var workingData = JSSData()
let JSSQueue = DispatchGroup()
let controller = BarcodeScannerController()
let scannedSN = SwiftOCR()


class ViewController: UIViewController {

    //Setup our connections to UI
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
    @IBOutlet weak var restartDeviceButton: UIButton!
    @IBOutlet weak var shutdownDeviceButton: UIButton!
    @IBOutlet weak var scanBarcodeButton: UIButton!
    @IBOutlet weak var batteryStatusIcon: UIImageView!
    @IBOutlet weak var freeSpaceStatusIcon: UIImageView!
    @IBOutlet weak var warrantyExpiresIcon: UIImageView!
    @IBOutlet weak var lookupUserButton: scanButton!
    @IBOutlet weak var lookupSNButton: scanButton!
    @IBOutlet weak var lookupINVNumButton: scanButton!
    

    override func viewDidAppear(_ animated: Bool) {
        updateUI()
    }
    
    @IBAction func clearDataPressed(_ sender: Any) {
        resetUI()
        workingData = JSSData()
    }
    
    
    //// ------------------------------------
    //
    // --- CODE TO PROCESS INPUTS BEGIN ---
    //
    //// ------------------------------------
        
    // Run this function when the "Lookup User" Button is pressed
    @IBAction func userToCheckPressed(_ sender: UIButton) {
        if (userToCheck.text != "") {
            workingData = JSSData()
            sender.layer.borderColor = warnColor.cgColor
            workingData.user = userToCheck.text!
            lookupData(parameterToCheck: workingData.user, passedItem: "username")
            JSSQueue.notify(queue: DispatchQueue.main, execute: {
                self.displayData(theButton: sender)
            } )
        }
        resetButtons()
    }
    
    // Run this function when the "Lookup SN" Button is pressed
    @IBAction func snToCheckPressed(_ sender: UIButton) {
        if (snToCheck.text != "") {
            workingData = JSSData()
            sender.layer.borderColor = warnColor.cgColor
            workingData.deviceSN = snToCheck.text!
            lookupData(parameterToCheck: workingData.deviceSN, passedItem: "serialnumber")
            JSSQueue.notify(queue: DispatchQueue.main, execute: {
                self.displayData(theButton: sender)
            } )
        }
        resetButtons()
    }
    
    @IBAction func lookupInventoryNumber(_ sender: UIButton) {
        if (invNumToCheck.text != "") {
            workingData = JSSData()
            sender.layer.borderColor = warnColor.cgColor
            workingData.deviceInventoryNumber = invNumToCheck.text!
            lookupData(parameterToCheck: workingData.deviceInventoryNumber, passedItem: "assettag")
            JSSQueue.notify(queue: DispatchQueue.main, execute: {
                self.displayData(theButton: sender)
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
            if let myImage = UIImage(named: "sample") {
            scannedSN.characterWhiteList = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            scannedSN.recognize(myImage) { result in
            }
        }
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
                                if let deviceID = mobileDevice[0][workingjss.idKey] as? Int {
                                    workingData.deviceID = deviceID
                                    self.getDetails()
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
                            if let asset_tag = generalData[workingjss.inventoryKey] as? String {
                                workingData.deviceInventoryNumber = asset_tag
                                self.invNumToCheck.text = workingData.deviceInventoryNumber
                            }
                            if let deviceName = generalData[workingjss.deviceNameKey] as? String {
                                workingData.deviceName = deviceName
                            }
                            if let deviceSN = generalData[workingjss.serialNumberKey] as? String {
                                workingData.deviceSN = deviceSN
                                self.snToCheck.text = workingData.deviceSN
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
                                workingData.user = username
                                self.userToCheck.text = workingData.user
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
                JSSQueue.leave()
            } // Close our successful result
            else {
                JSSQueue.leave()
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
        view.endEditing(true)
    }
    
    func displayData(theButton: UIButton) {
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
        if (workingData.batteryLevel <= savedSettings.sharedInstance.battCritLevel) {
            batteryStatusIcon.isHidden = false
            batteryStatusIcon.image = #imageLiteral(resourceName: "red")
        }
        else if (workingData.batteryLevel <= savedSettings.sharedInstance.battWarnLevel) {
            batteryStatusIcon.isHidden = false
            batteryStatusIcon.image = #imageLiteral(resourceName: "orange")
        }
        
        // Determine color of Free Space text based on percent used
        if (workingData.percentUsed >= savedSettings.sharedInstance.freespaceCritLevel) {
            freeSpaceStatusIcon.isHidden = false
            freeSpaceStatusIcon.image = #imageLiteral(resourceName: "red")
        }
        else if (workingData.percentUsed >= savedSettings.sharedInstance.freespaceWarnLevel) {
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
        removeRestritionsButton.isEnabled = true
        reapplyRestrictionsButton.isEnabled = true
        restartDeviceButton.isEnabled = true
        shutdownDeviceButton.isEnabled = true
        setupButtons(buttonWidth: 2)
    }
    
    func disableButtons() {
        updateInventoryButton.isEnabled = false
        sendBlankPushButton.isEnabled = false
        removeRestritionsButton.isEnabled = false
        reapplyRestrictionsButton.isEnabled = false
        restartDeviceButton.isEnabled = false
        shutdownDeviceButton.isEnabled = false
        setupButtons(buttonWidth: 0)
    }
    
    func resetButtons() {
        updateInventoryButton.layer.borderColor = UIColor.lightGray.cgColor
        sendBlankPushButton.layer.borderColor = UIColor.lightGray.cgColor
        removeRestritionsButton.layer.borderColor = UIColor.lightGray.cgColor
        reapplyRestrictionsButton.layer.borderColor = UIColor.lightGray.cgColor
        restartDeviceButton.layer.borderColor = UIColor.lightGray.cgColor
        shutdownDeviceButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func setupButtons(buttonWidth: Int) {
        updateInventoryButton.layer.borderWidth = CGFloat(buttonWidth)
        sendBlankPushButton.layer.borderWidth = CGFloat(buttonWidth)
        removeRestritionsButton.layer.borderWidth = CGFloat(buttonWidth)
        reapplyRestrictionsButton.layer.borderWidth = CGFloat(buttonWidth)
        restartDeviceButton.layer.borderWidth = CGFloat(buttonWidth)
        shutdownDeviceButton.layer.borderWidth = CGFloat(buttonWidth)
    }
    
    func updateUI() {
        let testURL = defaultsVC.string(forKey: "savedJSSURL")
        let testExclusionGID = defaultsVC.string(forKey: "savedExclusionGID")
        let testJSSUsername = defaultsVC.string(forKey: "savedJSSUsername")
        let testJSSPassword = keychain.get("savedJSSPassword")
        
        if testURL != nil {
            workingjss.jssURL = testURL!
            jssURLLabel.text = workingjss.jssURL
        }
        if testExclusionGID != nil {
            workingjss.exclusinGID = testExclusionGID!
            jssGIDLabel.text = workingjss.exclusinGID
        }
        if testJSSUsername != nil {
            workingjss.jssUsername = testJSSUsername!
            jssUsernameLabel.text = workingjss.jssUsername
        }
        if testJSSPassword != nil {
            workingjss.jssPassword = testJSSPassword!
        }
        if savedSettings.sharedInstance.snToCheck != nil {
            snToCheck.text = savedSettings.sharedInstance.snToCheck
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
        savedSettings.sharedInstance.snToCheck = ""
        iOSVersionLabel.text = "iOS Version"
        warrantyExpiresLabel.text = "Warranty Expires"
        freeSpaceLabel.text = "Free Space"
        batteryLevelLabel.text = "Battery %"
        disableButtons()
        batteryLevelLabel.textColor = UIColor.black
        freeSpaceLabel.textColor = UIColor.black
        warrantyExpiresLabel.textColor = UIColor.black
        batteryStatusIcon.image = nil
        freeSpaceStatusIcon.image = nil
        warrantyExpiresIcon.image = nil
        lookupUserButton.layer.borderColor = UIColor.lightGray.cgColor
        lookupSNButton.layer.borderColor = UIColor.lightGray.cgColor
        lookupINVNumButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    

    
    //// ------------------------------------
    //
    // --- UI RELATED FUNCTIONS END
    //
    //// ------------------------------------
    
}
////
//
// Barcode Scanning extensions
//
////
extension ViewController: BarcodeScannerCodeDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
        workingData.deviceInventoryNumber = code
        self.invNumToCheck.text = workingData.deviceInventoryNumber
        controller.dismiss(animated: true, completion: nil)
        resetButtons()
        lookupINVNumButton.layer.borderColor = warnColor.cgColor
        lookupData(parameterToCheck: workingData.deviceInventoryNumber, passedItem: "assettag")
        JSSQueue.notify(queue: DispatchQueue.main, execute: { self.displayData(theButton: self.lookupINVNumButton)} )
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
