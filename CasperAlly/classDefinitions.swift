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
    var mobileDeviceKey: String
    var mobileDevicesKey: String
    var generalKey: String
    var ipAddressKey: String
    var inventoryTimeKey: String
    var idKey: String
    var locationKey: String
    var usernameKey: String
    var realNameKey: String
    var deviceNameKey: String
    var serialNumberKey: String
    var MACAddressKey: String
    var inventoryKey: String
    init() {
        jssURL = ""
        exclusinGID = ""
        jssUsername = ""
        jssPassword = ""
        mobileDeviceKey = "mobile_device"
        mobileDevicesKey = "mobile_devices"
        generalKey = "general"
        ipAddressKey = "ip_address"
        inventoryTimeKey = "last_inventory_update"
        idKey = "id"
        locationKey = "location"
        usernameKey = "username"
        realNameKey = "realname"
        deviceNameKey = "name"
        serialNumberKey = "serial_number"
        MACAddressKey = "mac_address"
        inventoryKey = "asset_tag"
    }
}

class JSSData {
    var user: String
    var deviceSN: String
    var deviceMAC: String
    var responseDataJSON: [String:Any] // Look to phase out
    var responseDataString: String // Look tp phase out
    var deviceName: String
    var deviceID: Int
    var realName: String
    var deviceIPAddress: String
    var lastInventory: String
    var deviceInventoryNumber: String
    init () {
        user = "defaultUser"
        deviceSN = "0"
        deviceMAC = "00:"
        responseDataJSON = ["defaultKey":"defaultValue"]
        responseDataString = ""
        deviceName = "Default Device Name"
        deviceID = 0
        realName = "RSMB"
        deviceIPAddress = "0.0.0.0"
        lastInventory = "October 28"
        deviceInventoryNumber = "ToScan"
    }
}
