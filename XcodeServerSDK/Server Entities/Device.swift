//
//  Device.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 15/03/2015.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

public class Device : XcodeServerEntity {
    
    public let osVersion: String
    public let connected: Bool
    public let simulator: Bool
    public let modelCode: String? // Enum?
    public let deviceType: String? // Enum?
    public let modelName: String?
    public let deviceECID: String?
    public let modelUTI: String?
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
    
    public required init(json: NSDictionary) throws {
        
        self.connected = try json.boolForKey("connected")
        self.osVersion = try json.stringForKey("osVersion")
        self.simulator = try json.boolForKey("simulator")
        self.modelCode = json.optionalStringForKey("modelCode")
        self.deviceType = json.optionalStringForKey("deviceType")
        self.modelName = json.optionalStringForKey("modelName")
        self.deviceECID = json.optionalStringForKey("deviceECID")
        self.modelUTI = json.optionalStringForKey("modelUTI")
        if let proxyDevice = json.optionalDictionaryForKey("activeProxiedDevice") {
            self.activeProxiedDevice = try Device(json: proxyDevice)
        } else {
            self.activeProxiedDevice = nil
        }
        self.trusted = json.optionalBoolForKey("trusted") ?? false
        self.name = try json.stringForKey("name")
        self.supported = try json.boolForKey("supported")
        self.processor = json.optionalStringForKey("processor")
        self.identifier = try json.stringForKey("identifier")
        self.enabledForDevelopment = try json.boolForKey("enabledForDevelopment")
        self.serialNumber = json.optionalStringForKey("serialNumber")
        self.platform = DevicePlatform.PlatformType(rawValue: try json.stringForKey("platformIdentifier")) ?? .Unknown
        self.architecture = try json.stringForKey("architecture")
        
        //for some reason which is not yet clear to me (probably old/new XcS versions), sometimes
        //the key is "server" and sometimes "isServer". this just picks up the present one.
        self.isServer = json.optionalBoolForKey("server") ?? json.optionalBoolForKey("isServer") ?? false
        self.retina = try json.boolForKey("retina")
        
        try super.init(json: json)
    }
    
    public override func dictionarify() -> NSDictionary {
        
        return [
            "device_id": self.id
        ]
    }
    
}
