//
//  JSSSettingsViewController.swift
//  CasperAlly
//
//  Created by Randy Saeks on 2/9/17.
//  Copyright © 2017 Randy Saeks. All rights reserved.
//

import UIKit
import Alamofire

class savedSettings {
    static var sharedInstance = savedSettings()
    private init() {}
    var jssURL: String!
    var exclusionGID: String!
    var jssUsername: String!
    var jssPassword: String!
}

class JSSSettingsViewController: UIViewController {

    @IBOutlet weak var JSSURL: UITextField!
    @IBOutlet weak var jssExclusionGroupID: UITextField!
    @IBOutlet weak var jssUsername: UITextField!
    @IBOutlet weak var jssPassword: UITextField!
    @IBOutlet weak var checkURLLabel: UILabel!
    @IBOutlet weak var checkUPLabel: UILabel!

    
    let defaults = UserDefaults.standard
    
    
    @IBAction func checkURLButtonPressed(_ sender: Any) {
        Alamofire.request(savedSettings.sharedInstance.jssURL).response { response in
            let statusCode = response.response?.statusCode
            if statusCode == nil {
                self.checkURLLabel.text = "No response"
            }
            else if statusCode == 401 {
                self.checkURLLabel.text = "Auth Required"
            }
            else if statusCode == 404 {
                self.checkURLLabel.text = "URL not found"
            }
            else {
                self.checkURLLabel.text = "Other Error"
            }
        }
    }
    
    @IBAction func checkUPPressed(_ sender: Any) {
        //let builtURL: String = savedSettings.sharedInstance.jssURL + userPath + savedSettings.sharedInstance.jssUsername
        //print(builtURL)
        Alamofire.request(savedSettings.sharedInstance.jssURL + userPath + savedSettings.sharedInstance.jssUsername).authenticate(user: savedSettings.sharedInstance.jssUsername, password: savedSettings.sharedInstance.jssPassword).response { response in
            let userStatusCode = response.response?.statusCode
            if userStatusCode == nil {
                self.checkUPLabel.text = "No Response"
            }
            else if userStatusCode == 200 {
                self.checkUPLabel.text = "Valid combo"
            }
            else if userStatusCode == 401 {
                self.checkUPLabel.text = "Invalid combo"
            }
            else {
                self.checkUPLabel.text = "Other Error"
            }
        }

    }
    
    @IBAction func jssSaveSettings(_ sender: Any) {
        print("Save Settings Button Pressed")
        defaults.set(JSSURL.text, forKey: "savedJSSURL")
        defaults.set(jssExclusionGroupID.text, forKey: "savedExclusionGID")
        defaults.set(jssUsername.text, forKey: "savedJSSUsername")
        keychain.set(jssPassword.text!, forKey: "savedJSSPassword")
    }
    
    @IBAction func returnToMainPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Settings View Appeared")
        let testURL = defaults.string(forKey: "savedJSSURL")
        let testExclusionGID = defaults.string(forKey: "savedExclusionGID")
        let testJSSUsername = defaults.string(forKey: "savedJSSUsername")
        let testJSSPassword = keychain.get("savedJSSPassword")

        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
