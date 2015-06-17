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
            user: "ICanCreateBots",
            password: "superSecr3t")
        let server = XcodeServerFactory.server(config)
        
        //we have a setup server now
//        server.getBots { (bots, error) -> () in
//            if let error = error {
//                Log.error("Oh no! \(error.description)")
//                return
//            }
//            
//            //go crazy with bots
//            use bots...
//        }
    }
    
}
