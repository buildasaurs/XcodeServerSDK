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
    var endpoints: XcodeServerEndPoints?
    
    override func setUp() {
        self.endpoints = XcodeServerEndPoints(serverConfig: serverConfig)
    }
    
    // If malformed URL is passed to request creation function it should early exit and retur nil
    func testMalformedURLCreation() {
        let expectation = endpoints?.createRequest(.GET, endpoint: .Bots, params: ["test": "test"], query: ["test//http\\": "!test"], body: ["test": "test"], doBasicAuth: true)
        XCTAssertNil(expectation, "Shouldn't create request from malformed URL")
    }

}
