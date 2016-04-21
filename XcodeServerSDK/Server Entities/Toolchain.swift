//
//  Toolchain.swift
//  XcodeServerSDK
//
//  Created by Laurent Gaches on 21/04/16.
//  Copyright © 2016 Laurent Gaches. All rights reserved.
//

import Foundation

public class Toolchain: XcodeServerEntity {
    
    public let displayName: String
    public let path: String
    public let signatureVerified: Bool
 
    
    public required init(json: NSDictionary) {
        
        self.displayName = json.stringForKey("displayName")
        self.path = json.stringForKey("path")
        self.signatureVerified = json.boolForKey("signatureVerified")
        
        super.init(json: json)
    }
}