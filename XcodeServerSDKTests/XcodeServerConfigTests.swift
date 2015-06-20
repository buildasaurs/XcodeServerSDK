//
//  XcodeServerConfigTests.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 20/06/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
import XcodeServerSDK

class XcodeServerConfigTests: XCTestCase {

    // MARK: Initialization testing
    func testManualInit() {
        let config = XcodeServerConfig(host: "127.0.0.1", user: "ICanCreateBots", password: "superSecr3t")
        
        XCTAssertEqual(config.host, "https://127.0.0.1", "Should create proper host address")
        XCTAssertEqual(config.user!, "ICanCreateBots")
        XCTAssertEqual(config.password!, "superSecr3t")
    }
    
    func testDictionaryInit() {
        let json = [
            "host": "https://127.0.0.1",
            "user": "ICanCreateBots",
            "password": "superSecr3t"
        ]
        
        let config = XcodeServerConfig(json: json)
        
        XCTAssertEqual(config!.host, "https://127.0.0.1", "Should create proper host address")
        XCTAssertEqual(config!.user!, "ICanCreateBots")
        XCTAssertEqual(config!.password!, "superSecr3t")
    }
    
    func testNilDictionaryInit() {
        let json = [
            "user": "ICanCreateBots",
            "password": "superSecr3t"
        ]
        
        let config = XcodeServerConfig(json: json)
        
        XCTAssertNil(config)
    }
    
    // MARK: Returning JSON
    func testJsonify() {
        let config = XcodeServerConfig(host: "127.0.0.1", user: "ICanCreateBots", password: "superSecr3t")
        let expected = [
            "host": "https://127.0.0.1",
            "user": "ICanCreateBots",
            "password": "superSecr3t"
        ]
        
        XCTAssertEqual(config.jsonify(), expected)
    }

}
