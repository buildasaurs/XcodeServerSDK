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
    
    public let buildServiceErrors: [Issue]
    public let buildServiceWarnings: [Issue]
    public let triggerErrors: [Issue]
    public let errors: [Issue]
    public let warnings: [Issue]
    public let testFailures: [Issue]
    public let analyzerWarnings: [Issue]
    
    // MARK: Initialization
    
    public required init(json: NSDictionary) {
        self.buildServiceErrors = json.arrayForKey("buildServiceErrors").map { Issue(json: $0) }
        self.buildServiceWarnings = json.arrayForKey("buildServiceWarnings").map { Issue(json: $0) }
        self.triggerErrors = json.arrayForKey("triggerErrors").map { Issue(json: $0) }
        
        // Nested issues
        self.errors = json.dictionaryForKey("errors").allValues.map { Issue(json: $0 as! NSDictionary) }
        self.warnings = json.dictionaryForKey("warnings").allValues.map { Issue(json: $0 as! NSDictionary) }
        self.testFailures = json.dictionaryForKey("testFailures").allValues.map { Issue(json: $0 as! NSDictionary) }
        self.analyzerWarnings = json.dictionaryForKey("analyzerWarnings").allValues.map { Issue(json: $0 as! NSDictionary) }
        
        super.init(json: json)
    }
    
}