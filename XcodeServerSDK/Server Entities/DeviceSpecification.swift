//
//  DeviceSpecification.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 24/06/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class DeviceSpecification : XcodeServerEntity {
    
    public class Filter : XcodeServerEntity {
        
        public class Platform : XcodeServerEntity {
            
            let displayName: String
            let version: String
            
            public enum PlatformType: String {
                case Unknown = "unknown"
                case iOS = "com.apple.platform.iphoneos"
                case OSX = "com.apple.platform.macosx"
                case watchOS = "com.apple.platform.watchos"
            }
            
            public enum SimulatorType: String {
                case iPhone = "com.apple.platform.iphonesimulator"
                case Watch = "com.apple.platform.watchsimulator"
            }
            
            let type: PlatformType
            let simulatorType: SimulatorType?
            
            public required init(json: NSDictionary) {
                
                self.displayName = json.stringForKey("displayName")
                self.version = json.stringForKey("version")
                self.type = PlatformType(rawValue: json.optionalStringForKey("identifier") ?? "") ?? .Unknown
                self.simulatorType = SimulatorType(rawValue: json.optionalStringForKey("simulatorIdentifier") ?? "")
                
                super.init(json: json)
            }
            
            //TODO: dictionarify and an initializer to create from data for creating bots
        }
        
        let platform: Platform
        let filterType: Int //TODO: find out what the values mean by trial and error
        
        public enum ArchitectureType: Int {
            case Unknown = -1
            case iOS_Like = 0
            case OSX_Like = 1
        }
        
        let architectureType: ArchitectureType //TODO: ditto, find out more.
        
        public required init(json: NSDictionary) {
            
            self.platform = Platform(json: json.dictionaryForKey("platform"))
            self.filterType = json.intForKey("filterType")
            self.architectureType = ArchitectureType(rawValue: json.optionalIntForKey("architectureType") ?? -1) ?? .Unknown
            
            super.init(json: json)
        }
        
        //TODO: dictionarify and an initializer to create from data for creating bots
    }
    
    public let deviceIdentifiers: [String]
    public let filters: [Filter]
    
    public required init(json: NSDictionary) {
        
        self.deviceIdentifiers = json.arrayForKey("deviceIdentifiers")
        self.filters = XcodeServerArray(json.arrayForKey("filters"))
        
        super.init(json: json)
    }
    
    //
    /**
    Initializes a new DeviceSpecification object with only a list of tested device ids.
    This is a convenience initializer for compatibility with old Xcode 6 bots that are still hanging around on old servers.
    */
    public init(testingDeviceIDs: [String]) {
        
        self.deviceIdentifiers = testingDeviceIDs
        self.filters = []
        
        super.init()
    }
    
    public override func dictionarify() -> NSDictionary {
        
        return [
            "deviceIdentifiers": self.deviceIdentifiers,
            "filters": self.filters
        ]
    }
    
}

