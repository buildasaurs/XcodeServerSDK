//
//  XcodeServerEntityTests.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 20/06/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
import XcodeServerSDK

class XcodeServerEntityTests: XCTestCase {
    
    // MARK: No arguments init
    func testInit() {
        let defaultEntity = XcodeServerEntity()
        
        XCTAssertNil(defaultEntity.id, "ID should be nil")
        XCTAssertNil(defaultEntity.rev, "Rev should be nil")
        XCTAssertNil(defaultEntity.tinyID, "Tiny ID should be nil")
    }
    
    func testDictionarify() {
        // let defaultEntity = XcodeServerEntity()
        
        // Unable to test assertions in Swift...
        // XCTAssertNotNil(defaultEntity.dictionarify(), "Should return empty NSDictionary")
    }
    
}
