//
//  EmailConfiguration.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 13.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class EmailConfiguration : XcodeServerEntity {
    
    public let additionalRecipients: [String]
    public let emailCommitters: Bool
    public let includeCommitMessages: Bool
    public let includeIssueDetails: Bool
    
    public init(additionalRecipients: [String], emailCommitters: Bool, includeCommitMessages: Bool, includeIssueDetails: Bool) {
        
        self.additionalRecipients = additionalRecipients
        self.emailCommitters = emailCommitters
        self.includeCommitMessages = includeCommitMessages
        self.includeIssueDetails = includeIssueDetails
        
        super.init()
    }
    
    public override func dictionarify() -> NSDictionary {
        
        let dict = NSMutableDictionary()
        
        dict["emailCommitters"] = self.emailCommitters
        dict["includeCommitMessages"] = self.includeCommitMessages
        dict["includeIssueDetails"] = self.includeIssueDetails
        dict["additionalRecipients"] = self.additionalRecipients
        
        return dict
    }
    
    public required init(json: NSDictionary) throws {
        
        self.emailCommitters = try json.boolForKey("emailCommitters")
        self.includeCommitMessages = try json.boolForKey("includeCommitMessages")
        self.includeIssueDetails = try json.boolForKey("includeIssueDetails")
        self.additionalRecipients = try json.arrayForKey("additionalRecipients")
        
        try super.init(json: json)
    }
}