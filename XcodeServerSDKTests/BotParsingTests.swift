//
//  BotParsingTests.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 17/06/15.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import XCTest
import XcodeServerSDK

class BotParsingTests: XCTestCase {
    
    //MARK: shared stuff
    func testShared() {
        
        let bot = self.botInFileWithName("bot_mac_xcode6")
        
        XCTAssertEqual(bot.id, "6b3de48352a8126ce7e08ecf85093613")
        XCTAssertEqual(bot.rev, "16-d1e9e3d7e76a09381ca909d47ac6c18d")
        XCTAssertEqual(bot.tinyID, "2CA4EA9")
    }
    
    //MARK: bot
    func testBot() {
        
        let bot = self.botInFileWithName("bot_mac_xcode6")
        
        XCTAssertEqual(bot.name, "Builda Archiver")
        XCTAssertEqual(bot.integrationsCount, 7)
    }

    //MARK: configuration
    func testConfiguration() {
        
        let configuration = self.configurationFromBotWithName("bot_mac_xcode6")
        
        XCTAssertEqual(configuration.test, true)
        XCTAssertEqual(configuration.analyze, true)
        XCTAssertEqual(configuration.archive, true)
        XCTAssertEqual(configuration.schemeName, "Buildasaur")
    }
    
    //MARK: cleaning policy
    func testCleanPolicy() {
        //TODO: will be a whole set of tests, add all possible cases
    }

    //MARK: test schedule
    func testSchedule() {
        //TODO: will be a whole set of tests, add all possible cases
    }
    
    //MARK: blueprint (good luck with this one)
    func testBlueprint() {
        //TODO: will be a whole set of tests, add all possible cases
    }
    
    //MARK: destination type
    func testDestinationType() {
        //TODO: will be a whole set of tests, add all possible cases
    }
    
    //MARK: triggers
    func testTriggers() {
        //TODO: will be a whole set of tests, add all possible cases
    }
    
    //MARK: testing device ids (on both Xcode 6 and 7 formats!!!)
    func testTestingDeviceIds() {
        //TODO: will be a whole set of tests, add all possible cases
    }
}





