//
//  JSSSettingsViewController.swift
//  CasperAlly
//
//  Created by Randy Saeks on 2/9/17.
//  Copyright © 2017 Randy Saeks. All rights reserved.
//

import UIKit
import Alamofire


class JSSSettingsViewController: UIViewController {

    @IBOutlet weak var JSSURL: UITextField!
    @IBOutlet weak var jssExclusionGroupID: UITextField!
    @IBOutlet weak var jssUsername: UITextField!
    @IBOutlet weak var jssPassword: UITextField!
    @IBOutlet weak var checkURLLabel: UILabel!
    @IBOutlet weak var checkUPLabel: UILabel!
    @IBOutlet weak var checkURLButton: UIButton!
    @IBOutlet weak var checkUPButton: UIButton!
    @IBOutlet weak var checkingConnection: UIActivityIndicatorView!
    @IBOutlet weak var batteryWarnLevel: UITextField!
    @IBOutlet weak var batteryCritLevel: UITextField!
    @IBOutlet weak var freespaceWarnLevel: UITextField!
    @IBOutlet weak var freespaceCritLevel: UITextField!

    
    let defaults = UserDefaults.standard
    
    
    @IBAction func checkURLButtonPressed(_ sender: Any) {
        if (JSSURL.text != "" ) {
            checkingConnection.startAnimating()
            self.checkURLButton.layer.borderColor = UIColor.lightGray.cgColor
            Alamofire.request(JSSURL.text!).responseString { response in
                let statusCode = response.response?.statusCode
                if statusCode == nil {
                    self.URLStatus(buttonColor: failColor.cgColor, showError: true, message: "No Response Received")
                }
                else if statusCode == 401 {
                    self.checkUPButton.isEnabled = true
                    self.URLStatus(buttonColor: successColor.cgColor, showError: false, message: "Please Provide Username & Password")
                }
                else if statusCode == 404 {
                    self.URLStatus(buttonColor: failColor.cgColor, showError: true, message: "URL Not Found")
                }
                else {
                    self.URLStatus(buttonColor: failColor.cgColor, showError: true, message: "Other Error")
                }
            }
        }
    }
    
    
    @IBAction func checkUPPressed(_ sender: Any) {
        self.checkUPButton.layer.borderColor = UIColor.lightGray.cgColor
        if (self.jssUsername.text != "") {
            Alamofire.request(JSSURL.text! + userPath + jssUsername.text!).authenticate(user: jssUsername.text!, password: savedSettings.sharedInstance.jssPassword).responseString { response in
                let userStatusCode = response.response?.statusCode
                if userStatusCode == nil {
                    self.UPStatus(buttonColor: failColor.cgColor, hideLabel: false, message: "No Response")
                }
                else if userStatusCode == 200 {
                    self.UPStatus(buttonColor: successColor.cgColor, hideLabel: true, message: "Valid Username & Password")
                }
                else if userStatusCode == 401 {
                    self.UPStatus(buttonColor: failColor.cgColor, hideLabel: false, message: "Invalid Username / Password Combo")
                }
                else if userStatusCode == 404 {
                    self.UPStatus(buttonColor: successColor.cgColor, hideLabel: true, message: "JSS Only user with no assigned device")
                }
                else {
                    self.UPStatus(buttonColor: failColor.cgColor, hideLabel: false, message: "Other Error")
                }
            }
        }
    }
    
    @IBAction func jssSaveSettings(_ sender: Any) {
        defaults.set(JSSURL.text, forKey: "savedJSSURL")
        defaults.set(jssExclusionGroupID.text, forKey: "savedExclusionGID")
        defaults.set(jssUsername.text, forKey: "savedJSSUsername")
        
//        if (batteryWarnLevel.text == nil) {
//            defaults.set("30", forKey: "batteryWarnLevel")
//        }
//        else {
            defaults.set(batteryWarnLevel.text, forKey: "batteryWarnLevel")
//        }
        
//        if (batteryCritLevel.text == nil) {
//            defaults.set("15", forKey: "batteryCritLievel")
//        }
//        else {
            defaults.set(batteryCritLevel.text, forKey: "batteryCritLevel")
//        }
        
//        if (freespaceWarnLevel.text == nil) {
//            defaults.set("80", forKey: "freespaceWarnLevel")
//        }
//        else {
            defaults.set(freespaceWarnLevel.text, forKey: "freespaceWarnLevel")
//        }
        
//        if (freespaceCritLevel.text == nil) {
//            defaults.set("90", forKey: "freespaceCritLevel")
//        }
//        else {
            defaults.set(freespaceCritLevel.text, forKey: "freespaceCritLevel")
//        }
        
        keychain.set(jssPassword.text!, forKey: "savedJSSPassword")
    }
    
    @IBAction func returnToMainPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func statusIconInfoPressed(_ sender: Any) {
        let statusIconHelp = UIAlertController(title: "Status Icon Help", message: "You may change status icon notification thresholds to levels more suitable to your enviornment. Warning will trigger an orange dot, Critical will tigger a red dot. All options are expressed as a percentage.", preferredStyle: UIAlertControllerStyle.alert)
        statusIconHelp.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(statusIconHelp, animated: true)
        
        
    }
    func URLStatus (buttonColor: CGColor, showError: Bool, message: String) {
        self.checkURLButton.layer.borderWidth = 2
        self.checkingConnection.stopAnimating()
        self.checkURLButton.layer.borderColor = buttonColor
        self.checkUPLabel.isEnabled = showError
        self.checkUPLabel.text = message
    }
    
    func UPStatus (buttonColor: CGColor, hideLabel: Bool, message: String) {
        self.checkUPButton.layer.borderWidth = 2
        self.checkUPButton.layer.borderColor = buttonColor
        self.checkUPLabel.isHidden = hideLabel
        self.checkUPLabel.text = message
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let testURL = defaults.string(forKey: "savedJSSURL")
        let testExclusionGID = defaults.string(forKey: "savedExclusionGID")
        let testJSSUsername = defaults.string(forKey: "savedJSSUsername")
        let testJSSPassword = keychain.get("savedJSSPassword")
        checkingConnection.hidesWhenStopped = true
        let battWarnLevel = defaults.string(forKey: "batteryWarnLevel")
//        if battWarnLevel == nil {
//            savedSettings.sharedInstance.battWarnLevel = 30
//        }
        let battCritLevel = defaults.string(forKey: "batteryCritLevel")
//        if (battCritLevel == nil) {
//            savedSettings.sharedInstance.battCritLevel = 15
//        }
        let freeWarnLevel = defaults.string(forKey: "freespaceWarnLevel")
//        if (freeWarnLevel == nil) {
//            savedSettings.sharedInstance.freespaceWarnLevel = 80
//        }
        let freeCritLevel = defaults.string(forKey: "freespaceCritLevel")
//        if (freeCritLevel == nil) {
//            savedSettings.sharedInstance.freespaceCritLevel = 90
//        }
        
        // Test to make sure JSS URL is populated
        if testURL != nil {
            JSSURL.text = testURL
            savedSettings.sharedInstance.jssURL = JSSURL.text
        }
        
        // Test to make sure JSS exclusion GID is populated
        if testExclusionGID != nil {
            jssExclusionGroupID.text = testExclusionGID
            savedSettings.sharedInstance.exclusionGID = jssExclusionGroupID.text
        }
        
        // Test to make sure JSS Username is populated
        if testJSSUsername != nil {
            jssUsername.text = testJSSUsername
            savedSettings.sharedInstance.jssUsername = jssUsername.text
        }
        
        // Test to make sure JSS Password is populated
        if testJSSPassword != nil {
            jssPassword.text = testJSSPassword
            savedSettings.sharedInstance.jssPassword = jssPassword.text
        }
        
        if (battWarnLevel != "") {
            batteryWarnLevel.text = battWarnLevel
            savedSettings.sharedInstance.battWarnLevel = Int(battWarnLevel!)
        }
        else { savedSettings.sharedInstance.battWarnLevel = 30 }
        
        if (battCritLevel != "") {
            batteryCritLevel.text = battCritLevel
            savedSettings.sharedInstance.battCritLevel = Int(battCritLevel!)
        }
        else { savedSettings.sharedInstance.battCritLevel = 15 }
        
        if (freeWarnLevel != "") {
            freespaceWarnLevel.text = freeWarnLevel
            savedSettings.sharedInstance.freespaceWarnLevel = Int(freeWarnLevel!)

        }
        else { savedSettings.sharedInstance.freespaceWarnLevel = 80 }
        
        if (freeCritLevel != "") {
            freespaceCritLevel.text = freeCritLevel
            savedSettings.sharedInstance.freespaceCritLevel = Int(freeCritLevel!)
        }
        else { savedSettings.sharedInstance.freespaceCritLevel = 90 }
    }
}
