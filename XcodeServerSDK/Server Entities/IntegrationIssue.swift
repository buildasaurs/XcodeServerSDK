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
    public required init(json: NSDictionary) throws {
        self.payload = json.copy() as? NSDictionary ?? NSDictionary()
        
        self.message = json.optionalStringForKey("message")
        self.type = try IssueType(rawValue: json.stringForKey("type"))!
        self.issueType = try json.stringForKey("issueType")
        self.commits = try json.arrayForKey("commits").map { try Commit(json: $0) }
        self.integrationID = try json.stringForKey("integrationID")
        self.age = try json.intForKey("age")
        self.status = IssueStatus(rawValue: try json.intForKey("status"))!
        
        try super.init(json: json)
    }
    
}