//
//  TestHierarchy.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 15/07/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class TestHierarchy : XcodeServerEntity {
    
    public required init(json: NSDictionary) {
        
        //TODO: come up with useful things to parse
        //TODO: add search capabilities, aggregate generation etc
        super.init(json: json)
    }
}
