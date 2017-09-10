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
    @IBOutlet weak var checkURLButton: UIButton!
    @IBOutlet weak var checkUPButton: UIButton!
    @IBOutlet weak var checkingConnection: UIActivityIndicatorView!
    @IBOutlet weak var batteryWarnLevel: UITextField!
    @IBOutlet weak var batteryCritLevel: UITextField!
    @IBOutlet weak var freespaceWarnLevel: UITextField!
    @IBOutlet weak var freespaceCritLevel: UITextField!
    @IBOutlet weak var connectionErrorLabel: UILabel!

    
    let defaults = UserDefaults.standard
    
    
    @IBAction func checkURLButtonPressed(_ sender: Any) {
        if (JSSURL.text != "" ) {
            self.connectionErrorLabel.isHidden = true
            checkingConnection.startAnimating()
            self.checkURLButton.layer.borderColor = UIColor.lightGray.cgColor
           Alamofire.request(JSSURL.text!).responseString { response in
                let statusCode = response.response?.statusCode
                if statusCode != nil {
                    if statusCode == 401 {
                        self.checkUPButton.isEnabled = true
                        self.URLStatus(buttonColor: successColor.cgColor, hideMessage: true, message: "Please Provide Username & Password")
                    }
                    else if statusCode == 404 {
                        self.URLStatus(buttonColor: failColor.cgColor, hideMessage: false, message: "Please check path to JSS")
                    }
                    else {
                        self.URLStatus(buttonColor: failColor.cgColor, hideMessage: false, message: "Other Error")
                    }
                }
                else {
                    self.URLStatus(buttonColor: failColor.cgColor, hideMessage: false, message: "No Response Received from JSS")
                }
            }
        }
    }
    
    @IBAction func checkUPPressed(_ sender: Any) {
        self.checkUPButton.layer.borderColor = UIColor.lightGray.cgColor
        self.connectionErrorLabel.isHidden = true
        if (self.jssUsername.text != "") {
            if (self.jssPassword.text != "") {
//                Alamofire.request(JSSURL.text! + userPath + jssUsername.text!).authenticate(user: jssUsername.text!, password: Settings.shared.jssPassword).responseString { response in
                Alamofire.request(JSSURL.text! + userPath + jssUsername.text!).authenticate(user: jssUsername.text!, password: jssPassword.text!).responseString { response in
                    let userStatusCode = response.response?.statusCode
                    if userStatusCode == nil {
                        self.UPStatus(buttonColor: failColor.cgColor, hideMessage: false, message: "No Response")
                    }
                    else if userStatusCode == 200 {
                        self.UPStatus(buttonColor: successColor.cgColor, hideMessage: true, message: "Valid Username & Password")
                    }
                    else if userStatusCode == 401 {
                        self.UPStatus(buttonColor: failColor.cgColor, hideMessage: false, message: "Invalid Username / Password Combo")
                    }
                    else if userStatusCode == 404 {
                        self.UPStatus(buttonColor: successColor.cgColor, hideMessage: true, message: "JSS Only user with no assigned device")
                    }
                    else {
                        self.UPStatus(buttonColor: failColor.cgColor, hideMessage: false, message: "Please check URL")
                    }
                }
            }
        }
    }
    
    @IBAction func jssSaveSettings(_ sender: Any) {
        defaults.set(JSSURL.text, forKey: "savedJSSURL")
        defaults.set(jssExclusionGroupID.text, forKey: "savedExclusionGID")
        defaults.set(jssUsername.text, forKey: "savedJSSUsername")
        defaults.set(batteryWarnLevel.text, forKey: "batteryWarnLevel")
        defaults.set(batteryCritLevel.text, forKey: "batteryCritLevel")
        defaults.set(freespaceWarnLevel.text, forKey: "freespaceWarnLevel")
        defaults.set(freespaceCritLevel.text, forKey: "freespaceCritLevel")
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
    func URLStatus (buttonColor: CGColor, hideMessage: Bool, message: String) {
        self.checkURLButton.layer.borderWidth = 2
        self.checkingConnection.stopAnimating()
        self.checkURLButton.layer.borderColor = buttonColor
        self.connectionErrorLabel.isHidden = hideMessage
        self.connectionErrorLabel.text = message
    }
    
    func UPStatus (buttonColor: CGColor, hideMessage: Bool, message: String) {
        self.checkUPButton.layer.borderWidth = 2
        self.checkUPButton.layer.borderColor = buttonColor
        self.connectionErrorLabel.isHidden = hideMessage
        self.connectionErrorLabel.text = message
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkingConnection.hidesWhenStopped = true


        // Test to make sure JSS URL is populated
        if (defaults.string(forKey: "savedJSSURL") != nil) {
            (JSSURL.text, Settings.shared.jssURL)  = (defaults.string(forKey: "savedJSSURL"),defaults.string(forKey: "savedJSSURL"))
        }
        
        // Test to make sure JSS exclusion GID is populated
        if (defaults.string(forKey: "savedExclusionGID") != nil) {
            (jssExclusionGroupID.text, Settings.shared.exclusionGID) = (defaults.string(forKey: "savedExclusionGID"), defaults.string(forKey: "savedExclusionGID"))
        }

        // Test to make sure JSS Username is populated
        if (defaults.string(forKey: "savedJSSUsername") != nil) {
            (jssUsername.text, Settings.shared.jssUsername) = (defaults.string(forKey: "savedJSSUsername"),defaults.string(forKey: "savedJSSUsername"))
        }
        
        // Test to make sure JSS Password is populated
        if (keychain.get("savedJSSPassword") != nil) {
            (jssPassword.text, Settings.shared.jssPassword) = (keychain.get("savedJSSPassword"),keychain.get("savedJSSPassword"))
        }
        
        if (defaults.string(forKey: "batteryWarnLevel") != nil) {
            if defaults.string(forKey: "batteryWarnLevel") != "" {
                (batteryWarnLevel.text, Settings.shared.battWarnLevel) = (defaults.string(forKey: "batteryWarnLevel"), Int(defaults.string(forKey: "batteryWarnLevel")!))
            }
        }

        if (defaults.string(forKey: "batteryCritLevel") != nil) {
            if defaults.string(forKey: "batteryCritLevel") != "" {
                (batteryCritLevel.text, Settings.shared.battCritLevel) = (defaults.string(forKey: "batteryCritLevel"), Int(defaults.string(forKey: "batteryCritLevel")!))
            }
        }
        
        if (defaults.string(forKey: "freespaceWarnLevel") != nil) {
            if defaults.string(forKey: "freespaceWarnLevel") != "" {
                (freespaceWarnLevel.text, Settings.shared.freespaceWarnLevel)  = (defaults.string(forKey: "freespaceWarnLevel"), Int(defaults.string(forKey: "freespaceWarnLevel")!))
            }
        }
        
        if (defaults.string(forKey: "freespaceCritLevel") != nil) {
            if defaults.string(forKey: "freespaceCritLevel") != "" {
                (freespaceCritLevel.text, Settings.shared.freespaceCritLevel)  = (defaults.string(forKey: "freespaceCritLevel"), Int(defaults.string(forKey: "freespaceCritLevel")!))
            }
        }
    }
    
    func initSettings() {
        Settings.shared.battWarnLevel = 30
        Settings.shared.battCritLevel = 15
        Settings.shared.freespaceWarnLevel = 80
        Settings.shared.freespaceCritLevel = 90
    }
}
