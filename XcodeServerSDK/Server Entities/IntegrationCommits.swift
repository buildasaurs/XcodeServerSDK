//
//  IntegrationCommits.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 23/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

public class IntegrationCommits: XcodeServerEntity {
    
    public let integration: String
    public let botTinyID: String
    public let botID: String
    public let commits: [String: [Commit]]
    public let endedTimeDate: NSDate
    
    public required init(json: NSDictionary) {
        self.integration = json.stringForKey("integration")
        self.botTinyID = json.stringForKey("botTinyID")
        self.botID = json.stringForKey("botID")
        self.commits = IntegrationCommits.populateCommits(json.dictionaryForKey("commits"))
        self.endedTimeDate = NSDate()
        
        super.init(json: json)
    }
    
    class func populateCommits(json: NSDictionary) -> [String: [Commit]] {
        var resultsDictionary: [String: [Commit]] = Dictionary()
        
        for (key, value) in json {
            guard let blueprintID = key as? String, let commitsArray = value as? [NSDictionary] else {
                Log.error("Couldn't parse key \(key) and value \(value)")
                continue
            }
            
            resultsDictionary[blueprintID] = commitsArray.map { Commit(json: $0) }
        }
        
        return resultsDictionary
    }
    
}