//
//  Device.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 15/03/2015.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class Device : XcodeServerEntity {
    
    public let name: String
    public let simulator: Bool
    public let osVersion: String
    public let deviceType: String
    public let connected: Bool
    public let platform: DevicePlatform.PlatformType
    
    public required init(json: NSDictionary) {
        
        self.name = json.stringForKey("name")
        self.simulator = json.boolForKey("simulator")
        self.osVersion = json.stringForKey("osVersion")
        self.deviceType = json.stringForKey("deviceType")
        self.connected = json.boolForKey("connected")
        self.platform = DevicePlatform.PlatformType(rawValue: json.stringForKey("platformIdentifier")) ?? .Unknown
        
        super.init(json: json)
    }
    
    public override func dictionarify() -> NSDictionary {
        
        return [
            "device_id": self.id
        ]
    }
    
}
