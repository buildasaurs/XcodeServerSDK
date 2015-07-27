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
    public let endedTimeDate: NSDate?
    
    public required init(json: NSDictionary) {
        self.integration = json.stringForKey("integration")
        self.botTinyID = json.stringForKey("botTinyID")
        self.botID = json.stringForKey("botID")
        self.commits = IntegrationCommits.populateCommits(json.dictionaryForKey("commits"))
        self.endedTimeDate = IntegrationCommits.parseDate(json.arrayForKey("endedTimeDate"))
        
        super.init(json: json)
    }
    
    /**
    Method for populating commits property with data from JSON dictionary.
    
    - parameter json: JSON dictionary with blueprints and commits for each one.
    
    - returns: Dictionary of parsed Commit objects.
    */
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
    
    /**
    Parser for data objects which comes in form of array.
    
    - parameter array: Array with date components.
    
    - returns: Optional parsed date to the format used by Xcode Server.
    */
    class func parseDate(array: NSArray) -> NSDate? {
        guard let dateArray = array as? [Int] else {
            Log.error("Couldn't parse XCS date array")
            return nil
        }
        
        do {
            let stringDate = try dateArray.dateString()
            
            guard let date = NSDate.dateFromXCSString(stringDate) else {
                Log.error("Formatter couldn't parse date")
                return nil
            }
            
            return date
        } catch DateParsingError.WrongNumberOfElements(let elements) {
            Log.error("Couldn't parse date as Array has \(elements) elements")
        } catch {
            Log.error("Something went wrong while parsing date")
        }
        
        return nil
    }
    
}