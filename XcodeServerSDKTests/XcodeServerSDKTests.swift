//
//  XcodeServerSDKTests.swift
//  XcodeServerSDKTests
//
//  Created by Honza Dvorsky on 11/06/2015.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Cocoa
import XCTest
import XcodeServerSDK

class XcodeServerSDKTests: XCTestCase {
    
    func testServerCreation() {
        
        let config = XcodeServerConfig(
            host: "https://127.0.0.1",
            apiVersion: XcodeServerConfig.APIVersion.Xcode7,
            user: "ICanCreateBots",
            password: "superSecr3t")
        
        let server = XcodeServerFactory.server(config)
        
        XCTAssertNotNil(server)
    }
    
}
