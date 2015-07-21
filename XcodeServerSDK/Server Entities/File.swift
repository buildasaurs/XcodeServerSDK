//
//  File.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 21/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public enum FileStatus: Int {
    case Added = 1
    case Deleted = 2
    case Modified = 4
    case Moved = 8192
    case Other
}

public class File: XcodeServerEntity {
    
    public let status: FileStatus
    public let filePath: String
    
//    public required init(json: NSDictionary) {
//        
//        
//        super.init(json: json)
//    }
    
}