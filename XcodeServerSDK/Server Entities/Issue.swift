//
//  Issue.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 04.08.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class Issue: XcodeServerEntity {
    
    public enum Type: String {
        case BuildServiceError = "buildServiceError"
        // Looks like build service warnings are treated as warnings in case
        // of type. In case of Issue Type they're Build Service Error
        // case BuildServiceWarining
        case TriggerError = "triggerError"
        case Error = "error"
        case Warning = "warning"
        case TestFailure = "testFailure"
        case AnalyzerWarning = "analyzerWarning"
    }
    
    public enum IssueStatus: Int {
        case Unresolved = 0
        case Fresh
        case Resolved
        case Silenced
    }
    
    public let payload: NSDictionary
    
    public let messge: String?
    public let type: Type
    public let issueType: String
    public let commits: [Commit]
    public let integrationID: String
    public let age: Int
    public let status: IssueStatus
    
    // MARK: Initialization
    public required init(json: NSDictionary) {
        // Initialization of each object
        super.init(json: json)
    }
    
}