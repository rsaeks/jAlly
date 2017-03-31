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
let workingData = JSSData()
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
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var deviceIDLabel: UILabel!
    @IBOutlet weak var deviceSNLabel: UILabel!
    @IBOutlet weak var deviceMACLabel: UILabel!
    @IBOutlet weak var deviceIPLabel: UILabel!
    @IBOutlet weak var deviceInventorylabel: UILabel!
    @IBOutlet weak var updateInventoryButton: UIButton!
    @IBOutlet weak var sendBlankPushButton: UIButton!
    @IBOutlet weak var removeRestritionsButton: UIButton!
    @IBOutlet weak var reapplyRestrictionsButton: UIButton!
    @IBOutlet weak var restartDeviceButton: UIButton!
    @IBOutlet weak var shutdownDeviceButton: UIButton!
    @IBOutlet weak var scanBarcodeButton: UIButton!
    

    override func viewDidAppear(_ animated: Bool) {
        updateUI()
    }
    
    //// ------------------------------------
    //
    // --- CODE TO PROCESS INPUTS BEGIN ---
    //
    //// ------------------------------------
        
    // Run this function when the "Lookup User" Button is pressed
    @IBAction func userToCheckPressed(_ sender: Any) {
        if (userToCheck.text != "") {
            dissmissKeyboard()
            workingData.user = userToCheck.text!
            lookupData(parameterToCheck: workingData.user, passedItem: "username")
            JSSQueue.notify(queue: DispatchQueue.main, execute: { self.displayData()} )
        }
    }
    
    // Run this function when the "Lookup SN" Button is pressed
    @IBAction func snToCheckPressed(_ sender: Any) {
        if (snToCheck.text != "") {
            dissmissKeyboard()
            workingData.deviceSN = snToCheck.text!
            lookupData(parameterToCheck: workingData.deviceSN, passedItem: "serialnumber")
            JSSQueue.notify(queue: DispatchQueue.main, execute: { self.displayData()} )
        }
    }
    
    @IBAction func lookupInventoryNumber(_ sender: Any) {
        if (invNumToCheck.text != "") {
            dissmissKeyboard()
            workingData.deviceInventoryNumber = invNumToCheck.text!
            lookupData(parameterToCheck: workingData.deviceInventoryNumber, passedItem: "assettag")
            JSSQueue.notify(queue: DispatchQueue.main, execute: { self.displayData()} )
        }
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
    
    @IBAction func updateInventoryPressed(_ sender: Any) {
        setupButtons()
            Alamofire.request(workingjss.jssURL + devAPIUpdateInventoryPath + String(workingData.deviceID), method: .post).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseString { response in
            if (response.result.isSuccess) {
                self.updateInventoryButton.layer.borderColor = successColor
            }
            else {
                self.updateInventoryButton.layer.borderColor = failColor
                }
        }
    }
    
    @IBAction func sendBlankPushPressed(_ sender: Any) {
        setupButtons()
        Alamofire.request(workingjss.jssURL + devAPIBlankPushPath + String(workingData.deviceID), method: .post).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseString { response in
            if(response.result.isSuccess) {
                self.sendBlankPushButton.layer.borderColor = successColor
            }
            else {
                self.sendBlankPushButton.layer.borderColor = failColor
            }
        }
    }
    
    @IBAction func removeRestrictionsPressed(_ sender: Any) {
        setupButtons()
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
                    self.removeRestritionsButton.layer.borderColor = successColor
                }
                else {
                    self.removeRestritionsButton.layer.borderColor = failColor
                }
        }
    }
    
    @IBAction func reapplyRestrictionsPressed(_ sender: Any) {
        setupButtons()
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
                    self.reapplyRestrictionsButton.layer.borderColor = successColor
                }
                else {
                    self.reapplyRestrictionsButton.layer.borderColor = failColor
                }
        }
    }
    
    @IBAction func restartDevicePressed(_ sender: Any) {
        setupButtons()
        Alamofire.request(workingjss.jssURL + devRestartPath + String(workingData.deviceID), method: .post).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseString { response in
            if(response.result.isSuccess) {
                self.restartDeviceButton.layer.borderColor = successColor
            }
            else {
                self.restartDeviceButton.layer.borderColor = failColor
            }
        }
    }
    
    @IBAction func shutdownDevicePressed(_ sender: Any) {
        setupButtons()
        Alamofire.request(workingjss.jssURL + devShutdownPath + String(workingData.deviceID), method: .post).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseString { response in
            if(response.result.isSuccess) {
                self.shutdownDeviceButton.layer.borderColor = successColor
            }
            else {
                self.shutdownDeviceButton.layer.borderColor = failColor
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
        print("Scan SN pressed")
        if let myImage = UIImage(named: "sample") {
            print("Image set")
            scannedSN.characterWhiteList = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            scannedSN.recognize(myImage) { result in
            print(result)
            }
        }
    }
    
    
    
    //// ------------------------------------
    //
    // --- LOOKUP DATA BEGIN
    //
    //// ------------------------------------
    
    func lookupData (parameterToCheck: String, passedItem: String) {
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
        case "serialnumber":
            message = deviceSNNotFound
        case "assettag":
            message = inventoryNumNotFound
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
    
    func displayData() {
        deviceIDLabel.text = String(workingData.deviceID)
        deviceSNLabel.text = workingData.deviceSN
        deviceMACLabel.text = workingData.deviceMAC
        usernameLabel.text = workingData.user
        fullNameLabel.text = workingData.realName
        snToCheck.text = workingData.deviceSN
        userToCheck.text = workingData.user
        deviceIPLabel.text = workingData.deviceIPAddress
        deviceInventorylabel.text = workingData.lastInventoryEpocFormatted
        enableButtons()
    }
    
    func enableButtons() {
        updateInventoryButton.isEnabled = true
        sendBlankPushButton.isEnabled = true
        removeRestritionsButton.isEnabled = true
        reapplyRestrictionsButton.isEnabled = true
        restartDeviceButton.isEnabled = true
        shutdownDeviceButton.isEnabled = true
        setupButtons()
    }
    
    func setupButtons() {
        updateInventoryButton.layer.borderWidth = 2
        sendBlankPushButton.layer.borderWidth = 2
        removeRestritionsButton.layer.borderWidth = 2
        reapplyRestrictionsButton.layer.borderWidth = 2
        restartDeviceButton.layer.borderWidth = 2
        shutdownDeviceButton.layer.borderWidth = 2
        
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
