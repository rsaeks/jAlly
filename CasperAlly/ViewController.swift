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
import SwiftyJSON
import BarcodeScanner

// Create instances
let workingjss = JSSConfig()
let defaultsVC = UserDefaults()
let keychain = KeychainSwift()
let workingData = JSSData()
let JSSQueue = DispatchGroup()
let controller = BarcodeScannerController()


class ViewController: UIViewController {

    //Setup our connections to UI
    @IBOutlet weak var jssURLLabel: UILabel!
    @IBOutlet weak var jssGIDLabel: UILabel!
    @IBOutlet weak var jssUsernameLabel: UILabel!
    @IBOutlet weak var jssPasswordLabel: UILabel!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        updateUI()
    }

    // Run this function when the "Lookup User" Button is pressed
    @IBAction func userToCheckPressed(_ sender: Any) {
        if (userToCheck.text != "") {
            view.endEditing(true)
            workingData.user = userToCheck.text!
            getUserInfo()
            JSSQueue.notify(queue: DispatchQueue.main, execute: { self.displayData()} )
        }
    }
    
    // Run this function when the "Lookup SN" Button is pressed
    @IBAction func snToCheckPressed(_ sender: Any) {
        if (snToCheck.text != "") {
            view.endEditing(true)
            workingData.deviceSN = snToCheck.text!
            lookupSN()
            JSSQueue.notify(queue: DispatchQueue.main, execute: { self.displayData()} )
        }
    }
    
    // Run this function when the "Update Inventor Button" is pressed
    @IBAction func updateInventoryPressed(_ sender: Any) {
        setupButtons()
            Alamofire.request(workingjss.jssURL + devAPIUpdateInventoryPath + String(workingData.deviceID), method: .post).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseJSON { response in
            if (response.result.isSuccess) {
                self.updateInventoryButton.layer.borderColor = UIColor(red: 0, green: 0.4863, blue: 0.1843, alpha: 1.0).cgColor
            }
            else {
                self.updateInventoryButton.layer.borderColor = UIColor(red: 0.498, green: 0.0392, blue: 0.0, alpha: 1.0).cgColor
                }
        }
    }
    
    
    @IBAction func sendBlankPushPressed(_ sender: Any) {
        setupButtons()
        Alamofire.request(workingjss.jssURL + devAPIBlankPushPath + String(workingData.deviceID), method: .post).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseJSON { response in
            if(response.result.isSuccess) {
                self.sendBlankPushButton.layer.borderColor = UIColor(red: 0, green: 0.4863, blue: 0.1843, alpha: 1.0).cgColor
            }
            else {
                self.sendBlankPushButton.layer.borderColor = UIColor(red: 0.498, green: 0.0392, blue: 0.0, alpha: 1.0).cgColor
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
        //print(workingjss.jssURL + devAPIPath + workingjss.exclusinGID)
        Alamofire.request(workingjss.jssURL + devAPIPath + workingjss.exclusinGID, method: .put, encoding: RawDataEncoding.default, headers: xmlHeaders).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword)
            .responseJSON { response in
                if (response.result.isSuccess) {
                    self.removeRestritionsButton.layer.borderColor = UIColor(red: 0, green: 0.4863, blue: 0.1843, alpha: 1.0).cgColor
                    //print("Added to troubleshooting group")
                    //debugPrint("HTTP Response Body: \(response.data!)")
                }
                else {
                    self.removeRestritionsButton.layer.borderColor = UIColor(red: 0.498, green: 0.0392, blue: 0.0, alpha: 1.0).cgColor
                    //debugPrint("HTTP Request failed: \(response.result.error!)")
                }
        }
    }
    
    @IBAction func reapplyRestrictionsPressed(_ sender: Any) {
        setupButtons()
        //print("Reapply Restrictions Pressed")
        struct RawDataEncoding: ParameterEncoding {
            public static var `default`: RawDataEncoding { return RawDataEncoding() }
            public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
                var request = try urlRequest.asURLRequest()
                request.httpBody = "\(devGroupDeletionLeft)\(String(workingData.deviceID))\(devGroupDeletionRight)".data(using: String.Encoding.utf8, allowLossyConversion: false)
                return request
            }
        }
        // Fetch Request
        print(workingjss.jssURL + devAPIPath + workingjss.exclusinGID)
        Alamofire.request(workingjss.jssURL + devAPIPath + workingjss.exclusinGID, method: .put, encoding: RawDataEncoding.default, headers: xmlHeaders).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword)
            .responseJSON { response in
                if (response.result.isSuccess) {
                    self.reapplyRestrictionsButton.layer.borderColor = UIColor(red: 0, green: 0.4863, blue: 0.1843, alpha: 1.0).cgColor
                }
                else {
                    self.reapplyRestrictionsButton.layer.borderColor = UIColor(red: 0.498, green: 0.0392, blue: 0.0, alpha: 1.0).cgColor
                }
        }
    }
    
    
    // BARCODE SCANNING ADDITIONS
    //
    //
    
    @IBAction func scanBarCodePressed(_ sender: Any) {
        controller.reset()
        controller.codeDelegate = self
        controller.errorDelegate = self
        controller.dismissalDelegate = self
        print("Presenting the UI")
        present(controller, animated: true, completion: nil)
        //print("Function Called and returned this ----> \(workingData.deviceInventoryNumber)")
        //if (workingData.deviceInventoryNumber != "ToScan") {
         //   print("Inventory number passed check")
         //   invNumToCheck.text = workingData.deviceInventoryNumber
        //}
        //else {
        //    print("Inventory Number did not pass check")
        //}
    }
    
    //End Barcode scanner additions
    //
    //
    
    
    func lookupSN() {
        JSSQueue.enter()
        Alamofire.request(workingjss.jssURL + devAPISNPath + workingData.deviceSN, method: .get, headers: headers).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseJSON { response in
            if (response.response?.statusCode == 404) {
                let noSNFound = UIAlertController(title: "No device found", message: "Could not find a device with serial number \(workingData.deviceSN).", preferredStyle: UIAlertControllerStyle.alert)
                noSNFound.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(noSNFound, animated: true)
                JSSQueue.leave()
            }
            else if (response.result.isSuccess) {
                if let outerDict = response.result.value as? Dictionary <String, AnyObject> {
                    if let mobileDeviceData = outerDict[workingjss.mobileDeviceKey] as? Dictionary <String,AnyObject> {
                        if let generalData = mobileDeviceData[workingjss.generalKey] as? Dictionary <String, AnyObject> {
                            if let ip_address = generalData[workingjss.ipAddressKey] as? String {
                                workingData.deviceIPAddress = ip_address
                            }
                            if let inventoryTime = generalData[workingjss.inventoryTimeKey] as? String {
                                workingData.lastInventory = inventoryTime
                            }
                            if let macAddress = generalData[workingjss.MACAddressKey] as? String {
                                workingData.deviceMAC = macAddress
                            }
                            if let deviceID = generalData[workingjss.idKey] as? Int {
                                workingData.deviceID = deviceID
                            }
                        }
                        if let location = mobileDeviceData[workingjss.locationKey] as? Dictionary <String, AnyObject> {
                            if let username = location[workingjss.usernameKey] as? String {
                                workingData.user = username
                                self.userToCheck.text = workingData.user
                            }
                            if let fullName = location[workingjss.realNameKey] as? String {
                                workingData.realName = fullName
                            }
                        }
                    }
                }
            }
                JSSQueue.leave()
        }
    }
    
func getUserInfo() {
        JSSQueue.enter()
        JSSQueue.enter()
        Alamofire.request(workingjss.jssURL + devAPIMatchPath + workingData.user, method: .get, headers: headers)
            .authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseJSON { response in
                if (response.result.isSuccess) {
                    if let outerDict = response.result.value as? Dictionary <String, AnyObject> {
                        if let mobileDevice = outerDict[workingjss.mobileDevicesKey] as? [Dictionary<String,AnyObject>] {
                            if mobileDevice.count > 0 {
                                if let deviceName = mobileDevice[0][workingjss.deviceNameKey] as? String {
                                    workingData.deviceName = deviceName
                                    }
                                if let deviceSN = mobileDevice[0][workingjss.serialNumberKey] as? String {
                                    workingData.deviceSN = deviceSN
                                }
                                if let deviceMAC = mobileDevice[0][workingjss.MACAddressKey] as? String {
                                    workingData.deviceMAC = deviceMAC
                                }
                                if let deviceID = mobileDevice[0][workingjss.idKey] as? Int {
                                    workingData.deviceID = deviceID
                                }
                                if let userName = mobileDevice[0][workingjss.realNameKey] as? String {
                                    workingData.realName = userName
                                }
                            }
                            else {
                                let noUserFound = UIAlertController(title: "No User Found", message: "Could not find a device assigned to user \(workingData.user).", preferredStyle: UIAlertControllerStyle.alert)
                                noUserFound.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(noUserFound, animated: true)
                                JSSQueue.leave()
                            }
                        }
                    }
                }
                self.getDeviceInfo()
        }
    
        Alamofire.request(workingjss.jssURL + devAPIMatchPath + workingData.user, method: .get, headers: headers)
            .authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseJSON { response in
                if (response.result.isSuccess) {
                    JSSQueue.leave()
                }
            }
    }
    
    func getDeviceInfo() {
        Alamofire.request(workingjss.jssURL + devAPIMatchPathID + String(workingData.deviceID), method: .get, headers: headers).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseJSON { response in
            if (response.result.isSuccess) {
                if let outerDict = response.result.value as? Dictionary <String, AnyObject> {
                    if let mobileDeviceData = outerDict[workingjss.mobileDeviceKey] as? Dictionary <String,AnyObject> {
                        if let generalData = mobileDeviceData[workingjss.generalKey] as? Dictionary <String, AnyObject> {
                            if let ip_address = generalData[workingjss.ipAddressKey] as? String {
                                workingData.deviceIPAddress = ip_address
                            }
                            if let inventoryTime = generalData[workingjss.inventoryTimeKey] as? String {
                                workingData.lastInventory = inventoryTime
                            }
                        }
                    }
                }
                JSSQueue.leave()
            }
        }
    }
    
    func displayData() {
        deviceIDLabel.text = String(workingData.deviceID)
        deviceSNLabel.text = workingData.deviceSN
        deviceMACLabel.text = workingData.deviceMAC
        usernameLabel.text = workingData.user
        fullNameLabel.text = workingData.realName
        snToCheck.text = workingData.deviceSN
        deviceIPLabel.text = workingData.deviceIPAddress
        deviceInventorylabel.text = workingData.lastInventory
        enableButtons()
        }
    
    func displayInvNumber() {
        invNumToCheck.text = workingData.deviceInventoryNumber
    
    }

    func enableButtons() {
        updateInventoryButton.isEnabled = true
        sendBlankPushButton.isEnabled = true
        removeRestritionsButton.isEnabled = true
        reapplyRestrictionsButton.isEnabled = true
        setupButtons()
    }

    func setupButtons() {
        updateInventoryButton.layer.borderColor = UIColor.lightGray.cgColor
        updateInventoryButton.layer.borderWidth = 2
        updateInventoryButton.layer.cornerRadius = 5
        sendBlankPushButton.layer.borderColor = UIColor.lightGray.cgColor
        sendBlankPushButton.layer.borderWidth = 2
        sendBlankPushButton.layer.cornerRadius = 5
        removeRestritionsButton.layer.borderColor = UIColor.lightGray.cgColor
        removeRestritionsButton.layer.borderWidth = 2
        removeRestritionsButton.layer.cornerRadius = 5
        reapplyRestrictionsButton.layer.borderColor = UIColor.lightGray.cgColor
        reapplyRestrictionsButton.layer.borderWidth = 2
        reapplyRestrictionsButton.layer.cornerRadius = 5
    }
    
    func updateUI() {
        let testURL = defaultsVC.string(forKey: "savedJSSURL")
        let testExclusionGID = defaultsVC.string(forKey: "savedExclusionGID")
        let testJSSUsername = defaultsVC.string(forKey: "savedJSSUsername")
        let testJSSPassword = keychain.get("savedJSSPassword")
        
        // Test to make sure JSS URL is populated
        if testURL != nil {
            workingjss.jssURL = testURL!
            jssURLLabel.text = workingjss.jssURL
        }
     
        // Test to make sure JSS exclusion GID is populated
        if testExclusionGID != nil {
            workingjss.exclusinGID = testExclusionGID!
            jssGIDLabel.text = workingjss.exclusinGID
        }
        
        // Test to make sure JSS Username is populated
        if testJSSUsername != nil {
            workingjss.jssUsername = testJSSUsername!
            jssUsernameLabel.text = workingjss.jssUsername
        }
        
        // Test to make sure JSS Username is populated
        if testJSSPassword != nil {
            workingjss.jssPassword = testJSSPassword!
            //jssPasswordLabel.text = workingjss.jssPassword
        }
    }
}

// Barcode Scanning Addition
//
extension ViewController: BarcodeScannerCodeDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
        //print(code)
        workingData.deviceInventoryNumber = code
        print("Set inventory info as follows: \(workingData.deviceInventoryNumber)")
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
