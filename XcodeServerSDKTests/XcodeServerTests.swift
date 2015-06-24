//
//  XcodeServerTests.swift
//  XcodeServerSDKTests
//
//  Created by Honza Dvorsky on 11/06/2015.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import XCTest
import XcodeServerSDK

class XcodeServerTests: XCTestCase {
    
    var server: XcodeServer!
    
    override func setUp() {
        super.setUp()
        do {
            let config = try XcodeServerConfig(
                host: "https://127.0.0.1",
                user: "ICanCreateBots",
                password: "superSecr3t")
            self.server = XcodeServerFactory.server(config)
        } catch {
            XCTFail("Failed to initialize the server configuration: \(error)")
        }
    }
    
    func testServerCreation() {
        XCTAssertNotNil(self.server)
    }
}
