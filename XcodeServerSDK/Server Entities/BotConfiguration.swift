//
//  BotConfiguration.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 14/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation

public class BotConfiguration : XcodeServerEntity {
    
    /**
    Enum with values describing when Bots history
    should be cleaned.
    
    - Never:       Never clean
    - Always:      Clean always project is opened
    - Once_a_Day:  Clean once a day on first build
    - Once_a_Week: Clean once a week on first build
    */
    public enum CleaningPolicy : Int {
        case Never = 0
        case Always
        case Once_a_Day
        case Once_a_Week
        
        /**
        Method for preinting in human readable Bots
        cleaning policy
        
        - returns: String with cleaning policy description
        */
        public func toString() -> String {
            switch self {
                case .Never:
                    return "Never"
                case .Always:
                    return "Always"
                case .Once_a_Day:
                    return "Once a day (first build)"
                case .Once_a_Week:
                    return "Once a week (first build)"
            }
        }
    }
    
    /**
    Enum which describes type of available devices.
    
    - Simulator: iOS simulator (can be any device running iOS)
    - Mac:       Mac with installed OS X
    - iPhone:    iOS device (includes iPhone, iPad and iPod Touch)
    */
    public enum DeviceType : String {
        case Simulator = "com.apple.iphone-simulator"
        case Mac = "com.apple.mac"
        case iPhone = "com.apple.iphone"
    }
    
    /**
    Enum which describes identifiers of devices on which test should be run.
    
    - iOS_AllDevicesAndSimulators:      iOS default - for build only
    - iOS_AllDevices:                   All iOS devices
    - iOS_AllSimulators:                All iOS simulators
    - iOS_SelectedDevicesAndSimulators: Manually selected devices/simulators
    - Mac:                              Mac default (probably, crashes when saving in Xcode) - for build only
    - AllCompatible:                    All Compatible (default) - for build only
    */
    public enum TestingDestinationIdentifier : Int {
        case iOS_AllDevicesAndSimulators = 0
        case iOS_AllDevices = 1
        case iOS_AllSimulators = 2
        case iOS_SelectedDevicesAndSimulators = 3
        case Mac = 7
        case AllCompatible = 8
        
        public func toString() -> String {
            switch self {
                case .iOS_AllDevicesAndSimulators:
                    return "iOS: All Devices and Simulators"
                case .iOS_AllDevices:
                    return "iOS: All Devices"
                case .iOS_AllSimulators:
                    return "iOS: All Simulators"
                case .iOS_SelectedDevicesAndSimulators:
                    return "iOS: Selected Devices and Simulators"
                case .Mac:
                    return "Mac"
                case .AllCompatible:
                    return "All Compatible (Mac + iOS)"
            }
        }
        
        public func allowedDeviceTypes() -> [DeviceType] {
            switch self {
                case .iOS_AllDevicesAndSimulators:
                    return [.iPhone, .Simulator]
                case .iOS_AllDevices:
                    return [.iPhone]
                case .iOS_AllSimulators:
                    return [.Simulator]
                case .iOS_SelectedDevicesAndSimulators:
                    return [.iPhone, .Simulator]
                case .Mac:
                    return [.Mac]
                case .AllCompatible:
                    return [.iPhone, .Simulator, .Mac]
            }
        }
    }
    
    public let builtFromClean: CleaningPolicy!
    public let analyze: Bool
    public let test: Bool
    public let archive: Bool
    public let schemeName: String
    public let schedule: BotSchedule
    public let triggers: [Trigger]
    public let testingDestinationType: TestingDestinationIdentifier?
    public let deviceSpecification: DeviceSpecification
    public let sourceControlBlueprint: SourceControlBlueprint
    
    public required init(json: NSDictionary) {
        
        self.builtFromClean = CleaningPolicy(rawValue: json.intForKey("builtFromClean"))
        self.analyze = json.boolForKey("performsAnalyzeAction")
        self.archive = json.boolForKey("performsArchiveAction")
        self.test = json.boolForKey("performsTestAction")
        self.schemeName = json.stringForKey("schemeName")
        self.schedule = BotSchedule(json: json)
        self.triggers = XcodeServerArray(json.arrayForKey("triggers"))
        self.testingDestinationType = TestingDestinationIdentifier(rawValue: json.intForKey("testingDestinationType"))
        self.sourceControlBlueprint = SourceControlBlueprint(json: json.dictionaryForKey("sourceControlBlueprint"))
        
        //old bots (xcode 6) only have testingDeviceIds, try to parse those into the new format of DeviceSpecification (xcode 7)
        let deviceSpec = DeviceSpecification(json: json.dictionaryForKey("deviceSpecification"))
        
        self.deviceSpecification = deviceSpe
        
        super.init(json: json)
    }
    
    public init(
        builtFromClean: CleaningPolicy,
        analyze: Bool,
        test: Bool,
        archive: Bool,
        schemeName: String,
        schedule: BotSchedule,
        triggers: [Trigger],
        deviceSpecification: DeviceSpecification,
        testingDestinationType: TestingDestinationIdentifier,
        sourceControlBlueprint: SourceControlBlueprint) {
            
            self.builtFromClean = builtFromClean
            self.analyze = analyze
            self.test = test
            self.archive = archive
            self.schemeName = schemeName
            self.schedule = schedule
            self.triggers = triggers
            self.deviceSpecification = deviceSpecification
            self.sourceControlBlueprint = sourceControlBlueprint
            self.testingDestinationType = testingDestinationType
            
            super.init()
    }
    
    public override func dictionarify() -> NSDictionary {
        
        let dictionary = NSMutableDictionary()
        
        //blueprint
        dictionary["sourceControlBlueprint"] = self.sourceControlBlueprint.dictionarify()
        
        //others
        dictionary["builtFromClean"] = self.builtFromClean.rawValue
        dictionary["performsTestAction"] = self.test
        dictionary["triggers"] = self.triggers.map { $0.dictionarify() }
        dictionary["performsAnalyzeAction"] = self.analyze
        dictionary["schemeName"] = self.schemeName
        dictionary["deviceSpecification"] = self.deviceSpecification.dictionarify()
        dictionary["performsArchiveAction"] = self.archive
        dictionary["testingDestinationType"] = self.testingDestinationType?.rawValue //TODO: figure out if we need this
        
        let botScheduleDict = self.schedule.dictionarify() //needs to be merged into the main bot config dict
        dictionary.addEntriesFromDictionary(botScheduleDict as [NSObject : AnyObject])
        
        return dictionary
    }
}