//
//  DeviceSpecification.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 24/06/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class DevicePlatform : XcodeServerEntity {
    
    public let displayName: String
    public let version: String
    
    public enum PlatformType: String {
        case Unknown = "unknown"
        case iOS = "com.apple.platform.iphoneos"
        case iOS_Simulator = "com.apple.platform.iphonesimulator"
        case OSX = "com.apple.platform.macosx"
        case watchOS = "com.apple.platform.watchos"
        case watchOS_Simulator = "com.apple.platform.watchsimulator"
        case tvOS = "com.apple.platform.appletvos"
        case tvOS_Simulator = "com.apple.platform.appletvsimulator"
    }
    
    public enum SimulatorType: String {
        case iPhone = "com.apple.platform.iphonesimulator"
        case Watch = "com.apple.platform.watchsimulator"
        case TV = "com.apple.platform.appletvsimulator"
    }
    
    public let type: PlatformType
    public let simulatorType: SimulatorType?
    
    public required init(json: NSDictionary) {
        
        self.displayName = json.stringForKey("displayName")
        self.version = json.stringForKey("version")
        self.type = PlatformType(rawValue: json.optionalStringForKey("identifier") ?? "") ?? .Unknown
        self.simulatorType = SimulatorType(rawValue: json.optionalStringForKey("simulatorIdentifier") ?? "")
        
        super.init(json: json)
    }
    
    //for just informing the intention - iOS or WatchOS or OS X - and we'll fetch the real ones and replace this placeholder with a fetched one.
    public init(type: PlatformType) {
        self.type = type
        self.displayName = ""
        self.version = ""
        self.simulatorType = nil
        
        super.init()
    }
    
    public class func OSX() -> DevicePlatform {
        return DevicePlatform(type: DevicePlatform.PlatformType.OSX)
    }
    
    public class func iOS() -> DevicePlatform {
        return DevicePlatform(type: DevicePlatform.PlatformType.iOS)
    }
    
    public class func watchOS() -> DevicePlatform {
        return DevicePlatform(type: DevicePlatform.PlatformType.watchOS)
    }
    
    public class func tvOS() -> DevicePlatform {
        return DevicePlatform(type: DevicePlatform.PlatformType.tvOS)
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
    
    public var platform: DevicePlatform
    
    public enum FilterType: Int {
        case AllAvailableDevicesAndSimulators = 0
        case AllDevices = 1
        case AllSimulators = 2
        case SelectedDevicesAndSimulators = 3
        
        public func toString() -> String {
            switch self {
            case .AllAvailableDevicesAndSimulators:
                return "All Available Devices and Simulators"
            case .AllDevices:
                return "All Devices"
            case .AllSimulators:
                return "All Simulators"
            case .SelectedDevicesAndSimulators:
                return "Selected Devices and Simulators"
            }
        }
        
        public static func availableFiltersForPlatform(platformType: DevicePlatform.PlatformType) -> [FilterType] {
            
            switch platformType {
            case .iOS:
                return [
                    .AllAvailableDevicesAndSimulators,
                    .AllDevices,
                    .AllSimulators,
                    .SelectedDevicesAndSimulators
                ]
            case .OSX, .watchOS:
                return [
                    .AllAvailableDevicesAndSimulators
                ]
            default:
                return []
            }
        }
    }
    
    public let filterType: FilterType
    
    public enum ArchitectureType: Int {
        case Unknown = -1
        case iOS_Like = 0 //also watchOS and tvOS
        case OSX_Like = 1
        
        public static func architectureFromPlatformType(platformType: DevicePlatform.PlatformType) -> ArchitectureType {
            
            switch platformType {
            case .iOS, .iOS_Simulator, .watchOS, .watchOS_Simulator, .tvOS, .tvOS_Simulator, .Unknown:
                return .iOS_Like
            case .OSX:
                return .OSX_Like
            }
        }
    }
    
    public let architectureType: ArchitectureType //TODO: ditto, find out more.
    
    public required init(json: NSDictionary) {
        
        self.platform = DevicePlatform(json: json.dictionaryForKey("platform"))
        self.filterType = FilterType(rawValue: json.intForKey("filterType")) ?? .AllAvailableDevicesAndSimulators
        self.architectureType = ArchitectureType(rawValue: json.optionalIntForKey("architectureType") ?? -1) ?? .Unknown
        
        super.init(json: json)
    }
    
    public init(platform: DevicePlatform, filterType: FilterType, architectureType: ArchitectureType) {
        self.platform = platform
        self.filterType = filterType
        self.architectureType = architectureType
        
        super.init()
    }
    
    public override func dictionarify() -> NSDictionary {
        
        return [
            "filterType": self.filterType.rawValue,
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
    
    // MARK: Convenience methods
    
    public class func OSX() -> DeviceSpecification {
        let platform = DevicePlatform.OSX()
        let filter = DeviceFilter(platform: platform, filterType: .AllAvailableDevicesAndSimulators, architectureType: .OSX_Like)
        let spec = DeviceSpecification(filters: [filter], deviceIdentifiers: [])
        return spec
    }
    
    public class func iOS(filterType: DeviceFilter.FilterType, deviceIdentifiers: [String]) -> DeviceSpecification {
        let platform = DevicePlatform.iOS()
        let filter = DeviceFilter(platform: platform, filterType: filterType, architectureType: .iOS_Like)
        let spec = DeviceSpecification(filters: [filter], deviceIdentifiers: deviceIdentifiers)
        return spec
    }
    
    public class func watchOS() -> DeviceSpecification {
        let platform = DevicePlatform.watchOS()
        let filter = DeviceFilter(platform: platform, filterType: .AllAvailableDevicesAndSimulators, architectureType: .iOS_Like)
        let spec = DeviceSpecification(filters: [filter], deviceIdentifiers: [])
        return spec
    }
    
    public class func tvOS() -> DeviceSpecification {
        let platform = DevicePlatform.tvOS()
        let filter = DeviceFilter(platform: platform, filterType: .AllAvailableDevicesAndSimulators, architectureType: .iOS_Like)
        let spec = DeviceSpecification(filters: [filter], deviceIdentifiers: [])
        return spec
    }
}

