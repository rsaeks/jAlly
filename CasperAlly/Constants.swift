//
//  Constants.swift
//  CasperAlly
//
//  Created by Randy Saeks on 2/9/17.
//  Copyright © 2017 Randy Saeks. All rights reserved.
//

import UIKit

//Base URL Paths

let API_BASE = "/JSSResource/"
let MOBILE_DEV_PATH = "mobiledevices/"
let MOBILE_DEV_CMD = "mobiledevicecommands/command/"
let USER_PATH = "users/name/"

// Dialog Message Placeholders
let userNameNotFound = " does not appear to have an assigned device to them in the JSS."
let deviceSNNotFound = " does not appear to be enrolled in the JSS."
let inventoryNumNotFound = " does not match a device asset tag in the JSS."

// Constructed URL Paths
let devAPIPath = "\(API_BASE)mobiledevicegroups/id/"
let devAPIMatchPath = "\(API_BASE)\(MOBILE_DEV_PATH)match/"
let matchPath = "\(API_BASE)\(MOBILE_DEV_PATH)match/"
let devAPIMatchPathID = "\(API_BASE)\(MOBILE_DEV_PATH)id/"
let devAPISNPath = "\(API_BASE)\(MOBILE_DEV_PATH)serialnumber/"
let devInvPath = "\(API_BASE)\(MOBILE_DEV_PATH)asset_tag/"
let devAPIUpdateInventoryPath = "\(API_BASE)\(MOBILE_DEV_CMD)UpdateInventory/id/"
let devAPIBlankPushPath = "\(API_BASE)\(MOBILE_DEV_CMD)BlankPush/id/"
let userPath = "\(API_BASE)\(USER_PATH)"
let devRestartPath = "\(API_BASE)\(MOBILE_DEV_CMD)RestartDevice/id/"
let devShutdownPath = "\(API_BASE)\(MOBILE_DEV_CMD)ShutdownDevice/id/"
let devLostModePath = "\(API_BASE)mobiledevicecommands/command"

// Header options
let headers = [
    "Accept":"application/json",
]
let xmlHeaders = [
    "Content-Type":"text/xml",
]
let xmlAppHeaders = [
    "Content-Type":"application/xml",
]


// XML strings
let devGroupAdditionLeft = "<mobile_device_group><mobile_device_additions><mobile_device><id>"
let devGroupAdditionRight = "</id></mobile_device></mobile_device_additions></mobile_device_group>"
let devGroupDeletionLeft = "<mobile_device_group><mobile_device_deletions><mobile_device><id>"
let devGroupDeletionRight = "</id></mobile_device></mobile_device_deletions></mobile_device_group>"
let enableLostMode = """
<?xml version="1.0" encoding="UTF-8"?><mobile_device_command><general><command>EnableLostMode</command><lost_mode_message>Lost Mode Test</lost_mode_message><lost_mode_phone>18478357834</lost_mode_phone><lost_mode_footnote>_</lost_mode_footnote><always_enforce_lost_mode>false</always_enforce_lost_mode><lost_mode_with_sound>true</lost_mode_with_sound></general><mobile_devices><mobile_device><id>718</id></mobile_device></mobile_devices></mobile_device_command>
"""

// Button colors
let successColor = UIColor(red: 0, green: 0.4863, blue: 0.1843, alpha: 1.0)
let warnColor = UIColor(red: 0.9882, green: 0.6588, blue: 0, alpha: 1.0)
let failColor = UIColor(red: 0.498, green: 0.0392, blue: 0.0, alpha: 1.0)
