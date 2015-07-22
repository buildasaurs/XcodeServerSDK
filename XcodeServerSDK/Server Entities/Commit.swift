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
    public required init(json: NSDictionary) {
        self.hash = json.stringForKey("XCSCommitHash")
        self.filePaths = json.arrayForKey("XCSCommitCommitChangeFilePaths").map { File(json: $0) }
        self.message = json.optionalStringForKey("XCSCommitMessage")
        self.date = json.dateForKey("XCSCommitTimestamp")
        self.repositoryID = json.stringForKey("XCSBlueprintRepositoryID")
        self.contributor = Contributor(json: json.dictionaryForKey("XCSCommitContributor"))
        
        super.init(json: json)
    }
    
}