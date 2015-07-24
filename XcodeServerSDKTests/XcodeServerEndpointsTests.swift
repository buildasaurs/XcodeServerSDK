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
    var randomParams: [String: String]?
    
    override func setUp() {
        super.setUp()
        self.endpoints = XcodeServerEndpoints(serverConfig: serverConfig)
        self.randomParams = [
            "rev": "revValue",
            "bot": "botValue",
            "integration": "integrationValue",
            "otherKey": "otherValue"
        ]
    }
    
    // If malformed URL is passed to request creation function it should early exit and retur nil
    func testMalformedURLCreation() {
        let expectation = endpoints?.createRequest(.GET, endpoint: .Bots, params: ["test": "test"], query: ["test//http\\": "!test"], body: ["test": "test"], doBasicAuth: true)
        XCTAssertNil(expectation, "Shouldn't create request from malformed URL")
    }
    
    // MARK: endpointURL(.Bots)
    
    func testEndpointURLCreationForBotsWithoutParams() {
        let url = self.endpoints?.endpointURL(.Bots)
        XCTAssertEqual(url!, "/api/bots", "endpointURL(.Bots) should return \"/api/bots\"")
    }
    
    func testEndpointURLCreationForBots() {
        let paramsArray = [
            [
                "key": "value"
            ],
            [
                "key": "value",
                "rev": "rev"
            ]
        ]
        for params in paramsArray {
            let url = self.endpoints?.endpointURL(.Bots, params: params)
            XCTAssertEqual(url!, "/api/bots", "endpointURL(.Bots, \(params)) should return \"/api/bots\"")
        }
    }
    
    func testEndpointURLCreationForBotsBot() {
        let paramsArray = [
            [
                "bot": "botValue"
            ],
            [
                "otherKey": "otherValue",
                "bot": "botValue"
            ]
        ]
        for params in paramsArray {
            let url = self.endpoints?.endpointURL(.Bots, params: params)
            XCTAssertEqual(url!, "/api/bots/botValue", "endpointURL(.Bots, \(params)) should return \"/api/bots/botValue\"")
        }
    }
    
    func testEndpointURLCreationForBotsBotRev() {
        let paramsArray = [
            [
                "rev": "revValue",
                "bot": "botValue"
            ],
            [
                "otherKey": "otherValue",
                "bot": "botValue",
                "rev": "revValue"
            ]
        ]
        for params in paramsArray {
            let url = self.endpoints?.endpointURL(.Bots, params: params)
            XCTAssertEqual(url!, "/api/bots/botValue/revValue", "endpointURL(.Bots, \(params)) should return \"/api/bots/botValue/revValue\"")
        }
    }
    
    // MARK: endpointURL(.Integrations)
    
    func testEndpointURLCreationForIntegrationsWithoutParams() {
        let url = self.endpoints?.endpointURL(.Integrations)
        XCTAssertEqual(url!, "/api/integrations", "endpointURL(.Integrations) should return \"/api/integrations\"")
    }
    
    func testEndpointURLCreationForBotsBotIntegrations() {
        let paramsArray = [
            [
                "bot": "botValue"
            ],
            [
                "otherKey": "otherValue",
                "bot": "botValue"
            ],
            [
                "otherKey": "otherValue",
                "bot": "botValue",
                "integration": "integrationValue"
            ]
        ]
        for params in paramsArray {
            let url = self.endpoints?.endpointURL(.Integrations, params: params)
            XCTAssertEqual(url!, "/api/bots/botValue/integrations", "endpointURL(.Integrations, \(params)) should return \"/api/bots/botValue/integrations\"")
        }
    }
    
    func testEndpointURLCreationForBotsBotRevIntegrations() {
        let paramsArray = [
            [
                "rev": "revValue",
                "bot": "botValue"
            ],
            [
                "otherKey": "otherValue",
                "bot": "botValue",
                "rev": "revValue"
            ],
            [
                "otherKey": "otherValue",
                "bot": "botValue",
                "rev": "revValue",
                "integration": "integrationValue"
            ]
        ]
        for params in paramsArray {
            let url = self.endpoints?.endpointURL(.Integrations, params: params)
            XCTAssertEqual(url!, "/api/bots/botValue/revValue/integrations", "endpointURL(.Integrations, \(params)) should return \"/api/bots/botValue/revValue/integrations\"")
        }
    }
    
    func testEndpointURLCreationForIntegrationsIntegration() {
        let paramsArray = [
            [
                "integration": "integrationValue",
            ],
            [
                "otherKey": "otherValue",
                "integration": "integrationValue"
            ],
            [
                "rev": "revValue",
                "otherKey": "otherValue",
                "integration": "integrationValue"
            ]
        ]
        for params in paramsArray {
            let url = self.endpoints?.endpointURL(.Integrations, params: params)
            XCTAssertEqual(url!, "/api/integrations/integrationValue", "endpointURL(.Integrations, \(params)) should return \"/api/integrations/integrationValue\"")
        }
    }
    
    // MARK: endpointURL(.CancelIntegration)
    
    func testEndpointURLCreationForCancelIntegrationWithoutParams() {
        let url = self.endpoints?.endpointURL(.CancelIntegration)
        XCTAssertEqual(url!, "/api/integrations/cancel", "endpointURL(.CancelIntegration) should return \"/api/integrations/cancel\"")
    }
    
    func testEndpointURLCreationForBotsBotIntegrationsCancel() {
        let paramsArray = [
            [
                "bot": "botValue"
            ],
            [
                "otherKey": "otherValue",
                "bot": "botValue"
            ],
            [
                "otherKey": "otherValue",
                "bot": "botValue",
                "integration": "integrationValue"
            ]
        ]
        for params in paramsArray {
            let url = self.endpoints?.endpointURL(.CancelIntegration, params: params)
            XCTAssertEqual(url!, "/api/bots/botValue/integrations/cancel", "endpointURL(.CancelIntegration, \(params)) should return \"/api/bots/botValue/integrations/cancel\"")
        }
    }
    
    func testEndpointURLCreationForBotsBotRevIntegrationsCancel() {
        let paramsArray = [
            [
                "rev": "revValue",
                "bot": "botValue"
            ],
            [
                "otherKey": "otherValue",
                "bot": "botValue",
                "rev": "revValue"
            ],
            [
                "otherKey": "otherValue",
                "bot": "botValue",
                "rev": "revValue",
                "integration": "integrationValue"
            ]
        ]
        for params in paramsArray {
            let url = self.endpoints?.endpointURL(.CancelIntegration, params: params)
            XCTAssertEqual(url!, "/api/bots/botValue/revValue/integrations/cancel", "endpointURL(.CancelIntegration, \(params)) should return \"/api/bots/botValue/revValue/integrations/cancel\"")
        }
    }
    
    func testEndpointURLCreationForIntegrationsIntegrationCancel() {
        let paramsArray = [
            [
                "integration": "integrationValue",
            ],
            [
                "otherKey": "otherValue",
                "integration": "integrationValue"
            ],
            [
                "rev": "revValue",
                "otherKey": "otherValue",
                "integration": "integrationValue"
            ]
        ]
        for params in paramsArray {
            let url = self.endpoints?.endpointURL(.CancelIntegration, params: params)
            XCTAssertEqual(url!, "/api/integrations/integrationValue/cancel", "endpointURL(.CancelIntegration, \(params)) should return \"/api/integrations/integrationValue/cancel\"")
        }
    }
    
    // MARK: endpointURL(.Devices)
    
    func testEndpointURLCreationForDevicesWithoutParams() {
        let url = self.endpoints?.endpointURL(.Devices)
        XCTAssertEqual(url!, "/api/devices", "endpointURL(.Devices) should return \"/api/devices\"")
    }
    
    func testEndpointURLCreationForDevices() {
        let url = self.endpoints?.endpointURL(.Devices, params: self.randomParams)
        XCTAssertEqual(url!, "/api/devices", "endpointURL(.Devices, \(self.randomParams)) should return \"/api/devices\"")
    }
    
    // MARK: endpointURL(.UserCanCreateBots)
    
    func testEndpointURLCreationForUserCanCreateBotsWithoutParams() {
        let url = self.endpoints?.endpointURL(.UserCanCreateBots)
        XCTAssertEqual(url!, "/api/auth/isBotCreator", "endpointURL(.UserCanCreateBots) should return \"/api/auth/isBotCreator\"")
    }
    
    func testEndpointURLCreationForAuthIsBotCreator() {
        let url = self.endpoints?.endpointURL(.UserCanCreateBots, params: self.randomParams)
        XCTAssertEqual(url!, "/api/auth/isBotCreator", "endpointURL(.UserCanCreateBots, \(self.randomParams)) should return \"/api/auth/isBotCreator\"")
    }
    
    // MARK: endpointURL(.Login)
    
    func testEndpointURLCreationForLoginWithoutParams() {
        let url = self.endpoints?.endpointURL(.Login)
        XCTAssertEqual(url!, "/api/auth/login", "endpointURL(.Login) should return \"/api/auth/login\"")
    }
    
    func testEndpointURLCreationForAuthLogin() {
        let url = self.endpoints?.endpointURL(.Login, params: self.randomParams)
        XCTAssertEqual(url!, "/api/auth/login", "endpointURL(.Login, \(self.randomParams)) should return \"/api/auth/login\"")
    }
    
    // MARK: endpointURL(.Logout)
    
    func testEndpointURLCreationForLogoutWithoutParams() {
        let url = self.endpoints?.endpointURL(.Logout)
        XCTAssertEqual(url!, "/api/auth/logout", "endpointURL(.Logout) should return \"/api/auth/logout\"")
    }
    
    func testEndpointURLCreationForAuthLogout() {
        let url = self.endpoints?.endpointURL(.Logout, params: self.randomParams)
        XCTAssertEqual(url!, "/api/auth/logout", "endpointURL(.Logout, \(self.randomParams)) should return \"/api/auth/logout\"")
    }
    
    // MARK: endpointURL(.Platforms)
    
    func testEndpointURLCreationForPlatformsWithoutParams() {
        let url = self.endpoints?.endpointURL(.Platforms)
        XCTAssertEqual(url!, "/api/platforms", "endpointURL(.Platforms) should return \"/api/platforms\"")
    }
    
    func testEndpointURLCreationForPlatforms() {
        let url = self.endpoints?.endpointURL(.Platforms, params: self.randomParams)
        XCTAssertEqual(url!, "/api/platforms", "endpointURL(.Platforms, \(self.randomParams)) should return \"/api/platforms\"")
    }
    
    // MARK: endpointURL(.SCM_Branches)
    
    func testEndpointURLCreationForSCMBranchesWithoutParams() {
        let url = self.endpoints?.endpointURL(.SCM_Branches)
        XCTAssertEqual(url!, "/api/scm/branches", "endpointURL(.SCM_Branches) should return \"/api/scm/branches\"")
    }
    
    func testEndpointURLCreationForSCMBranches() {
        let url = self.endpoints?.endpointURL(.SCM_Branches, params: self.randomParams)
        XCTAssertEqual(url!, "/api/scm/branches", "endpointURL(.SCM_Branches, \(self.randomParams)) should return \"/api/scm/branches\"")
    }
    
    // MARK: endpointURL(.Repositories)
    
    func testEndpointURLCreationForRepositoriesWithoutParams() {
        let url = self.endpoints?.endpointURL(.Repositories)
        XCTAssertEqual(url!, "/api/repositories", "endpointURL(.Repositories) should return \"/api/repositories\"")
    }
    
    func testEndpointURLCreationForRepositories() {
        let url = self.endpoints?.endpointURL(.Repositories, params: self.randomParams)
        XCTAssertEqual(url!, "/api/repositories", "endpointURL(.Repositories, \(self.randomParams)) should return \"/api/repositories\"")
    }
}
