//
//  MiscsTests.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 10/10/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
import Foundation
@testable import XcodeServerSDK
import Nimble

class MiscsTests: XCTestCase {

    func testHostname_Success() {

        let server = self.getRecordingXcodeServer("hostname")
        var done = false
        
        server.getHostname { (hostname, error) -> () in
            expect(error).to(beNil())
            expect(hostname) == "honzadvysmbpr14.home"
            done = true
        }
        
        expect(done).toEventually(beTrue())
    }
}
