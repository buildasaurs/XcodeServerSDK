//
//  XcodeServerEndpointsTests.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 20/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
import BuildaUtils
@testable import XcodeServerSDK

class XcodeServerEndpointsTests: XCTestCase {

    let serverConfig = try! XcodeServerConfig(host: "https://127.0.0.1", user: "test", password: "test")
    var endpoints: XcodeServerEndpoints?
    
    override func setUp() {
        super.setUp()
        self.endpoints = XcodeServerEndpoints(serverConfig: serverConfig)
    }
    
    // If malformed URL is passed to request creation function it should early exit and retur nil
    func testMalformedURLCreation() {
        let expectation = endpoints?.createRequest(.GET, endpoint: .Bots, params: ["test": "test"], query: ["test//http\\": "!test"], body: ["test": "test"], doBasicAuth: true)
        XCTAssertNil(expectation, "Shouldn't create request from malformed URL")
    }
    
    // MARK: endpointURL(.Bots)
    
    func testEndpointURLCreationForBotsPath() {
        let expectation = "/api/bots"
        let url = self.endpoints?.endpointURL(.Bots)
        XCTAssertEqual(url!, expectation, "endpointURL(.Bots) should return \(expectation)")
    }
    
    func testEndpointURLCreationForBotsBotPath() {
        let expectation = "/api/bots/bot_id"
        let params = [
            "bot": "bot_id"
        ]
        let url = self.endpoints?.endpointURL(.Bots, params: params)
        XCTAssertEqual(url!, expectation, "endpointURL(.Bots, \(params)) should return \(expectation)")
    }
    
    func testEndpointURLCreationForBotsBotRevPath() {
        let expectation = "/api/bots/bot_id/rev_id"
        let params = [
            "bot": "bot_id",
            "rev": "rev_id"
        ]
        let url = self.endpoints?.endpointURL(.Bots, params: params)
        XCTAssertEqual(url!, expectation, "endpointURL(.Bots, \(params)) should return \(expectation)")
    }
    
    // MARK: endpointURL(.Integrations)
    
    func testEndpointURLCreationForIntegrationsPath() {
        let expectation = "/api/integrations"
        let url = self.endpoints?.endpointURL(.Integrations)
        XCTAssertEqual(url!, expectation, "endpointURL(.Integrations) should return \(expectation)")
    }
    
    func testEndpointURLCreationForIntegrationsIntegrationPath() {
        let expectation = "/api/integrations/integration_id"
        let params = [
            "integration": "integration_id"
        ]
        let url = self.endpoints?.endpointURL(.Integrations, params: params)
        XCTAssertEqual(url!, expectation, "endpointURL(.Integrations, \(params)) should return \(expectation)")
    }
    
    func testEndpointURLCreationForBotsBotIntegrationsPath() {
        let expectation = "/api/bots/bot_id/integrations"
        let params = [
            "bot": "bot_id"
        ]
        let url = self.endpoints?.endpointURL(.Integrations, params: params)
        XCTAssertEqual(url!, expectation, "endpointURL(.Integrations, \(params)) should return \(expectation)")
    }
    
    // MARK: endpointURL(.CancelIntegration)
    
    func testEndpointURLCreationForIntegrationsIntegrationCancelPath() {
        let expectation = "/api/integrations/integration_id/cancel"
        let params = [
            "integration": "integration_id"
        ]
        let url = self.endpoints?.endpointURL(.CancelIntegration, params: params)
        XCTAssertEqual(url!, expectation, "endpointURL(.CancelIntegration, \(params)) should return \(expectation)")
    }
    
    // MARK: endpointURL(.Devices)
    
    func testEndpointURLCreationForDevicesPath() {
        let expectation = "/api/devices"
        let url = self.endpoints?.endpointURL(.Devices)
        XCTAssertEqual(url!, expectation, "endpointURL(.Devices) should return \(expectation)")
    }
    
    // MARK: endpointURL(.UserCanCreateBots)
    
    func testEndpointURLCreationForAuthIsBotCreatorPath() {
        let expectation = "/api/auth/isBotCreator"
        let url = self.endpoints?.endpointURL(.UserCanCreateBots)
        XCTAssertEqual(url!, expectation, "endpointURL(.UserCanCreateBots) should return \(expectation)")
    }
    
    // MARK: endpointURL(.Login)
    
    func testEndpointURLCreationForAuthLoginPath() {
        let expectation = "/api/auth/login"
        let url = self.endpoints?.endpointURL(.Login)
        XCTAssertEqual(url!, expectation, "endpointURL(.Login) should return \(expectation)")
    }
    
    // MARK: endpointURL(.Logout)
    
    func testEndpointURLCreationForAuthLogoutPath() {
        let expectation = "/api/auth/logout"
        let url = self.endpoints?.endpointURL(.Logout)
        XCTAssertEqual(url!, expectation, "endpointURL(.Logout) should return \(expectation)")
    }
    
    // MARK: endpointURL(.Platforms)
    
    func testEndpointURLCreationForPlatformsPath() {
        let expectation = "/api/platforms"
        let url = self.endpoints?.endpointURL(.Platforms)
        XCTAssertEqual(url!, expectation, "endpointURL(.Platforms) should return \(expectation)")
    }
    
    // MARK: endpointURL(.SCM_Branches)
    
    func testEndpointURLCreationForScmBranchesPath() {
        let expectation = "/api/scm/branches"
        let url = self.endpoints?.endpointURL(.SCM_Branches)
        XCTAssertEqual(url!, expectation, "endpointURL(.SCM_Branches) should return \(expectation)")
    }
    
    // MARK: endpointURL(.Repositories)
    
    func testEndpointURLCreationForRepositoriesPath() {
        let expectation = "/api/repositories"
        let url = self.endpoints?.endpointURL(.Repositories)
        XCTAssertEqual(url!, expectation, "endpointURL(.Repositories) should return \(expectation)")
    }
}
