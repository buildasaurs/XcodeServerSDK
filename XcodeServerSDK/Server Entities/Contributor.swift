//
//  Contributor.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 21/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

// MARK: Constants
let kContributorName = "XCSContributorName"
let kContributorDisplayName = "XCSContributorDisplayName"
let kContributorEmails = "XCSContributorEmails"

public class Contributor: XcodeServerEntity {
    
    public let name: String
    public let displayName: String
    public let emails: [String]
    
    public required init(json: NSDictionary) throws {
        self.name = try json.stringForKey(kContributorName)
        self.displayName = try json.stringForKey(kContributorDisplayName)
        self.emails = try json.arrayForKey(kContributorEmails)
        
        try super.init(json: json)
    }
    
    public override func dictionarify() -> NSDictionary {
        return [
            kContributorName: self.name,
            kContributorDisplayName: self.displayName,
            kContributorEmails: self.emails
        ]
    }
    
    public func description() -> String {
        return "\(displayName) [\(emails[0])]"
    }
    
}