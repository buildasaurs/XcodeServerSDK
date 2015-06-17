//
//  BotParsingTests.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 17/06/15.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Cocoa
import XCTest
import XcodeServerSDK

class BotParsingTests: XCTestCase {

    func testCommonProperties() {
        
        let json = self.loadJSONWithName("bot_mac_xcode6")
        let bot = Bot(json: json)
        
        XCTAssertEqual(bot.id, "6b3de48352a8126ce7e08ecf85093613")
        XCTAssertEqual(bot.rev, "16-d1e9e3d7e76a09381ca909d47ac6c18d")
        XCTAssertEqual(bot.tinyID, "2CA4EA9")
        
        XCTAssertEqual(bot.name, "Builda Archiver")
        //...
    }

}
