//
//  ViewController.swift
//  CasperAlly
//
//  Created by Randy Saeks on 2/9/17.
//  Copyright © 2017 Randy Saeks. All rights reserved.
//

import UIKit

class JSSConfig {
    var jssURL: String
    var exclusinGID: String
    var jssUsername: String
    init() {
        jssURL = ""
        exclusinGID = ""
        jssUsername = ""
    }
}

let workingjss = JSSConfig()
let defaultsVC = UserDefaults()

class ViewController: UIViewController {

    @IBOutlet weak var jssURLLabel: UILabel!
    @IBOutlet weak var jssGIDLabel: UILabel!
    @IBOutlet weak var jssUsernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Loaded View Controller VIew")
        updateUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        updateUI()
    }

func updateUI() {
    let testURL = defaultsVC.string(forKey: "savedJSSURL")
    print("\(testURL ?? "DEFAULT URL")")
    let testExclusionGID = defaultsVC.string(forKey: "savedExclusionGID")
    print("\(testExclusionGID ?? "DEFAULT GID")")
    let testJSSUsername = defaultsVC.string(forKey: "savedJSSUsername")
    print("\(testJSSUsername ?? "DEFAULT GID")")
    
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
}

}

