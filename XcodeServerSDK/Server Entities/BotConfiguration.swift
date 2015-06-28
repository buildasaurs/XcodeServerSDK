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
        case iOSAndWatch = 0
        case Mac = 7
    }
    
    public let builtFromClean: CleaningPolicy!
    public let analyze: Bool
    public let test: Bool
    public let archive: Bool
    public let schemeName: String
    public let schedule: BotSchedule
    public let triggers: [Trigger]
    public var testingDestinationType: TestingDestinationIdentifier {
        get {
            if let firstFilter = self.deviceSpecification.filters.first {
                if case .OSX = firstFilter.platform.type {
                    return .Mac
                }
            }
            return .iOSAndWatch
        }
    }
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
        self.sourceControlBlueprint = SourceControlBlueprint(json: json.dictionaryForKey("sourceControlBlueprint"))
        
        //old bots (xcode 6) only have testingDeviceIds, try to parse those into the new format of DeviceSpecification (xcode 7)
        if let deviceSpecJSON = json.optionalDictionaryForKey("deviceSpecification") {
            self.deviceSpecification = DeviceSpecification(json: deviceSpecJSON)
        } else {
            if let testingDeviceIds = json.optionalArrayForKey("testingDeviceIDs") as? [String] {
                self.deviceSpecification = DeviceSpecification(testingDeviceIDs: testingDeviceIds)
            } else {
                self.deviceSpecification = DeviceSpecification(testingDeviceIDs: [])
            }
        }
        
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
        dictionary["testingDestinationType"] = self.testingDestinationType.rawValue //TODO: figure out if we still need this in Xcode 7
        
        let botScheduleDict = self.schedule.dictionarify() //needs to be merged into the main bot config dict
        dictionary.addEntriesFromDictionary(botScheduleDict as [NSObject : AnyObject])
        
        return dictionary
    }
}