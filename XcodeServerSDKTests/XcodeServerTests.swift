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
    
    func DEVELOPMENT_ONLY_testFetchAndRecordBot() {
        
        let exp = self.expectationWithDescription("Network")
        let server = self.getRecordingXcodeServer("test_bot")
        
        server.getBots { (bots, error) in
            print()
            exp.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func DEVELOPMENT_ONLY_testLive_BotCreation() {

        let exp = self.expectationWithDescription("wait")

        let privateKey = self.stringAtPath("~/.ssh/id_rsa")
        let publicKey = self.stringAtPath("~/.ssh/id_rsa.pub")
        
        let blueprint = SourceControlBlueprint(branch: "swift-2", projectWCCIdentifier: "A36AEFA3F9FF1F738E92F0C497C14977DCE02B97", wCCName: "XcodeServerSDK", projectName: "XcodeServerSDK", projectURL: "git@github.com:czechboy0/XcodeServerSDK.git", projectPath: "XcodeServerSDK.xcworkspace", publicSSHKey: publicKey, privateSSHKey: privateKey, sshPassphrase: nil, certificateFingerprint: nil)
        
        let platform = DevicePlatform.OSX()
        let filter = DeviceFilter(platform: platform, filterType: 0, architectureType: .OSX_Like)
        let deviceSpec = DeviceSpecification(filters: [filter], deviceIdentifiers: [])
        
        let config = BotConfiguration(builtFromClean: BotConfiguration.CleaningPolicy.Once_a_Day, analyze: true, test: true, archive: false, schemeName: "XcodeServerSDK - OS X", schedule: BotSchedule.commitBotSchedule(), triggers: [], deviceSpecification: deviceSpec, testingDestinationType: BotConfiguration.TestingDestinationIdentifier.Mac, sourceControlBlueprint: blueprint)
        
        let bot = Bot(name: "HELLO5", configuration: config)

        self.server.createBot(bot) { (response) -> () in
            print()
            exp.fulfill()
        }

        self.waitForExpectationsWithTimeout(1000, handler: nil)
    }
}




