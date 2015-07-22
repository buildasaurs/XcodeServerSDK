//
//  File.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 21/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class File: XcodeServerEntity {
    
    public let status: FileStatus
    public let filePath: String
    
    public init(filePath: String, status: FileStatus) {
        self.filePath = filePath
        self.status = status
        
        super.init()
    }
    
    public required init(json: NSDictionary) {
        self.filePath = json.stringForKey("filePath")
        self.status = FileStatus(rawValue: json.intForKey("status")) ?? .Other
        
        super.init(json: json)
    }
    
    public override func dictionarify() -> NSDictionary {
        return [
            "status": self.status.rawValue,
            "filePath": self.filePath
        ]
    }
    
}

/**
*  Enum which describes file statuses.
*/
public enum FileStatus: Int {
    case Added = 1
    case Deleted = 2
    case Modified = 4
    case Moved = 8192
    case Other
}