//
//  Integration.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 15/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation

public class Integration : XcodeServerEntity {
    
    //usually available during the whole integration's lifecycle
    public let queuedDate: NSDate
    public let shouldClean: Bool
    public let currentStep: Step!
    public let number: Int
    
    //usually available only after the integration has finished
    public let successStreak: Int?
    public let startedDate: NSDate?
    public let endedTime: NSDate?
    public let duration: NSTimeInterval?
    public let result: Result?
    public let buildResultSummary: BuildResultSummary?
    public let testedDevices: [Device]?
    public let testHierarchy: TestHierarchy?
    public let assets: NSDictionary?  //TODO: add typed array with parsing
    public let blueprint: SourceControlBlueprint?
    
    //new keys
    public let expectedCompletionDate: NSDate?
    
    public enum Step : String {
        case Unknown = ""
        case Pending = "pending"
        case Preparing = "preparing"
        case Checkout = "checkout"
        case BeforeTriggers = "before-triggers"
        case Building = "building"
        case Testing = "testing"
        case Archiving = "archiving"
        case Processing = "processing"
        case AfterTriggers = "after-triggers"
        case Uploading = "uploading"
        case Completed = "completed"
    }
    
    public enum Result : String {
        case Unknown = "unknown"
        case Succeeded = "succeeded"
        case BuildErrors = "build-errors"
        case TestFailures = "test-failures"
        case Warnings = "warnings"
        case AnalyzerWarnings = "analyzer-warnings"
        case BuildFailed = "build-failed"
        case CheckoutError = "checkout-error"
        case InternalError = "internal-error"
        case InternalCheckoutError = "internal-checkout-error"
        case InternalBuildError = "internal-build-error"
        case InternalProcessingError = "internal-processing-error"
        case Canceled = "canceled"
        case TriggerError = "trigger-error"
    }
    
    public required init(json: NSDictionary) throws {
        
        self.queuedDate = try json.dateForKey("queuedDate")
        self.startedDate = json.optionalDateForKey("startedTime")
        self.endedTime = json.optionalDateForKey("endedTime")
        self.duration = json.optionalDoubleForKey("duration")
        self.shouldClean = try json.boolForKey("shouldClean")
        self.currentStep = Step(rawValue: try json.stringForKey("currentStep")) ?? .Unknown
        self.number = try json.intForKey("number")
        self.successStreak = try json.intForKey("success_streak")
        self.expectedCompletionDate = json.optionalDateForKey("expectedCompletionDate")
        
        if let raw = json.optionalStringForKey("result") {
            self.result = Result(rawValue: raw)
        } else {
            self.result = nil
        }
        
        if let raw = json.optionalDictionaryForKey("buildResultSummary") {
            self.buildResultSummary = try BuildResultSummary(json: raw)
        } else {
            self.buildResultSummary = nil
        }
        
        if let testedDevices = json.optionalArrayForKey("testedDevices") {
            self.testedDevices = try XcodeServerArray(testedDevices)
        } else {
            self.testedDevices = nil
        }
        
        if let testHierarchy = json.optionalDictionaryForKey("testHierarchy") where testHierarchy.count > 0 {
            self.testHierarchy = try TestHierarchy(json: testHierarchy)
        } else {
            self.testHierarchy = nil
        }

        self.assets = json.optionalDictionaryForKey("assets")
        
        if let blueprint = json.optionalDictionaryForKey("revisionBlueprint") {
            self.blueprint = try SourceControlBlueprint(json: blueprint)
        } else {
            self.blueprint = nil
        }
        
        try super.init(json: json)
    }
}

public class BuildResultSummary : XcodeServerEntity {
    
    public let analyzerWarningCount: Int
    public let testFailureCount: Int
    public let testsChange: Int
    public let errorCount: Int
    public let testsCount: Int
    public let testFailureChange: Int
    public let warningChange: Int
    public let regressedPerfTestCount: Int
    public let warningCount: Int
    public let errorChange: Int
    public let improvedPerfTestCount: Int
    public let analyzerWarningChange: Int
    public let codeCoveragePercentage: Int
    public let codeCoveragePercentageDelta: Int
    
    public required init(json: NSDictionary) throws {
        
        self.analyzerWarningCount = try json.intForKey("analyzerWarningCount")
        self.testFailureCount = try json.intForKey("testFailureCount")
        self.testsChange = try json.intForKey("testsChange")
        self.errorCount = try json.intForKey("errorCount")
        self.testsCount = try json.intForKey("testsCount")
        self.testFailureChange = try json.intForKey("testFailureChange")
        self.warningChange = try json.intForKey("warningChange")
        self.regressedPerfTestCount = try json.intForKey("regressedPerfTestCount")
        self.warningCount = try json.intForKey("warningCount")
        self.errorChange = try json.intForKey("errorChange")
        self.improvedPerfTestCount = try json.intForKey("improvedPerfTestCount")
        self.analyzerWarningChange = try json.intForKey("analyzerWarningChange")
        self.codeCoveragePercentage = json.optionalIntForKey("codeCoveragePercentage") ?? 0
        self.codeCoveragePercentageDelta = json.optionalIntForKey("codeCoveragePercentageDelta") ?? 0
        
        try super.init(json: json)
    }
    
}

extension Integration : Hashable {
    
    public var hashValue: Int {
        get {
            return self.number
        }
    }
}

public func ==(lhs: Integration, rhs: Integration) -> Bool {
    return lhs.number == rhs.number
}


