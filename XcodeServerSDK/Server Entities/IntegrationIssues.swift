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
    
    public required init(json: NSDictionary) {
        self.buildServiceErrors = json.arrayForKey("buildServiceErrors").map { IntegrationIssue(json: $0) }
        self.buildServiceWarnings = json.arrayForKey("buildServiceWarnings").map { IntegrationIssue(json: $0) }
        self.triggerErrors = json.arrayForKey("triggerErrors").map { IntegrationIssue(json: $0) }
        
        // Nested issues
        self.errors = json.dictionaryForKey("errors").allValues.filter { $0.count != 0 }.flatMap { ($0 as! NSArray).map { IntegrationIssue(json: $0 as! NSDictionary) } }
        self.warnings = json.dictionaryForKey("warnings").allValues.filter { $0.count != 0 }.flatMap { ($0 as! NSArray).map { IntegrationIssue(json: $0 as! NSDictionary) } }
        self.testFailures = json.dictionaryForKey("testFailures").allValues.filter { $0.count != 0 }.flatMap { ($0 as! NSArray).map { IntegrationIssue(json: $0 as! NSDictionary) } }
        self.analyzerWarnings = json.dictionaryForKey("analyzerWarnings").allValues.filter { $0.count != 0 }.flatMap { ($0 as! NSArray).map { IntegrationIssue(json: $0 as! NSDictionary) } }
        
        super.init(json: json)
    }
    
}