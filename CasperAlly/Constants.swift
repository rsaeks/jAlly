//
//  Constants.swift
//  CasperAlly
//
//  Created by Randy Saeks on 2/9/17.
//  Copyright © 2017 Randy Saeks. All rights reserved.
//

import Foundation


//Base URL Paths

let API_BASE = "/JSSResource/"
let MOBILE_DEV_PATH = "mobiledevices/"
let MOBILE_DEV_CMD = "mobiledevicecommands/command/"
let USER_PATH = "users/name/"

//Constructed URL Paths
let devAPIPath = "\(API_BASE)mobiledevicegroups/id/"
let devAPIMatchPath = "\(API_BASE)\(MOBILE_DEV_PATH)match/"
let devAPIMatchPathID = "\(API_BASE)\(MOBILE_DEV_PATH)id/"
let devAPISNPath = "\(API_BASE)\(MOBILE_DEV_PATH)serialnumber/"
let devInvPath = "\(API_BASE)\(MOBILE_DEV_PATH)asset_tag/"
let devAPIUpdateInventoryPath = "\(API_BASE)\(MOBILE_DEV_CMD)UpdateInventory/id/"
let devAPIBlankPushPath = "\(API_BASE)\(MOBILE_DEV_CMD)BlankPush/id/"
let userPath = "\(API_BASE)\(USER_PATH)"

// Header options
let headers = [
    "Accept":"application/json",
]
let xmlHeaders = [
    "Content-Type":"text/xml",
]

// XML strings
let devGroupAdditionLeft = "<mobile_device_group><mobile_device_additions><mobile_device><id>"
let devGroupAdditionRight = "</id></mobile_device></mobile_device_additions></mobile_device_group>"
let devGroupDeletionLeft = "<mobile_device_group><mobile_device_deletions><mobile_device><id>"
let devGroupDeletionRight = "</id></mobile_device></mobile_device_deletions></mobile_device_group>"
