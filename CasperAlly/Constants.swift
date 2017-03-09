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
let devAPISNPath = "\(API_BASE)\(MOBILE_DEV_PATH)serialnumber/"
let devAPIUpdateInventoryPath = "\(API_BASE)\(MOBILE_DEV_CMD)UpdateInventory/id/"
let devAPIBlankPushPath = "\(API_BASE)\(MOBILE_DEV_CMD)BlankPush/id/"
let userPath = "\(API_BASE)\(USER_PATH)"
