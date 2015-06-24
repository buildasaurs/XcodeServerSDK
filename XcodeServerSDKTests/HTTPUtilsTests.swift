//
//  HTTPUtilsTests.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 24.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
import XcodeServerSDK

class HTTPUtilsTests: XCTestCase {

    // MARK: HTTP extension tests
    func testStringForQuery() {
        let query = [
            "Key1": "Value1",
            "Key2": "Value2",
            "Key3": "Value3"
        ]
        
        XCTAssertEqual(HTTP.stringForQuery(query), "?Key1=Value1&Key2=Value2&Key3=Value3")
    }
    
    func testOptionalStringForQuery() {
        XCTAssertEqual(HTTP.stringForQuery(nil), "")
    }

}
