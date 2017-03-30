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

// Setup button border colors:
//let successColor = UIColor(red: 0, green: 0.4863, blue: 0.1843, alpha: 1.0).cgColor
// let failColor = UIColor(red: 0.498, green: 0.0392, blue: 0.0, alpha: 1.0).cgColor


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
    
   override func viewDidLoad() {
        super.viewDidLoad()
        //Do any additional setup after loading the view, typically from a nib.
        updateUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        updateUI()
        alwaysOnButtons()
    }
    
    //
    //
    // --- CODE TO PROCESS INPUTS BEGIN ---
    //
    //
        
    // Run this function when the "Lookup User" Button is pressed
    @IBAction func userToCheckPressed(_ sender: Any) {
        if (userToCheck.text != "") {
            JSSQueue.enter()
            view.endEditing(true)
            workingData.user = userToCheck.text!
            //getUserInfo()
            lookupData(parameterToCheck: workingData.user, passedItem: "username")
            JSSQueue.notify(queue: DispatchQueue.main, execute: { self.displayData()} )
        }
    }
    
    // Run this function when the "Lookup SN" Button is pressed
    @IBAction func snToCheckPressed(_ sender: Any) {
        if (snToCheck.text != "") {
            JSSQueue.enter()
            view.endEditing(true)
            workingData.deviceSN = snToCheck.text!
            //lookupSN()
            lookupData(parameterToCheck: workingData.deviceSN, passedItem: "serialnumber")
            JSSQueue.notify(queue: DispatchQueue.main, execute: { self.displayData()} )
        }
    }
    
    @IBAction func lookupInventoryNumber(_ sender: Any) {
        if (invNumToCheck.text != "") {
            JSSQueue.enter()
            view.endEditing(true)
            workingData.deviceInventoryNumber = invNumToCheck.text!
            //lookupInventory()
            lookupData(parameterToCheck: workingData.deviceInventoryNumber, passedItem: "assettag")
            JSSQueue.notify(queue: DispatchQueue.main, execute: { self.displayData()} )
        }
    }
    
    //
    //
    // --- CODE TO PROCESS INPUTS END ---
    //
    //
    
    
    //
    //
    // --- CODE TO PERFORM ACTIONS BEGINS ---
    //
    //
    
    // Run this function when the "Update Inventory Button" is pressed
    @IBAction func updateInventoryPressed(_ sender: Any) {
        setupButtons()
            Alamofire.request(workingjss.jssURL + devAPIUpdateInventoryPath + String(workingData.deviceID), method: .post).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseString { response in
            if (response.result.isSuccess) {
                //self.updateInventoryButton.layer.borderColor = UIColor(red: 0, green: 0.4863, blue: 0.1843, alpha: 1.0).cgColor
                self.updateInventoryButton.layer.borderColor = successColor
            }
            else {
                //self.updateInventoryButton.layer.borderColor = UIColor(red: 0.498, green: 0.0392, blue: 0.0, alpha: 1.0).cgColor
                self.updateInventoryButton.layer.borderColor = failColor
                }
        }
    }
    
    
    @IBAction func sendBlankPushPressed(_ sender: Any) {
        setupButtons()
        Alamofire.request(workingjss.jssURL + devAPIBlankPushPath + String(workingData.deviceID), method: .post).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseString { response in
            if(response.result.isSuccess) {
                //self.sendBlankPushButton.layer.borderColor = UIColor(red: 0, green: 0.4863, blue: 0.1843, alpha: 1.0).cgColor
                self.sendBlankPushButton.layer.borderColor = successColor
            }
            else {
                //self.sendBlankPushButton.layer.borderColor = UIColor(red: 0.498, green: 0.0392, blue: 0.0, alpha: 1.0).cgColor
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
                    //self.removeRestritionsButton.layer.borderColor = UIColor(red: 0, green: 0.4863, blue: 0.1843, alpha: 1.0).cgColor
                    self.removeRestritionsButton.layer.borderColor = successColor
                    //print("Added to troubleshooting group")
                    //debugPrint("HTTP Response Body: \(response.data!)")
                }
                else {
                    self.removeRestritionsButton.layer.borderColor = UIColor(red: 0.498, green: 0.0392, blue: 0.0, alpha: 1.0).cgColor
                    self.removeRestritionsButton.layer.borderColor = failColor
                    //debugPrint("HTTP Request failed: \(response.result.error!)")
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
                    //self.reapplyRestrictionsButton.layer.borderColor = UIColor(red: 0, green: 0.4863, blue: 0.1843, alpha: 1.0).cgColor
                    self.reapplyRestrictionsButton.layer.borderColor = successColor
                }
                else {
                    //self.reapplyRestrictionsButton.layer.borderColor = UIColor(red: 0.498, green: 0.0392, blue: 0.0, alpha: 1.0).cgColor
                    self.reapplyRestrictionsButton.layer.borderColor = failColor
                }
        }
    }
    
    @IBAction func restartDevicePressed(_ sender: Any) {
        setupButtons()
        Alamofire.request(workingjss.jssURL + devRestartPath + String(workingData.deviceID), method: .post).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseString { response in
            if(response.result.isSuccess) {
                //self.restartDeviceButton.layer.borderColor = UIColor(red: 0, green: 0.4863, blue: 0.1843, alpha: 1.0).cgColor
                self.restartDeviceButton.layer.borderColor = successColor
            }
            else {
                //self.restartDeviceButton.layer.borderColor = UIColor(red: 0.498, green: 0.0392, blue: 0.0, alpha: 1.0).cgColor
                self.restartDeviceButton.layer.borderColor = failColor
            }
        }
    }
    
    
    
    @IBAction func shutdownDevicePressed(_ sender: Any) {
        setupButtons()
        Alamofire.request(workingjss.jssURL + devShutdownPath + String(workingData.deviceID), method: .post).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseString { response in
            if(response.result.isSuccess) {
                //self.shutdownDeviceButton.layer.borderColor = UIColor(red: 0, green: 0.4863, blue: 0.1843, alpha: 1.0).cgColor
                self.shutdownDeviceButton.layer.borderColor = successColor
            }
            else {
                //self.shutdownDeviceButton.layer.borderColor = UIColor(red: 0.498, green: 0.0392, blue: 0.0, alpha: 1.0).cgColor
                self.shutdownDeviceButton.layer.borderColor = failColor
            }
        }

    }
    
    //
    //
    // --- CODE TO PERFORM ACTIONS ENDS ---
    //
    //
    
    
    //
    //
    // --- BARCODE SCANNING BEGIN ---
    //
    //
    
    @IBAction func scanBarCodePressed(_ sender: Any) {
        controller.reset()
        controller.codeDelegate = self
        controller.errorDelegate = self
        controller.dismissalDelegate = self
        //print("Presenting the UI")
        present(controller, animated: true, completion: nil)
    }
    
    //
    //
    // --- BARCODE SCANNING END ---
    //
    //
    
    func lookupInventory () {
        JSSQueue.enter()
        JSSQueue.enter()
        Alamofire.request(workingjss.jssURL + devAPIMatchPath + workingData.deviceInventoryNumber, method: .get, headers: headers)
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
                                if let userShortName = mobileDevice[0][workingjss.usernameKey] as? String {
                                    workingData.user = userShortName
                                }
                            }
                            else {
                                let noUserFound = UIAlertController(title: "Unable to locate asset tag", message: "Could not find a device with asset tag  \(workingData.deviceInventoryNumber).", preferredStyle: UIAlertControllerStyle.alert)
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
                            //if let inventoryTime = generalData[workingjss.inventoryTimeKey] as? String {
                            //    workingData.lastInventory = inventoryTime
                            //}
                            if let macAddress = generalData[workingjss.MACAddressKey] as? String {
                                workingData.deviceMAC = macAddress
                            }
                            if let deviceID = generalData[workingjss.idKey] as? Int {
                                workingData.deviceID = deviceID
                            }
                            if let epochTime = generalData[workingjss.epochInventroryTimekey] as? Double {
                                workingData.lastInventoryEpoc = epochTime/1000
                                let date = Date(timeIntervalSince1970: workingData.lastInventoryEpoc)
                                let dateFormat = DateFormatter()
                                dateFormat.dateFormat = "E MM/dd/YY HH:mm a"
                                dateFormat.timeZone = TimeZone.current
                                workingData.lastInventoryEpocFormatted = dateFormat.string(from: date)
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
                                // ******* IP ADDRESS DONE
                            }
                            //if let inventoryTime = generalData[workingjss.inventoryTimeKey] as? String {
                            //    workingData.lastInventory = inventoryTime
                                // ******* INVENTORY TIME DONE
                            //}
                            if let epochTime = generalData[workingjss.epochInventroryTimekey] as? Double {
                                workingData.lastInventoryEpoc = epochTime/1000
                                let date = Date(timeIntervalSince1970: workingData.lastInventoryEpoc)
                                let dateFormat = DateFormatter()
                                dateFormat.dateFormat = "E MM/dd/YY HH:mm a"
                                dateFormat.timeZone = TimeZone.current
                                workingData.lastInventoryEpocFormatted = dateFormat.string(from: date)
                                // ******* INVENTORY EPOCH TIME DONE
                            }

                            if let asset_tag = generalData[workingjss.inventoryKey] as? String {
                                workingData.deviceInventoryNumber = asset_tag
                                self.invNumToCheck.text = workingData.deviceInventoryNumber
                                // ******* ASSET TAG DONE

                            }
                        }
                    }
                }
                JSSQueue.leave()
            }
        }
    }
    
    //
    //
    // --- UI RELATED FUNCTIONS BEGIN
    //
    //
    
    
    func displayData() {
        deviceIDLabel.text = String(workingData.deviceID)
        deviceSNLabel.text = workingData.deviceSN
        deviceMACLabel.text = workingData.deviceMAC
        usernameLabel.text = workingData.user
        fullNameLabel.text = workingData.realName
        snToCheck.text = workingData.deviceSN
        userToCheck.text = workingData.user
        deviceIPLabel.text = workingData.deviceIPAddress
        //deviceInventorylabel.text = workingData.lastInventory
        deviceInventorylabel.text = workingData.lastInventoryEpocFormatted
        enableButtons()
        }
    
    func displayInvNumber() {
        invNumToCheck.text = workingData.deviceInventoryNumber
    }
    
    func alwaysOnButtons () {
        scanBarcodeButton.layer.borderColor = UIColor.lightGray.cgColor
        scanBarcodeButton.layer.borderWidth = 1
        scanBarcodeButton.layer.cornerRadius = 5
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
        restartDeviceButton.layer.borderColor = UIColor.lightGray.cgColor
        restartDeviceButton.layer.borderWidth = 2
        restartDeviceButton.layer.cornerRadius = 5
        shutdownDeviceButton.layer.borderColor = UIColor.lightGray.cgColor
        shutdownDeviceButton.layer.borderWidth = 2
        shutdownDeviceButton.layer.cornerRadius = 5
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
    }
    
    //
    //
    // --- UI RELATED FUNCTIONS END
    //
    //
    
    //
    //
    // --- CODE SIMPLIFICATION BEGIN
    //
    //
    
    func lookupData (parameterToCheck: String, passedItem: String) {
        //JSSQueue.enter()
        //print("We are looking up the following item: \(parameterToCheck) and it is the type \(passedItem)")
        Alamofire.request(workingjss.jssURL + matchPath + parameterToCheck, method: .get, headers: headers)
            .authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseJSON { response in
                if (response.result.isSuccess) {
                    if let outerDict = response.result.value as? Dictionary <String, AnyObject> {
                        if let mobileDevice = outerDict[workingjss.mobileDevicesKey] as? [Dictionary<String,AnyObject>] {
                            if mobileDevice.count > 0 {
                                if let deviceID = mobileDevice[0][workingjss.idKey] as? Int {
                                    workingData.deviceID = deviceID
                                    //print("For \(passedItem) with value \(parameterToCheck) we found a match with \(workingData.deviceID)")
                                    self.getDetails()
                                }
                            }
                            else {
                                self.notFound(notFoundItem: parameterToCheck, ItemType: passedItem)
//                                switch passedItem {
//                                case "username":
//                                    print("\(parameterToCheck)\(userNameNotFound)")
//                                    self.notFound(notFoundItem: parameterToCheck, ItemType: passedItem)
//                                    //JSSQueue.leave()
//                                case "serialnumber":
//                                    print("\(parameterToCheck)\(deviceSNNotFound)")
//                                    JSSQueue.leave()
//                                case "assettag":
//                                    print("\(parameterToCheck)\(inventoryNumNotFound)")
//                                    JSSQueue.leave()
//                                default:
//                                    print("Other uncaught error occured")
//                                    JSSQueue.leave()
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
                            //if let inventoryTime = generalData[workingjss.inventoryTimeKey] as? String {
                            //    workingData.lastInventory = inventoryTime
                            //}
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
                            //if let userName = generalData[workingjss.realNameKey] as? String {
                            //    workingData.realName = userName
                            //}
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
                //self.printResults()
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
            //JSSQueue.leave()
        }
        let notFoundDialog = UIAlertController(title: "Not Found", message: "\(notFoundItem)\(message) ", preferredStyle: UIAlertControllerStyle.alert)
        notFoundDialog.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(notFoundDialog, animated: true)
        JSSQueue.leave()
    }
    
    func printResults() {
    print("----- BEGINNING OF DEVICE INFO -----")
    print("Username: \(workingData.user)")
    print("Full Name: \(workingData.realName)")
    print("Device ID: \(workingData.deviceID)")
    print("Device SN: \(workingData.deviceSN)")
    print("Device MAC: \(workingData.deviceMAC)")
    print("Device IP: \(workingData.deviceIPAddress)")
    print("Last Inventory: \(workingData.lastInventoryEpocFormatted)")
    print("Asset Tag: \(workingData.deviceInventoryNumber)")
    print("----- END OF DEVICE INFO -----")
    }
    
    
    //
    //
    // --- CODE SIMPLIFICATION END
    //
    //
}

// Barcode Scanning extensions
//
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
