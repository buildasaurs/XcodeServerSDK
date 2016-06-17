//
//  IntegrationIssues.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 12.08.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

public class IntegrationIssues: XcodeServerEntity {
    
    public let buildServiceErrors: [IntegrationIssue]
    public let buildServiceWarnings: [IntegrationIssue]
    public let triggerErrors: [IntegrationIssue]
    public let errors: [IntegrationIssue]
    public let warnings: [IntegrationIssue]
    public let testFailures: [IntegrationIssue]
    public let analyzerWarnings: [IntegrationIssue]
    
    // MARK: Initialization
    
    public required init(json: NSDictionary) throws {
        self.buildServiceErrors = try json.arrayForKey("buildServiceErrors").map { try IntegrationIssue(json: $0) }
        self.buildServiceWarnings = try json.arrayForKey("buildServiceWarnings").map { try IntegrationIssue(json: $0) }
        self.triggerErrors = try json.arrayForKey("triggerErrors").map { try IntegrationIssue(json: $0) }
        
        // Nested issues
        self.errors = try json
            .dictionaryForKey("errors")
            .allValues
            .filter { $0.count != 0 }
            .flatMap {
                try ($0 as! NSArray).map { try IntegrationIssue(json: $0 as! NSDictionary) }
        }
        self.warnings = try json
            .dictionaryForKey("warnings")
            .allValues
            .filter { $0.count != 0 }
            .flatMap {
                try ($0 as! NSArray).map { try IntegrationIssue(json: $0 as! NSDictionary) }
        }
        self.testFailures = try json
            .dictionaryForKey("testFailures")
            .allValues
            .filter { $0.count != 0 }
            .flatMap {
                try ($0 as! NSArray).map { try IntegrationIssue(json: $0 as! NSDictionary) }
        }
        self.analyzerWarnings = try json
            .dictionaryForKey("analyzerWarnings")
            .allValues
            .filter { $0.count != 0 }
            .flatMap {
                try ($0 as! NSArray).map { try IntegrationIssue(json: $0 as! NSDictionary) }
        }
        
        try super.init(json: json)
    }
    
}