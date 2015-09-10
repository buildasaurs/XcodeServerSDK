//
//  Device.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 15/03/2015.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class Device : XcodeServerEntity {
    
    public let osVersion: String
    public let connected: Bool
    public let simulator: Bool
    public let modelCode: String // Enum?
    public let deviceType: String // Enum?
    public let modelName: String
    public let deviceECID: String?
    public let modelUTI: String
    public let activeProxiedDevice: Device?
    public let trusted: Bool
    public let name: String
    public let supported: Bool
    public let processor: String?
    public let identifier: String
    public let enabledForDevelopment: Bool
    public let serialNumber: String?
    public let platform: DevicePlatform.PlatformType
    public let architecture: String // Enum?
    public let isServer: Bool
    public let retina: Bool
    
    public required init(json: NSDictionary) {
        
        self.osVersion = json.stringForKey("osVersion")
        self.connected = json.boolForKey("connected")
        self.simulator = json.boolForKey("simulator")
        self.modelCode = json.stringForKey("modelCode")
        self.deviceType = json.stringForKey("deviceType")
        self.modelName = json.stringForKey("modelName")
        self.deviceECID = json.optionalStringForKey("deviceECID")
        self.modelUTI = json.stringForKey("modelUTI")
        if let proxyDevice = json.optionalDictionaryForKey("activeProxiedDevice") {
            self.activeProxiedDevice = Device(json: proxyDevice)
        } else {
            self.activeProxiedDevice = nil
        }
        self.trusted = json.optionalBoolForKey("trusted") ?? false
        self.name = json.stringForKey("name")
        self.supported = json.boolForKey("supported")
        self.processor = json.optionalStringForKey("processor")
        self.identifier = json.stringForKey("identifier")
        self.enabledForDevelopment = json.boolForKey("enabledForDevelopment")
        self.serialNumber = json.optionalStringForKey("serialNumber")
        self.platform = DevicePlatform.PlatformType(rawValue: json.stringForKey("platformIdentifier")) ?? .Unknown
        self.architecture = json.stringForKey("architecture")
        
        //for some reason which is not yet clear to me (probably old/new XcS versions), sometimes
        //the key is "server" and sometimes "isServer". this just picks up the present one.
        self.isServer = json.optionalBoolForKey("server") ?? json.optionalBoolForKey("isServer") ?? false
        self.retina = json.boolForKey("retina")
        
        super.init(json: json)
    }
    
    public override func dictionarify() -> NSDictionary {
        
        return [
            "device_id": self.id
        ]
    }
    
}
