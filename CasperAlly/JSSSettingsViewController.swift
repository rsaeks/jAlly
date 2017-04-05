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
            //print("Checking URL: " + JSSURL.text!)
            Alamofire.request(JSSURL.text!).responseString { response in
                let statusCode = response.response?.statusCode
                //print(statusCode ?? 999)
                if statusCode == nil {
                    self.checkURLButton.layer.borderColor = failColor
                    self.checkURLButton.layer.borderWidth = 2
                    self.checkURLLabel.isEnabled = true
                    self.checkURLLabel.text = "No Response Received"
                    self.checkingConnection.stopAnimating()
                }
                else if statusCode == 401 {
                    self.checkURLButton.layer.borderColor = successColor
                    self.checkURLButton.layer.borderWidth = 2
                    self.checkURLLabel.isEnabled = false
                    self.checkURLLabel.text = "Authentifcation Required"
                    self.checkingConnection.stopAnimating()
                    self.checkUPButton.isEnabled = true
                }
                else if statusCode == 404 {
                    self.checkURLButton.layer.borderColor = failColor
                    self.checkURLButton.layer.borderWidth = 2
                    self.checkURLLabel.isEnabled = false
                    self.checkURLLabel.text = "URL Not Found"
                    self.checkingConnection.stopAnimating()
                }
                else {
                    self.checkURLButton.layer.borderColor = failColor
                    self.checkURLButton.layer.borderWidth = 2
                    self.checkURLLabel.isEnabled = false
                    self.checkURLLabel.text = "Other Error"
                    self.checkingConnection.stopAnimating()
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
                    self.checkUPButton.layer.borderColor = failColor
                    self.checkUPButton.layer.borderWidth = 2
                    self.checkUPLabel.isEnabled = true
                    self.checkUPLabel.text = "No Response"
                }
                else if userStatusCode == 200 {
                    self.checkUPButton.layer.borderColor = successColor
                    self.checkUPButton.layer.borderWidth = 2
                }
                else if userStatusCode == 401 {
                    self.checkUPButton.layer.borderColor = failColor
                    self.checkUPButton.layer.borderWidth = 2
                    self.checkUPLabel.isEnabled = true
                    self.checkUPLabel.text = "Invalid Username / Password Combo"
                }
                else if userStatusCode == 404 {
                    self.checkUPButton.layer.borderColor = successColor
                    self.checkUPButton.layer.borderWidth = 2
                }
                else {
                    self.checkUPButton.layer.borderColor = failColor
                    self.checkUPButton.layer.borderWidth = 2
                    self.checkUPLabel.isEnabled = true
                    self.checkUPLabel.text = "Other Error"
                }
            }
        }
    }
    
    @IBAction func jssSaveSettings(_ sender: Any) {
        //print("Save Settings Button Pressed")
        defaults.set(JSSURL.text, forKey: "savedJSSURL")
        defaults.set(jssExclusionGroupID.text, forKey: "savedExclusionGID")
        defaults.set(jssUsername.text, forKey: "savedJSSUsername")
        keychain.set(jssPassword.text!, forKey: "savedJSSPassword")
    }
    
    @IBAction func returnToMainPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //print("Settings View Appeared")
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
