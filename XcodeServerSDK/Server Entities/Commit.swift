//
//  Commit.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 21/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class Commit: XcodeServerEntity {
    
    public let hash: String
    public let filePaths: [File]
    public let message: String?
    public let date: NSDate
    public let repositoryID: String
    public let contributor: Contributor
    
    // MARK: Initializers
    public required init(json: NSDictionary) throws {
        self.hash = try json.stringForKey("XCSCommitHash")
        self.filePaths = try json.arrayForKey("XCSCommitCommitChangeFilePaths").map { try File(json: $0) }
        self.message = json.optionalStringForKey("XCSCommitMessage")
        self.date = try json.dateForKey("XCSCommitTimestamp")
        self.repositoryID = try json.stringForKey("XCSBlueprintRepositoryID")
        self.contributor = try Contributor(json: try json.dictionaryForKey("XCSCommitContributor"))
        
        try super.init(json: json)
    }
    
}