//
//  LostModeVC.swift
//  jAlly
//
//  Created by Randy Saeks on 12/15/17.
//  Copyright © 2017 Randy Saeks. All rights reserved.
//

import UIKit
import Alamofire

let defaultsLM = UserDefaults()

class LostModeVC: UIViewController {

    @IBOutlet weak var lostModeMessageText: UITextView!
    @IBOutlet weak var lostModePhoneNumberText: UITextField!
    @IBOutlet weak var lostModeFootnoteText: UITextView!
    @IBOutlet weak var alwaysEnforceLostSwitch: UISwitch!
    @IBOutlet weak var lostModeSoundSwitch: UISwitch!
    
    var lmMessage: String = ""
    var lmPhone: String = ""
    var lmFootnote: String = ""
    var lmAlwaysEnforce: Bool = false
    var lmSound: Bool = true
    
    override func viewDidLoad() {
        

        lostModeMessageText.layer.borderWidth = 1
        lostModeMessageText.layer.borderColor = UIColor.lightGray.cgColor
        lostModeFootnoteText.layer.borderWidth = 1
        lostModeFootnoteText.layer.borderColor = UIColor.lightGray.cgColor
        lostModePhoneNumberText.layer.borderWidth = 1
        lostModePhoneNumberText.layer.borderColor = UIColor.lightGray.cgColor
        
        print("View did load....")
        super.viewDidLoad()
        
        if let lmMessage = defaultsLM.string(forKey: "savedLostModeMessage") {
            print("Data present in VDL for message: \(lmMessage)")
            lostModeMessageText.text = lmMessage
            LostMode.lostModeSettings.lostModeMessage = lmMessage
        }
        else {
            print("No Saved Lost Mode Message Present...initilaizing")
            lmMessage = "Default Lost Mode Message"
            LostMode.lostModeSettings.lostModeMessage = lmMessage
        }
        
        if let lmPhone = defaultsLM.string(forKey: "savedLostModePhone") {
            print("Data present in VDL for Phone: \(lmPhone)")
            lostModePhoneNumberText.text = lmPhone
            LostMode.lostModeSettings.lostModeNumber = lmPhone
        }
        else {
            print("No Saved Lost Mode Phone Present...initilaizing")
            lmPhone = "123-456-7890"
            LostMode.lostModeSettings.lostModeNumber = lmPhone
        }
        
        if let lmFootnote = defaultsLM.string(forKey: "savedLostModeFootnote") {
            print("Data present in VDL for footnote: \(lmFootnote)")
            lostModeFootnoteText.text = lmFootnote
            LostMode.lostModeSettings.lostModeFootNote = lmFootnote
        }
        else {
            print("No Saved Lost Mode Footnote Present...initilaizing")
            lmFootnote = "Device is lost"
            LostMode.lostModeSettings.lostModeFootNote = lmFootnote
        }
        
        if defaultsLM.bool(forKey: "savedLostModeForced") == true {
            print("Lost mode enforced = true")
            alwaysEnforceLostSwitch.isOn = true
            LostMode.lostModeSettings.lostModeForced = true
        }
        else {
            print("Lost mode enforced set to false or unknown ...")
            //lmAlwaysEnforce = false
            alwaysEnforceLostSwitch.isOn = false
            LostMode.lostModeSettings.lostModeForced = false
        }
        
        if defaultsLM.bool(forKey: "savedLostModeSound") == false {
            print("Lost Mode sound set to false or unitilized")
            lostModeSoundSwitch.isOn = false
            LostMode.lostModeSettings.lostModeSound = false
        }
        else {
            print("Lost mode sound set to on ")
            //lmAlwaysEnforce = true
            lostModeSoundSwitch.isOn = true
            LostMode.lostModeSettings.lostModeSound = true
        }
        
        // Let's setup our view data
        //lostModeMessageText.text = lmMessage
        //lostModePhoneNumberText.text = lmPhone
        //lostModeFootnoteText.text = lmFootnote
//        alwaysEnforceLostSwitch.isOn = lmAlwaysEnforce
//        lostModeSoundSwitch.isOn = lmSound
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {

        cameFromLostMode = true
        print("Setting came from lost mode to true:\(cameFromLostMode)")
//        print("View appeared ... here is the loaded data")
//        print("Message to use: \(lmMessage)")
//        print("Has length: \(lmMessage.count)")
//        print("Phone number to use: \(lmPhone)")
//        print("Footnote to use: \(lmFootnote)")
//        print("Enforced Lost Mode status: \(lmAlwaysEnforce)")
//        print("Play sound Status: \(lmSound)")
//        print("Now to pass back data....")
//        
//        print("Here are settings as of View Did Appear:")
//        print("Message: \(String(describing: lostModeMessageText.text))")
//        //print("Message length for lost message: \(String(describing: lostModeMessageText.text?.count))")
//        print("Phone: \(String(describing: lostModePhoneNumberText.text))")
//        print("Message length for phone : \(String(describing: lostModePhoneNumberText.text?.count))")
//        print("Footnote: \(String(describing: lostModeFootnoteText.text))")
//        print("Message length for footnote: \(String(describing: lostModeFootnoteText.text?.count))")
//        print("Always Enforce: \(alwaysEnforceLostSwitch.isOn)")
//        print("Play sound: \(lostModeSoundSwitch.isOn)")
        
       
        
    }
    
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func enableLostModePressed(_ sender: UIButton) {
        
    
        defaultsLM.set(lostModeMessageText.text, forKey: "savedLostModeMessage")
        defaultsLM.set(lostModePhoneNumberText.text, forKey: "savedLostModePhone")
        defaultsLM.set(lostModeFootnoteText.text, forKey: "savedLostModeFootnote")
        defaultsLM.set(alwaysEnforceLostSwitch.isOn, forKey: "savedLostModeForced")
        defaultsLM.set(lostModeSoundSwitch.isOn, forKey: "savedLostModeSound")
        
        LostMode.lostModeSettings.lostModeMessage = lostModeMessageText.text
        LostMode.lostModeSettings.lostModeNumber = lostModePhoneNumberText.text
        LostMode.lostModeSettings.lostModeFootNote = lostModeFootnoteText.text
        LostMode.lostModeSettings.lostModeForced = alwaysEnforceLostSwitch.isOn
        LostMode.lostModeSettings.lostModeSound = lostModeSoundSwitch.isOn
        
        sender.layer.borderWidth = 2.0
        sender.layer.borderColor = warnColor.cgColor
        
        let headers = [ "Content-Type":"application/xml", ]
        
        // Custom Body Encoding
        struct RawDataEncoding: ParameterEncoding {
            public static var `default`: RawDataEncoding { return RawDataEncoding() }
            public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
                var request = try urlRequest.asURLRequest()
                //                print("Incoming Data....")
                //                print(LostMode.lostModeSettings.lostModeMessage) - Done
                //                print(LostMode.lostModeSettings.lostModeNumber) - Done
                //                print(LostMode.lostModeSettings.lostModeFootNote) - Done
                //                print(LostMode.lostModeSettings.lostModeForced) - Done
                //                print(LostMode.lostModeSettings.lostModeSound)
                request.httpBody = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><mobile_device_command><general><command>EnableLostMode</command><lost_mode_message>\(LostMode.lostModeSettings.lostModeMessage!)</lost_mode_message><lost_mode_phone>\(LostMode.lostModeSettings.lostModeNumber!)</lost_mode_phone><lost_mode_footnote>\(LostMode.lostModeSettings.lostModeFootNote!)</lost_mode_footnote><always_enforce_lost_mode>\(LostMode.lostModeSettings.lostModeForced!)</always_enforce_lost_mode><lost_mode_with_sound>\(LostMode.lostModeSettings.lostModeSound!)</lost_mode_with_sound></general><mobile_devices><mobile_device><id>\(workingData.deviceID)</id></mobile_device></mobile_devices></mobile_device_command>".data(using: String.Encoding.utf8, allowLossyConversion: false)
                return request
            }
        }
        
        // Fetch Request
        //print(workingjss.jssURL + devLostModePath)
        Alamofire.request(workingjss.jssURL + devLostModePath, method: .post, encoding: RawDataEncoding.default, headers: headers)
            .authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword)
            .validate(statusCode: 200..<300)
            .responseString { LMresponse in
                if (LMresponse.result.error == nil) {
                    print("Successful Command")
                    sender.layer.borderColor = successColor.cgColor
                    //debugPrint("HTTP Response Body: \(response.data)")
                }
                else {
                    print("Failed Command")
                    sender.layer.borderColor = failColor.cgColor
                    //debugPrint("HTTP Request failed: \(response.result.error)")
                }
        }
        
    }
}
