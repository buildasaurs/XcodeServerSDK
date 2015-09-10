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
    
    public required init(json: NSDictionary) {
        self.name = json.stringForKey(kContributorName)
        self.displayName = json.stringForKey(kContributorDisplayName)
        self.emails = json.arrayForKey(kContributorEmails)
        
        super.init(json: json)
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