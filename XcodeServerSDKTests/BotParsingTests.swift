//
//  BotParsingTests.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 17/06/15.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import XcodeServerSDK
import XCTest

class BotParsingTests: XCTestCase {
    
    //MARK: shared stuff
    
    func testParseOSXBot() {
        
        let exp = self.expectationWithDescription("Network")
        let server = self.getRecordingXcodeServer("osx_bot")
        
        server.getBot("963bc95f1c1a56f69f3392b4aa03302f") { (bots, error) in
            exp.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testShared() {
        
        let bot = self.botInCassetteWithName("osx_bot")
        
        XCTAssertEqual(bot.id, "963bc95f1c1a56f69f3392b4aa03302f")
        XCTAssertEqual(bot.rev, "10-117b73f201ea103229a2e8cd26a01845")
        XCTAssertEqual(bot.tinyID, "4807518")
    }
    
    //MARK: bot
//    func testBot() {
//        
//        let bot = self.botInFileWithName("bot_mac_xcode6")
//        
//        XCTAssertEqual(bot.name, "Builda Archiver")
//        XCTAssertEqual(bot.integrationsCount, 7)
//    }
//
//    //MARK: configuration
//    func testConfiguration() {
//        
//        let configuration = self.configurationFromBotWithName("bot_mac_xcode6")
//        
//        XCTAssertEqual(configuration.test, true)
//        XCTAssertEqual(configuration.analyze, true)
//        XCTAssertEqual(configuration.archive, true)
//        XCTAssertEqual(configuration.schemeName, "Buildasaur")
//    }
    
    //MARK: cleaning policy
//    func testCleanPolicy() {
//        //TODO: will be a whole set of tests, add all possible cases
//    }
//
//    //MARK: test schedule
//    func testSchedule() {
//        //TODO: will be a whole set of tests, add all possible cases
//    }
//    
//    //MARK: blueprint (good luck with this one)
//    func testBlueprint() {
//        //TODO: will be a whole set of tests, add all possible cases
//    }
//    
//    //MARK: destination type
//    func testDestinationType() {
//        //TODO: will be a whole set of tests, add all possible cases
//    }
//    
//    //MARK: triggers
//    func testTriggers() {
//        //TODO: will be a whole set of tests, add all possible cases
//    }
//    
//    //MARK: testing device ids (on both Xcode 6 and 7 formats!!!)
//    func testTestingDeviceIds() {
//        //TODO: will be a whole set of tests, add all possible cases
//    }
}





