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

    
    let defaults = UserDefaults.standard
    
    
    @IBAction func checkURLButtonPressed(_ sender: Any) {
        if (JSSURL.text != "" ) {
            checkingConnection.startAnimating()
            self.checkURLButton.layer.borderColor = UIColor.lightGray.cgColor
            Alamofire.request(JSSURL.text!).responseString { response in
                let statusCode = response.response?.statusCode
                if statusCode == nil {
                    self.URLStatus(buttonColor: failColor, showError: true, message: "No Response Received")
                }
                else if statusCode == 401 {
                    self.checkUPButton.isEnabled = true
                    self.URLStatus(buttonColor: successColor, showError: false, message: "Please Provide Username & Password")
                }
                else if statusCode == 404 {
                    self.URLStatus(buttonColor: failColor, showError: true, message: "URL Not Found")
                }
                else {
                    self.URLStatus(buttonColor: failColor, showError: true, message: "Other Error")
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
                    self.UPStatus(buttonColor: failColor, hideLabel: false, message: "No Response")
                }
                else if userStatusCode == 200 {
                    self.UPStatus(buttonColor: successColor, hideLabel: true, message: "Valid Username & Password")
                }
                else if userStatusCode == 401 {
                    self.UPStatus(buttonColor: failColor, hideLabel: false, message: "Invalid Username / Password Combo")
                }
                else if userStatusCode == 404 {
                    self.UPStatus(buttonColor: successColor, hideLabel: true, message: "JSS Only user with no assigned device")
                }
                else {
                    self.UPStatus(buttonColor: failColor, hideLabel: false, message: "Other Error")
                }
            }
        }
    }
    
    @IBAction func jssSaveSettings(_ sender: Any) {
        defaults.set(JSSURL.text, forKey: "savedJSSURL")
        defaults.set(jssExclusionGroupID.text, forKey: "savedExclusionGID")
        defaults.set(jssUsername.text, forKey: "savedJSSUsername")
        keychain.set(jssPassword.text!, forKey: "savedJSSPassword")
    }
    
    @IBAction func returnToMainPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    }
}
