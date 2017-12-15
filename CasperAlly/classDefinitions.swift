//
//  classDefinitions.swift
//  CasperAlly
//
//  Created by Randy Saeks on 3/10/17.
//  Copyright © 2017 Randy Saeks. All rights reserved.
//

import Foundation
import UIKit

public class actionButton: UIButton {
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0
        self.layer.cornerRadius = 5
    }
}

public class scanButton: UIButton {
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
    }
}

public class cameraScanButton: UIButton {
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
    }
}

class Settings {
    static var shared = Settings()
    private init() {}
    var jssURL: String!
    var exclusionGID: String!
    var jssUsername: String!
    var jssPassword: String!
    var snToCheck: String!
    var battWarnLevel: Int! = 30
    var battCritLevel: Int! = 15
    var freespaceWarnLevel: Int! = 80
    var freespaceCritLevel: Int! = 90
    var numbersOnlyIsOn: Bool! = false
}

class LostMode {
    static var lostModeSettings = LostMode()
    var lostModeMessage: String!
    var lostModeNumber: String!
    var lostModeFootNote: String!
    var lostModeForced: Bool!
    var lostModeSound: Bool!
    init () {
        lostModeMessage = "This device has been reported as lost"
        lostModeNumber = "1234567890"
        lostModeFootNote = "Lost device"
        lostModeForced = false
        lostModeSound = true
    }
}

class JSSConfig {
    var jssURL: String
    var exclusinGID: String
    var jssUsername: String
    var jssPassword: String
    var mobileDeviceKey: String
    var mobileDevicesKey: String
    var generalKey: String
    var purchasingKey: String
    var ipAddressKey: String
    var idKey: String
    var locationKey: String
    var usernameKey: String
    var realNameKey: String
    var deviceNameKey: String
    var serialNumberKey: String
    var MACAddressKey: String
    var inventoryKey: String
    var epochInventroryTimekey: String
    var osVersionKey: String
    var batteryLevelKey: String
    var freeSpaceKey: String
    var percentUsedKey: String
    var epochWarrantyExpiresKey: String
    init() {
        jssURL = ""
        exclusinGID = ""
        jssUsername = ""
        jssPassword = ""
        mobileDeviceKey = "mobile_device"
        mobileDevicesKey = "mobile_devices"
        generalKey = "general"
        purchasingKey = "purchasing"
        ipAddressKey = "ip_address"
        idKey = "id"
        locationKey = "location"
        usernameKey = "username"
        realNameKey = "realname"
        deviceNameKey = "device_name"
        serialNumberKey = "serial_number"
        MACAddressKey = "wifi_mac_address"
        inventoryKey = "asset_tag"
        epochInventroryTimekey = "last_inventory_update_epoch"
        osVersionKey = "os_version"
        batteryLevelKey = "battery_level"
        freeSpaceKey = "available_mb"
        percentUsedKey = "percentage_used"
        epochWarrantyExpiresKey = "warranty_expires_epoch"
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
    var deviceInventoryNumber: String
    var lastInventoryEpoc: Double
    var lastInventoryEpocFormatted: String
    var iOSVersion: String
    var batteryLevel: Int
    var freeSpace: Int
    var percentUsed: Int
    var warrantyExpiresEpoch: Double
    var warrantyExpiresEpochFormatted: String
    
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
        deviceInventoryNumber = "ToScan"
        lastInventoryEpoc = 0.0
        lastInventoryEpocFormatted = "To Set"
        iOSVersion = "0.0"
        batteryLevel = 101
        freeSpace = 0
        percentUsed = 0
        warrantyExpiresEpoch = 0.0
        warrantyExpiresEpochFormatted = "To Set"
    }
}
