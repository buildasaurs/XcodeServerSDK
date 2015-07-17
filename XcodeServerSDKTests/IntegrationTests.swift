//
//  IntegrationTests.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 17/07/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import XcodeServerSDK
import XCTest

class IntegrationTests: XCTestCase {
    
    func test_GetIntegration() {
        
        let exp = self.expectationWithDescription("Network")
        let server = self.getRecordingXcodeServer("get_integration")
        server.getIntegration("ad2fac04895bd1bb06c1d50e3400fd35") { (integration, error) in
            print()
            exp.fulfill()
        }
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
}
