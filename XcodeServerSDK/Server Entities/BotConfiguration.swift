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
    Legacy property of what devices should be tested on. Now moved to `DeviceSpecification`, but
    sending 0 or 7 still required. Sigh.
    */
    public enum TestingDestinationIdentifier : Int {
        case iOSAndWatch = 0
        case Mac = 7
    }
    
    /**
    Enum which describes whether code coverage data should be collected during tests.
    
    - Disabled:             Turned off
    - Enabled:              Turned on, regardless of the preference in Scheme
    - UseSchemeSettings:    Respects the preference in Scheme
    */
    public enum CodeCoveragePreference: Int {
        case Disabled = 0
        case Enabled = 1
        case UseSchemeSetting = 2
    }
    
    /**
    Enum describing build config preference. Xcode 7 API allows for overriding a config setup in the scheme for a specific one. UseSchemeSetting is the default.
    */
    public enum BuildConfiguration {
        case OverrideWithSpecific(String)
        case UseSchemeSetting
    }
    
    public let builtFromClean: CleaningPolicy
    public let codeCoveragePreference: CodeCoveragePreference
    public let buildConfiguration: BuildConfiguration
    public let analyze: Bool
    public let test: Bool
    public let archive: Bool
    public let exportsProductFromArchive: Bool
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
        
        self.builtFromClean = CleaningPolicy(rawValue: json.intForKey("builtFromClean")) ?? .Never
        self.codeCoveragePreference = CodeCoveragePreference(rawValue: json.optionalIntForKey("codeCoveragePreference") ?? 0) ?? .UseSchemeSetting
        
        if let buildConfigOverride = json.optionalStringForKey("buildConfiguration") {
            self.buildConfiguration = BuildConfiguration.OverrideWithSpecific(buildConfigOverride)
        } else {
            self.buildConfiguration = .UseSchemeSetting
        }
        self.analyze = json.boolForKey("performsAnalyzeAction")
        self.archive = json.boolForKey("performsArchiveAction")
        self.exportsProductFromArchive = json.optionalBoolForKey("exportsProductFromArchive") ?? false
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
        codeCoveragePreference: CodeCoveragePreference = .UseSchemeSetting,
        buildConfiguration: BuildConfiguration = .UseSchemeSetting,
        analyze: Bool,
        test: Bool,
        archive: Bool,
        exportsProductFromArchive: Bool = true,
        schemeName: String,
        schedule: BotSchedule,
        triggers: [Trigger],
        deviceSpecification: DeviceSpecification,
        sourceControlBlueprint: SourceControlBlueprint) {
            
            self.builtFromClean = builtFromClean
            self.codeCoveragePreference = codeCoveragePreference
            self.buildConfiguration = buildConfiguration
            self.analyze = analyze
            self.test = test
            self.archive = archive
            self.exportsProductFromArchive = exportsProductFromArchive
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
        dictionary["codeCoveragePreference"] = self.codeCoveragePreference.rawValue
        dictionary["performsTestAction"] = self.test
        dictionary["triggers"] = self.triggers.map { $0.dictionarify() }
        dictionary["performsAnalyzeAction"] = self.analyze
        dictionary["schemeName"] = self.schemeName
        dictionary["deviceSpecification"] = self.deviceSpecification.dictionarify()
        dictionary["performsArchiveAction"] = self.archive
        dictionary["exportsProductFromArchive"] = self.exportsProductFromArchive
        dictionary["testingDestinationType"] = self.testingDestinationType.rawValue //TODO: figure out if we still need this in Xcode 7
        
        if case .OverrideWithSpecific(let buildConfig) = self.buildConfiguration {
            dictionary["buildConfiguration"] = buildConfig
        }
        
        let botScheduleDict = self.schedule.dictionarify() //needs to be merged into the main bot config dict
        dictionary.addEntriesFromDictionary(botScheduleDict as [NSObject : AnyObject])
        
        return dictionary
    }
}