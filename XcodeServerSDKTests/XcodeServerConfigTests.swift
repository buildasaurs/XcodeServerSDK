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
        do {
            let config = try XcodeServerConfig(host: "127.0.0.1", user: "ICanCreateBots", password: "superSecr3t")
            
            XCTAssertEqual(config.host, "https://127.0.0.1", "Should create proper host address")
            XCTAssertEqual(config.user!, "ICanCreateBots")
            XCTAssertEqual(config.password!, "superSecr3t")
        } catch {
            XCTFail("Failed to initialize the server configuration: \(error)")
        }
    }
    
    func testDictionaryInit() {
        let json = [
            "host": "https://127.0.0.1",
            "user": "ICanCreateBots",
            "password": "superSecr3t"
        ]
        
        do {
            let config = try XcodeServerConfig(json: json)
            
            XCTAssertEqual(config!.host, "https://127.0.0.1", "Should create proper host address")
            XCTAssertEqual(config!.user!, "ICanCreateBots")
            XCTAssertEqual(config!.password!, "superSecr3t")
        } catch {
            XCTFail("Failed to initialize the server configuration: \(error)")
        }
    }
    
    func testInvalidDictionaryInit() {
        let json = [
            "user": "ICanCreateBots",
            "password": "superSecr3t"
        ]
        
        XCTempAssertThrowsSpecificError(ConfigurationErrors.NoHostProvided) {
            try XcodeServerConfig(json: json)
        }
    }
    
    func testInvalidSchemeProvided() {
        XCTempAssertThrowsSpecificError(ConfigurationErrors.InvalidSchemeProvided("")) {
            try XcodeServerConfig(host: "http://127.0.0.1")
        }
    }
    
    // MARK: Returning JSON
    func testJsonify() {
        XCTempAssertNoThrowError("Failed to initialize the server configuration") {
            let config = try XcodeServerConfig(host: "127.0.0.1", user: "ICanCreateBots", password: "superSecr3t")
            let expected = [
                "host": "https://127.0.0.1",
                "user": "ICanCreateBots",
                "password": "superSecr3t"
            ]
            
            XCTAssertEqual(config.jsonify(), expected)
        }
    }

}
