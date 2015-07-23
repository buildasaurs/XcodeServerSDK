//
//  IntegrationCommits.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 23/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class IntegrationCommits: XcodeServerEntity {
    
    public let integration: String
    public let botTinyID: String
    public let botID: String
    public let commits: [Commit]
    public let endedTimeDate: NSDate
    
    public required init(json: NSDictionary) {
        self.integration = json.stringForKey("integration")
        self.botTinyID = json.stringForKey("botTinyID")
        self.botID = json.stringForKey("botID")
        self.commits = json.dictionaryForKey("commits").allValues.flatMap { Commit(json: $0 as! NSDictionary) }
        self.endedTimeDate = NSDate()
        
        super.init(json: json)
    }
    
}