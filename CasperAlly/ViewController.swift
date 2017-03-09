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

class JSSConfig {
    var jssURL: String
    var exclusinGID: String
    var jssUsername: String
    var jssPassword: String
    init() {
        jssURL = ""
        exclusinGID = ""
        jssUsername = ""
        jssPassword = ""
    }
}

let workingjss = JSSConfig()
let defaultsVC = UserDefaults()
let keychain = KeychainSwift()

class ViewController: UIViewController {

    @IBOutlet weak var jssURLLabel: UILabel!
    @IBOutlet weak var jssGIDLabel: UILabel!
    @IBOutlet weak var jssUsernameLabel: UILabel!
    @IBOutlet weak var jssPasswordLabel: UILabel!
    @IBOutlet weak var connectionStatus: UIActivityIndicatorView!
    
    @IBOutlet weak var responseBack: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        print("Main View Controller Appeared")
        updateUI()
        connectionStatus.stopAnimating()
    }

//    @IBAction func testConnectionPressed(_ sender: Any) {
//        print("Test Connection Button Pressed")
//        connectionStatus.startAnimating()
//        self.responseBack.isHidden = true
//        Alamofire.request(workingjss.jssURL).response { response in
//            if response.response == nil {
//                print("Blank Response Back")
//            }
//            else {
//                print("Received some data back")
//                self.responseBack.isHidden = false
//                self.connectionStatus.stopAnimating()
//            }
//            print(response.data ?? "Default Data")     // server data
//            }
//    }
    
    
func updateUI() {
    print("Update UI Function")
    let testURL = defaultsVC.string(forKey: "savedJSSURL")
    print("\(testURL ?? "DEFAULT URL")")
    let testExclusionGID = defaultsVC.string(forKey: "savedExclusionGID")
    print("\(testExclusionGID ?? "DEFAULT GID")")
    let testJSSUsername = defaultsVC.string(forKey: "savedJSSUsername")
    print("\(testJSSUsername ?? "DEFAULT GID")")
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
