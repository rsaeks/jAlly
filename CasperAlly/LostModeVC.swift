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
    @IBOutlet weak var enableLostModeButton: actionButton!
    @IBOutlet weak var closeButton: actionButton!
    
    var lmMessage: String = ""
    var lmPhone: String = ""
    var lmFootnote: String = ""
    var lmAlwaysEnforce: Bool = false
    var lmSound: Bool = true
    
    override func viewDidLoad() {
        
        enableLostModeButton.layer.borderWidth = 1.0
        enableLostModeButton.layer.borderColor = UIColor.lightGray.cgColor
        closeButton.layer.borderWidth = 1.0
        closeButton.layer.borderColor = UIColor.lightGray.cgColor
        
        setButtonColors(color: UIColor.lightGray.cgColor, width: 1.0)
        
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
            lostModeMessageText.text = lmMessage
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
            lostModePhoneNumberText.text = lmPhone
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
            lostModeFootnoteText.text = lmFootnote
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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { self.view.endEditing(true) }
    override func viewDidAppear(_ animated: Bool) { cameFromLostMode = true }
    @IBAction func closeButtonPressed(_ sender: Any) { dismiss(animated: true, completion: nil) }
    
    
    @IBAction func enableLostModePressed(_ sender: UIButton) {
        
        setButtonColors(color: UIColor.lightGray.cgColor, width: 1)
        
        defaultsLM.set(lostModePhoneNumberText.text, forKey: "savedLostModePhone")
        defaultsLM.set(lostModeFootnoteText.text, forKey: "savedLostModeFootnote")
        defaultsLM.set(alwaysEnforceLostSwitch.isOn, forKey: "savedLostModeForced")
        defaultsLM.set(lostModeSoundSwitch.isOn, forKey: "savedLostModeSound")
        
//        LostMode.lostModeSettings.lostModeMessage = lostModeMessageText.text
//        LostMode.lostModeSettings.lostModeNumber = lostModePhoneNumberText.text
//        LostMode.lostModeSettings.lostModeFootNote = lostModeFootnoteText.text
        LostMode.lostModeSettings.lostModeForced = alwaysEnforceLostSwitch.isOn
        LostMode.lostModeSettings.lostModeSound = lostModeSoundSwitch.isOn
    
        
        print("Lost Mode Message contains text test: \(lostModeMessageText.hasText)")
        print("Lost Mode Phone Number contains text test: \(lostModePhoneNumberText.hasText)")
        print("Lost Mode Footnteo contains text: \(lostModeFootnoteText.hasText)")
        
        if (lostModeMessageText.hasText && lostModePhoneNumberText.hasText && lostModeFootnoteText.hasText) {
            sender.layer.borderWidth = 2.0
            sender.layer.borderColor = warnColor.cgColor
            print("Text fields all have data ... ")
//            let headers = [ "Content-Type":"application/xml", ]
//            // Custom Body Encoding
//            struct RawDataEncoding: ParameterEncoding {
//                public static var `default`: RawDataEncoding { return RawDataEncoding() }
//                public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
//                    var request = try urlRequest.asURLRequest()
//                    request.httpBody = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><mobile_device_command><general><command>EnableLostMode</command><lost_mode_message>\(LostMode.lostModeSettings.lostModeMessage!)</lost_mode_message><lost_mode_phone>\(LostMode.lostModeSettings.lostModeNumber!)</lost_mode_phone><lost_mode_footnote>\(LostMode.lostModeSettings.lostModeFootNote!)</lost_mode_footnote><always_enforce_lost_mode>\(LostMode.lostModeSettings.lostModeForced!)</always_enforce_lost_mode><lost_mode_with_sound>\(LostMode.lostModeSettings.lostModeSound!)</lost_mode_with_sound></general><mobile_devices><mobile_device><id>\(workingData.deviceID)</id></mobile_device></mobile_devices></mobile_device_command>".data(using: String.Encoding.utf8, allowLossyConversion: false)
//                    return request
//                }
//            }
//
//            // Fetch Request
//            Alamofire.request(workingjss.jssURL + devLostModePath, method: .post, encoding: RawDataEncoding.default, headers: headers)
//                .authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword)
//                .validate(statusCode: 200..<300)
//                .responseString { LMresponse in
//                    if (LMresponse.result.error == nil) { sender.layer.borderColor = successColor.cgColor }
//                    else { sender.layer.borderColor = failColor.cgColor }
//            } // Close Alamofire Request
        }
        else {
            print("One or more fields are empty")
            sender.layer.borderWidth = 1.0
            sender.layer.borderColor = UIColor.lightGray.cgColor
            if !lostModeMessageText.hasText {
                lostModeMessageText.layer.borderColor = failColor.cgColor
                lostModeMessageText.layer.borderWidth = 2.0
            }
            else { defaultsLM.set(lostModeMessageText.text, forKey: "savedLostModeMessage") }
            if !lostModePhoneNumberText.hasText {
                lostModePhoneNumberText.layer.borderColor = failColor.cgColor
                lostModePhoneNumberText.layer.borderWidth = 2.0
            }
            else { LostMode.lostModeSettings.lostModeNumber = lostModePhoneNumberText.text }
            if !lostModeFootnoteText.hasText {
                lostModeFootnoteText.layer.borderColor = failColor.cgColor
                lostModeFootnoteText.layer.borderWidth = 2.0
            }
            else { LostMode.lostModeSettings.lostModeFootNote = lostModeFootnoteText.text }
        }
    } // Close enableLostModePresed Function
    
    func setButtonColors(color: CGColor, width: Float) {
        lostModeMessageText.layer.borderColor = color
        lostModeMessageText.layer.borderWidth = CGFloat(width)
        lostModePhoneNumberText.layer.borderColor = color
        lostModePhoneNumberText.layer.borderWidth = CGFloat(width)
        lostModeFootnoteText.layer.borderColor = color
        lostModeFootnoteText.layer.borderWidth = CGFloat(width)
    }
    
}
