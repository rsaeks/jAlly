//
//  ViewController.swift
//  CasperAlly
//
//  Created by Randy Saeks on 2/9/17.
//  Copyright © 2017 Randy Saeks. All rights reserved.
//

import UIKit
import KeychainSwift
import Alamofire
import SwiftyJSON

let workingjss = JSSConfig()
let defaultsVC = UserDefaults()
let keychain = KeychainSwift()
let workingData = JSSData()
let JSSQueue = DispatchGroup()


class ViewController: UIViewController {

    @IBOutlet weak var jssURLLabel: UILabel!
    @IBOutlet weak var jssGIDLabel: UILabel!
    @IBOutlet weak var jssUsernameLabel: UILabel!
    @IBOutlet weak var jssPasswordLabel: UILabel!
    @IBOutlet weak var userToCheck: UITextField!
    @IBOutlet weak var snToCheck: UITextField!
    @IBOutlet weak var debugData: UILabel!
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
        //print("Main View Controller Appeared")
        updateUI()
    }

    @IBAction func userToCheckPressed(_ sender: Any) {
        if (userToCheck.text == "") {
            //print("Need to provide a username")
        }
        else {
            view.endEditing(true)
            workingData.user = userToCheck.text!
            //print("Provided Username is: \(workingData.user)")
            getUserInfo()
            JSSQueue.notify(queue: DispatchQueue.main, execute: {
                //print("Dispatch Queue Returned JSON Data is: \(workingData.responseDataJSON)")
                //print("Dispatch Queue Returned String Data is: \(workingData.responseDataString)")
                //self.debugData.text = workingData.responseDataString
                //self.getDeviceInfo()
                self.displayData()
            } )
            
            
//            print("===== About to call delay =====")
//            print("Pre-delay JSON Data is: \(workingData.responseData)")
//            print("Pre-delay  String Data is: \(workingData.responseDataString)")
//            let delay = DispatchTime.now() + 0.1
//            DispatchQueue.main.asyncAfter(deadline: delay) {
//                print("===== Delay called =====")
//                print("Delay Returned JSON Data is: \(workingData.responseData)")
//                print("Delay Returned String Data is: \(workingData.responseDataString)")
//                self.debugData.text = workingData.responseDataString
//            }

        }
    }
    
    @IBAction func snToCheckPressed(_ sender: Any) {
    }
    
    @IBAction func updateInventoryPressed(_ sender: Any) {
        print("Pressed Update Inventory")
        //https://mdm.glencoeschools.org:8443/JSSResource/mobiledevicecommands/command/UpdateInventory/id/13 POST
        print(workingjss.jssURL + devAPIUpdateInventoryPath + String(workingData.deviceID))
        Alamofire.request(workingjss.jssURL + devAPIUpdateInventoryPath + String(workingData.deviceID), method: .post).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseString { response in
            print("Respons back from the JSS")
            print(response.result)
            if (response.result.isSuccess) {
                print("Sent update inventory command")
            }
            else {
                print("Did not work")
                print(response.result.error ?? "Did not get back error code")
            }
        }
    }
    
    
    @IBAction func sendBlankPushPressed(_ sender: Any) {
        print("Send blank push pressed")
        print(workingjss.jssURL + devAPIBlankPushPath + String(workingData.deviceID))
        Alamofire.request(workingjss.jssURL + devAPIBlankPushPath + String(workingData.deviceID), method: .post).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseString { response in
            print("Resposne back from the JSS")
            print(response.result)
            if(response.result.isSuccess) {
                print("Sent blank push")
            }
            else {
                print("Did not work")
                print(response.result.error ?? "Did not get back error code")
            }
        }
    }
    
    @IBAction func removeRestrictionsPressed(_ sender: Any) {
        print("Remove Restrictions Pressed")
        // Add Headers
        let removeHeaders = [
            "Content-Type":"text/xml",
            ]
        
        // Custom Body Encoding
        struct RawDataEncoding: ParameterEncoding {
            public static var `default`: RawDataEncoding { return RawDataEncoding() }
            public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
                var request = try urlRequest.asURLRequest()
                request.httpBody = "<mobile_device_group><mobile_device_additions><mobile_device><id>\(String(workingData.deviceID))</id></mobile_device></mobile_device_additions></mobile_device_group>".data(using: String.Encoding.utf8, allowLossyConversion: false)
                return request
            }
        }
        // Fetch Request
        print(workingjss.jssURL + devAPIPath + workingjss.exclusinGID)
        Alamofire.request(workingjss.jssURL + devAPIPath + workingjss.exclusinGID, method: .put, encoding: RawDataEncoding.default, headers: removeHeaders).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword)
            .responseString { response in
                if (response.result.isSuccess) {
                    print("Added to troubleshooting group")
                    debugPrint("HTTP Response Body: \(response.data!)")
                }
                else {
                    debugPrint("HTTP Request failed: \(response.result.error!)")
                }
        }
    }
    
    @IBAction func reapplyRestrictionsPressed(_ sender: Any) {
        print("Reapply Restrictions Pressed")
        // Add Headers
        let reapplyHeaders = [
            "Content-Type":"text/xml",
            ]
        
        // Custom Body Encoding
        struct RawDataEncoding: ParameterEncoding {
            public static var `default`: RawDataEncoding { return RawDataEncoding() }
            public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
                var request = try urlRequest.asURLRequest()
                request.httpBody = "<mobile_device_group><mobile_device_deletions><mobile_device><id>\(String(workingData.deviceID))</id></mobile_device></mobile_device_deletions></mobile_device_group>".data(using: String.Encoding.utf8, allowLossyConversion: false)
                return request
            }
        }
        // Fetch Request
        print(workingjss.jssURL + devAPIPath + workingjss.exclusinGID)
        Alamofire.request(workingjss.jssURL + devAPIPath + workingjss.exclusinGID, method: .put, encoding: RawDataEncoding.default, headers: reapplyHeaders).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword)
            .responseString { response in
                if (response.result.isSuccess) {
                    print("Removed from troubleshooting group")
                    debugPrint("HTTP Response Body: \(response.data!)")
                }
                else {
                    debugPrint("HTTP Request failed: \(response.result.error!)")
                }
        }
    }
    
    
    
// Add Function here to get user data
    
func getUserInfo() {
        // Add two queue tasks to disparch queue
        JSSQueue.enter()
        JSSQueue.enter()
        // Fetch Request in JSON Format
        Alamofire.request(workingjss.jssURL + devAPIMatchPath + workingData.user, method: .get, headers: headers)
            .authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseJSON { response in
                //print(response.result.value ?? "Default")
                //workingData.responseData = response.result.value!
                if (response.result.isSuccess) {
                   // print(response.result.isSuccess)
                    //print("JSON we are going to store is this --------------")
                    //print(response.result.value!)
                    //print("End of JSON we are going to store ---------------")
                    //workingData.responseDataJSON = (response.result.value as? [String:Any])!
                    workingData.responseDataJSON = response.result.value as! [String : Any]
                    
                    if let outerDict = response.result.value as? Dictionary <String, AnyObject> {
                        if let mobileDevice = outerDict["mobile_devices"] as? [Dictionary<String,AnyObject>] {
                            let numberOfDevices = mobileDevice.count
                            print("Number of items in array is: \(numberOfDevices)")
                            if let deviceName = mobileDevice[0]["name"] as? String {
                                print("The name of the device is: \(deviceName)")
                                workingData.deviceName = deviceName
                                }
                            if let deviceSN = mobileDevice[0]["serial_number"] as? String {
                                print("The device Serial NUmber is: \(deviceSN)")
                                workingData.deviceSN = deviceSN
                            }
                            if let deviceMAC = mobileDevice[0]["mac_address"] as? String {
                                print("The deivce MAC Address is: \(deviceMAC)")
                                workingData.deviceMAC = deviceMAC
                            }
                            if let deviceID = mobileDevice[0]["id"] as? Int {
                                print("The devie ID is: \(deviceID)")
                                workingData.deviceID = deviceID
                            }
                            if let userName = mobileDevice[0]["realname"] as? String {
                                print("The device owner name is: \(userName)")
                                workingData.realName = userName
                            }
                        }
                    }
                    self.getDeviceInfo()
                }
        }
    
        // Fetch Request in String Format
        Alamofire.request(workingjss.jssURL + devAPIMatchPath + workingData.user, method: .get, headers: headers)
            .authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseString { response in
                //print(response.result.value ?? "Default")
                //workingData.responseData = response.result.value!
                if (response.result.isSuccess) {
                    // print(response.result.isSuccess)
                    //print(response.result.value!)
                    workingData.responseDataString = response.result.value!
                    JSSQueue.leave()
                }
            }
    }
    
    func getDeviceInfo() {
        Alamofire.request(workingjss.jssURL + devAPIMatchPathID + String(workingData.deviceID), method: .get, headers: headers).authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseJSON { response in
            if (response.result.isSuccess) {
                //print("Response data for device is --------------")
                //print(response.result.value!)
                if let outerDict = response.result.value as? Dictionary <String, AnyObject> {
                    if let mobileDeviceData = outerDict["mobile_device"] as? Dictionary <String,AnyObject> {
                        if let generalData = mobileDeviceData["general"] as? Dictionary <String, AnyObject> {
                            if let ip_address = generalData["ip_address"] as? String {
                                //print(ip_address)
                                workingData.deviceIPAddress = ip_address
                            }
                            if let inventoryTime = generalData["last_inventory_update"] as? String {
                                workingData.lastInventory = inventoryTime
                            }
                        }
                    }
                }
                //print("End of data for device -------------------")
                JSSQueue.leave()
            }
        }
        //print("Built URL to get info on device is: \(workingjss.jssURL)\(devAPIMatchPathID)\(String(workingData.deviceID))")
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

    func enableButtons() {
        updateInventoryButton.isEnabled = true
        sendBlankPushButton.isEnabled = true
        removeRestritionsButton.isEnabled = true
        reapplyRestrictionsButton.isEnabled = true
    }
    
    func parseData() {
        //print("=================================")
        //print("Data we will be parsing: \(workingData.responseDataJSON)")
        //print("Number of items: \(workingData.responseDataJSON.count)")
        //print("=================================")

    }

    
func updateUI() {
    //print("Update UI Function")
    let testURL = defaultsVC.string(forKey: "savedJSSURL")
    //print("\(testURL ?? "DEFAULT URL")")
    let testExclusionGID = defaultsVC.string(forKey: "savedExclusionGID")
    //print("\(testExclusionGID ?? "DEFAULT GID")")
    let testJSSUsername = defaultsVC.string(forKey: "savedJSSUsername")
    //print("\(testJSSUsername ?? "DEFAULT GID")")
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
