//
//  classDefinitions.swift
//  CasperAlly
//
//  Created by Randy Saeks on 3/10/17.
//  Copyright © 2017 Randy Saeks. All rights reserved.
//

import Foundation

class savedSettings {
    static var sharedInstance = savedSettings()
    private init() {}
    var jssURL: String!
    var exclusionGID: String!
    var jssUsername: String!
    var jssPassword: String!
}


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

class JSSData {
    var user: String
    var deviceSN: String
    var deviceMAC: String
    var responseData: [String:Any]
    init () {
        user = "defaultUser"
        deviceSN = "0"
        deviceMAC = "00:"
        responseData = ["defaultKey":"defaultValue"]
    }
}
