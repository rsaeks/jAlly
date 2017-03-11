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

let workingjss = JSSConfig()
let defaultsVC = UserDefaults()
let keychain = KeychainSwift()
let workingData = JSSData()

class ViewController: UIViewController {

    @IBOutlet weak var jssURLLabel: UILabel!
    @IBOutlet weak var jssGIDLabel: UILabel!
    @IBOutlet weak var jssUsernameLabel: UILabel!
    @IBOutlet weak var jssPasswordLabel: UILabel!
    @IBOutlet weak var userToCheck: UITextField!
    @IBOutlet weak var snToCheck: UITextField!

    
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
            print("Need to provide a username")
        }
        else {
            workingData.user = userToCheck.text!
            print("Provided Username is:")
            print(workingData.user)
            getUserInfo()
            print("Returned Data is:")
            print(workingData.responseData)
        }
    }
    
    @IBAction func snToCheckPressed(_ sender: Any) {
    }
    
// Add Function here to get user data
    
func getUserInfo() {
        // Add Headers
        let headers = [
            "Accept":"application/json",
            ]
        
        // Fetch Request
        Alamofire.request(workingjss.jssURL + devAPIMatchPath + workingData.user, method: .get, headers: headers)
            .authenticate(user: workingjss.jssUsername, password: workingjss.jssPassword).responseString { response in
                //print(response.result.value ?? "Default")
                workingData.responseData = response.result.value!
            }
    }
    

    
func updateUI() {
    print("Update UI Function")
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
