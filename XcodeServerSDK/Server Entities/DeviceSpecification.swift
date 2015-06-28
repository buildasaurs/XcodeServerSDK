//
//  DeviceSpecification.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 24/06/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class DevicePlatform : XcodeServerEntity {
    
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
    
    public class func OSX() -> DevicePlatform {
        
        let dict = [
            "buildNumber": "15A204f",
            "displayName": "OS X",
            "identifier": "com.apple.platform.macosx",
            "version": "1.1",
            "doc_type": "platform",
        ]
        return DevicePlatform(json: dict)
    }
    
    public class func iOS() -> DevicePlatform {
        
        let dict = [
            "buildNumber": "13A4280e",
            "simulatorIdentifier": "com.apple.platform.iphonesimulator",
            "displayName": "iOS",
            "identifier": "com.apple.platform.iphoneos",
            "version": "9.0",
            "doc_type": "platform",
        ]
        return DevicePlatform(json: dict)
    }
    
    public class func watchOS() -> DevicePlatform {
        
        let dict = [
            "buildNumber": "13S5255c",
            "simulatorIdentifier": "com.apple.platform.watchsimulator",
            "displayName": "watchOS",
            "identifier": "com.apple.platform.watchos",
            "version": "2.0",
            "doc_type": "platform",
        ]
        return DevicePlatform(json: dict)
    }
    
    public override func dictionarify() -> NSDictionary {
        
        //in this case we want everything the way we parsed it.
        if let original = self.originalJSON {
            return original
        }
        
        let dictionary = NSMutableDictionary()
        
        dictionary["displayName"] = self.displayName
        dictionary["version"] = self.version
        dictionary["identifier"] = self.type.rawValue
        dictionary.optionallyAddValueForKey(self.simulatorType?.rawValue, key: "simulatorIdentifier")
        
        return dictionary
    }
}

public class DeviceFilter : XcodeServerEntity {
    
    let platform: DevicePlatform
    let filterType: Int //TODO: find out what the values mean by trial and error
    
    public enum ArchitectureType: Int {
        case Unknown = -1
        case iOS_Like = 0
        case OSX_Like = 1
    }
    
    let architectureType: ArchitectureType //TODO: ditto, find out more.
    
    public required init(json: NSDictionary) {
        
        self.platform = DevicePlatform(json: json.dictionaryForKey("platform"))
        self.filterType = json.intForKey("filterType")
        self.architectureType = ArchitectureType(rawValue: json.optionalIntForKey("architectureType") ?? -1) ?? .Unknown
        
        super.init(json: json)
    }
    
    public init(platform: DevicePlatform, filterType: Int, architectureType: ArchitectureType) {
        self.platform = platform
        self.filterType = filterType
        self.architectureType = architectureType
        
        super.init()
    }
    
    public override func dictionarify() -> NSDictionary {
        
        return [
            "filterType": self.filterType,
            "architectureType": self.architectureType.rawValue,
            "platform": self.platform.dictionarify()
        ]
    }
}

public class DeviceSpecification : XcodeServerEntity {
    
    public let deviceIdentifiers: [String]
    public let filters: [DeviceFilter]
    
    public required init(json: NSDictionary) {
        
        self.deviceIdentifiers = json.arrayForKey("deviceIdentifiers")
        self.filters = XcodeServerArray(json.arrayForKey("filters"))
        
        super.init(json: json)
    }
    
    public init(filters: [DeviceFilter], deviceIdentifiers: [String]) {
        self.deviceIdentifiers = deviceIdentifiers
        self.filters = filters
        
        super.init()
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
            "filters": self.filters.map({ $0.dictionarify() })
        ]
    }
    
}

