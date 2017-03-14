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
            workingData.user = userToCheck.text!
            //print("Provided Username is: \(workingData.user)")
            getUserInfo()
            JSSQueue.notify(queue: DispatchQueue.main, execute: {
                //print("Dispatch Queue Returned JSON Data is: \(workingData.responseDataJSON)")
                //print("Dispatch Queue Returned String Data is: \(workingData.responseDataString)")
                //self.debugData.text = workingData.responseDataString
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
                    
                    
                    JSSQueue.leave()
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
    
    func displayData() {
        deviceIDLabel.text = String(workingData.deviceID)
        deviceSNLabel.text = workingData.deviceSN
        deviceMACLabel.text = workingData.deviceMAC
        usernameLabel.text = workingData.user
        fullNameLabel.text = workingData.realName
        
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
