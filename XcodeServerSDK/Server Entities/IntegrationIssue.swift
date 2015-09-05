//
//  Issue.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 04.08.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class IntegrationIssue: XcodeServerEntity {
    
    public enum IssueType: String {
        case BuildServiceError = "buildServiceError"
        case BuildServiceWarning = "buildServiceWarning"
        case TriggerError = "triggerError"
        case Error = "error"
        case Warning = "warning"
        case TestFailure = "testFailure"
        case AnalyzerWarning = "analyzerWarning"
    }
    
    public enum IssueStatus: Int {
        case Fresh = 0
        case Unresolved
        case Resolved
        case Silenced
    }
    
    /// Payload is holding whole Dictionary of the Issue
    public let payload: NSDictionary
    
    public let message: String?
    public let type: IssueType
    public let issueType: String
    public let commits: [Commit]
    public let integrationID: String
    public let age: Int
    public let status: IssueStatus
    
    // MARK: Initialization
    public required init(json: NSDictionary) {
        self.payload = json.copy() as? NSDictionary ?? NSDictionary()
        
        self.message = json.optionalStringForKey("message")
        self.type = IssueType(rawValue: json.stringForKey("type"))!
        self.issueType = json.stringForKey("issueType")
        self.commits = json.arrayForKey("commits").map { Commit(json: $0) }
        self.integrationID = json.stringForKey("integrationID")
        self.age = json.intForKey("age")
        self.status = IssueStatus(rawValue: json.intForKey("status"))!
        
        super.init(json: json)
    }
    
}