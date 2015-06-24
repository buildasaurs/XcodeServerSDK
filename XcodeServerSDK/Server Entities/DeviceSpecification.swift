//
//  DeviceSpecification.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 24/06/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class DeviceSpecification : XcodeServerEntity {
    
    public let deviceIdentifiers: [String]
    public let filters: [NSDictionary] //TODO: parse more and get more understanding of what they're for
    
    public required init(json: NSDictionary) {
        
        self.deviceIdentifiers = json.arrayForKey("deviceIdentifiers")
        self.filters = json.arrayForKey("filters")
        
        super.init(json: json)
    }
    
    public override func dictionarify() -> NSDictionary {
        
        return [
            "deviceIdentifiers": self.deviceIdentifiers,
            "filters": self.filters
        ]
    }
    
}

