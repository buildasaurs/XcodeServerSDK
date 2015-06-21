//
//  XcodeServerTests.swift
//  XcodeServerSDKTests
//
//  Created by Honza Dvorsky on 11/06/2015.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

#if os(iOS)
import Foundation
#else
import Cocoa
#endif
import XCTest
import XcodeServerSDK

class XcodeServerTests: XCTestCase {
    
    var server: XcodeServer!
    
    override func setUp() {
        super.setUp()
        
        let config = XcodeServerConfig(
            host: "https://127.0.0.1",
            user: "ICanCreateBots",
            password: "superSecr3t")
        self.server = XcodeServerFactory.server(config)
    }
    
    func testServerCreation() {
        XCTAssertNotNil(self.server)
    }
}
