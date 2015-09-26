//
//  XcodeServerTests.swift
//  XcodeServerSDKTests
//
//  Created by Honza Dvorsky on 11/06/2015.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import XCTest
@testable import XcodeServerSDK

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
    
    // MARK: Creadentials tests
    
    func testCredentials() {
        let user = server.credential?.user
        let pass = server.credential?.password
        
        XCTAssertEqual(user!, "ICanCreateBots")
        XCTAssertEqual(pass!, "superSecr3t")
    }
    
    func testNoUserCredentials() {
        let noUserConfig = try! XcodeServerConfig(host: "https://127.0.0.1")
        let server = XcodeServerFactory.server(noUserConfig)
        
        XCTAssertNil(server.credential)
    }
    
    func testLiveUpdates() {
        
        let exp = self.expectationWithDescription("Network")
        let stopHandler = self.server.startListeningForLiveUpdates({ (messages: String) -> () in

            let messages = LiveUpdateMessage.parseMessages(messages)
            print(messages)
//            exp.fulfill()
            })
        self.waitForExpectationsWithTimeout(1000) { (_) -> Void in
            stopHandler()
        }
    }

    func DEV_testLive_GetBots() {
        
        let exp = self.expectationWithDescription("Network")
        self.server.getBots { (bots, error) in
            exp.fulfill()
        }
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func DEV_testLive_FetchAndRecordBot() {
        
        let exp = self.expectationWithDescription("Network")
        let server = self.getRecordingXcodeServer("test_bot")
        
        server.getBots { (bots, error) in
            exp.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func DEV_testLive_BotCreation() {

        let exp = self.expectationWithDescription("wait")

        let privateKey = self.stringAtPath("~/.ssh/id_rsa")
        let publicKey = self.stringAtPath("~/.ssh/id_rsa.pub")
        
        let blueprint = SourceControlBlueprint(branch: "swift-2", projectWCCIdentifier: "A36AEFA3F9FF1F738E92F0C497C14977DCE02B97", wCCName: "XcodeServerSDK", projectName: "XcodeServerSDK", projectURL: "git@github.com:czechboy0/XcodeServerSDK.git", projectPath: "XcodeServerSDK.xcworkspace", publicSSHKey: publicKey, privateSSHKey: privateKey, sshPassphrase: nil, certificateFingerprint: nil)
        
        let scriptBody = "cd XcodeServerSDK; /usr/local/bin/carthage update --no-build"
        let scriptTrigger = Trigger(phase: .Prebuild, kind: .RunScript, scriptBody: scriptBody, name: "Carthage", conditions: nil, emailConfiguration: nil)!
        
        let devices = [
            "a85553a5b26a7c1a4998f3b237005ac7",
            "a85553a5b26a7c1a4998f3b237004afd"
        ]
        let deviceSpec = DeviceSpecification.iOS(.SelectedDevicesAndSimulators, deviceIdentifiers: devices)
        let config = BotConfiguration(builtFromClean: BotConfiguration.CleaningPolicy.Once_a_Day, codeCoveragePreference: .UseSchemeSetting, buildConfiguration: .UseSchemeSetting, analyze: true, test: true, archive: true, exportsProductFromArchive: true, schemeName: "XcodeServerSDK - iOS", schedule: BotSchedule.commitBotSchedule(), triggers: [scriptTrigger], deviceSpecification: deviceSpec, sourceControlBlueprint: blueprint)
        
        let bot = Bot(name: "TestBot From XcodeServerSDK", configuration: config)

        self.server.createBot(bot) { (response) -> () in
            
            print("")
            switch response {
            case .Success(let newBot):
                
                self.server.postIntegration(newBot.id) { (integration, error) -> () in
                    
                    print("")
                    exp.fulfill()
                }
                
            default: break
            }
        }

        self.waitForExpectationsWithTimeout(1000, handler: nil)
    }
}




