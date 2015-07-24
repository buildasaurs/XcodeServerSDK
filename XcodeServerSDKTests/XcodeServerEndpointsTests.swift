//
//  XcodeServerEndpointsTests.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 20/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
import BuildaUtils
@testable import XcodeServerSDK

class XcodeServerEndpointsTests: XCTestCase {

    let serverConfig = try! XcodeServerConfig(host: "https://127.0.0.1", user: "test", password: "test")
    var endpoints: XcodeServerEndpoints?
    
    override func setUp() {
        super.setUp()
        self.endpoints = XcodeServerEndpoints(serverConfig: serverConfig)
    }
    
    // If malformed URL is passed to request creation function it should early exit and retur nil
    func testMalformedURLCreation() {
        let expectation = endpoints?.createRequest(.GET, endpoint: .Bots, params: ["test": "test"], query: ["test//http\\": "!test"], body: ["test": "test"], doBasicAuth: true)
        XCTAssertNil(expectation, "Shouldn't create request from malformed URL")
    }
    
    // MARK: endpointURL(.Bots)
    
    func testEndpointURLCreationForBotsWithoutParams() {
        let url = self.endpoints?.endpointURL(.Bots)
        XCTAssertEqual(url!, "/api/bots", "endpointURL(.Bots) should return \"/api/bots\"")
    }
    
    func testEndpointURLCreationForBots() {
        let paramsArray = [
            [
                "key": "value"
            ],
            [
                "key": "value",
                "rev": "rev"
            ]
        ]
        for params in paramsArray {
            let url = self.endpoints?.endpointURL(.Bots, params: params)
            XCTAssertEqual(url!, "/api/bots", "endpointURL(.Bots, \(params)) should return \"/api/bots\"")
        }
    }
    
    func testEndpointURLCreationForBotsBot() {
        let paramsArray = [
            [
                "bot": "botValue"
            ],
            [
                "otherKey": "otherValue",
                "bot": "botValue"
            ]
        ]
        for params in paramsArray {
            let url = self.endpoints?.endpointURL(.Bots, params: params)
            XCTAssertEqual(url!, "/api/bots/botValue", "endpointURL(.Bots, \(params)) should return \"/api/bots/botValue\"")
        }
    }
    
    func testEndpointURLCreationForBotsBotRev() {
        let paramsArray = [
            [
                "rev": "revValue",
                "bot": "botValue"
            ],
            [
                "otherKey": "otherValue",
                "bot": "botValue",
                "rev": "revValue"
            ]
        ]
        for params in paramsArray {
            let url = self.endpoints?.endpointURL(.Bots, params: params)
            XCTAssertEqual(url!, "/api/bots/botValue/revValue", "endpointURL(.Bots, \(params)) should return \"/api/bots/botValue/revValue\"")
        }
    }
}
