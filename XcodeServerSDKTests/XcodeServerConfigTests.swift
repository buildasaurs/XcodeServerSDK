//
//  XcodeServerConfigTests.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 20/06/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
import XcodeServerSDK

class XcodeServerConfigTests: XCTestCase {

    // MARK: AvailabilityCheckState testing
    func testEqualityOfUncheckedStates() {
        XCTAssertEqual(AvailabilityCheckState.Unchecked, AvailabilityCheckState.Unchecked)
    }
    
    func testEqualityOfCheckingStates() {
        XCTAssertEqual(AvailabilityCheckState.Checking, AvailabilityCheckState.Checking)
    }
    
    func testEqualityOfFailedStates() {
        let error1 = ConfigurationErrors.InvalidSchemeProvided("http") as NSError
        let error2 = ConfigurationErrors.InvalidSchemeProvided("ftp") as NSError
        XCTAssertEqual(AvailabilityCheckState.Failed(error1), AvailabilityCheckState.Failed(error2))
    }
    
    func testInequalityOfFailedStates() {
        let error1 = ConfigurationErrors.NoHostProvided as NSError
        let error2 = ConfigurationErrors.InvalidSchemeProvided("ftp") as NSError
        XCTAssertNotEqual(AvailabilityCheckState.Failed(error1), AvailabilityCheckState.Failed(error2))
    }
    
    func testEqualityOfSucceededStates() {
        XCTAssertEqual(AvailabilityCheckState.Succeeded, AvailabilityCheckState.Succeeded)
    }
    
    func testInequalityOfUncheckedAndSucceededStates() {
        XCTAssertNotEqual(AvailabilityCheckState.Unchecked, AvailabilityCheckState.Succeeded)
    }
    
    // MARK: Initialization testing
    func testManualInit() {
        XCTempAssertNoThrowError("Failed to initialize the server configuration") {
            let config = try XcodeServerConfig(host: "127.0.0.1", user: "ICanCreateBots", password: "superSecr3t")
            
            XCTAssertEqual(config.host, "https://127.0.0.1", "Should create proper host address")
            XCTAssertEqual(config.user!, "ICanCreateBots")
            XCTAssertEqual(config.password!, "superSecr3t")
            XCTAssertTrue(config.availabilityState == AvailabilityCheckState.Unchecked)
        }
    }
    
    func testInvalidHostProvidingForManualInit() {
        XCTempAssertThrowsSpecificError(ConfigurationErrors.InvalidHostProvided("Invalid host name provided, please double check your host name")) {
            _ = try XcodeServerConfig(host: "<>127.0.0.1", user: "ICanCreateBots", password: "superSecr3t")
        }
    }
    
    func testDictionaryInit() {
        XCTempAssertNoThrowError("Failed to initialize the server configuration") {
            let json = [
                "host": "https://127.0.0.1",
                "user": "ICanCreateBots",
                "password": "superSecr3t"
            ]
            
            let config = try XcodeServerConfig(json: json)
            
            XCTAssertEqual(config.host, "https://127.0.0.1", "Should create proper host address")
            XCTAssertEqual(config.user!, "ICanCreateBots")
            XCTAssertEqual(config.password!, "superSecr3t")
        }
    }
    
    func testInvalidDictionaryInit() {
        let json = [
            "user": "ICanCreateBots",
            "password": "superSecr3t"
        ]
        
        XCTempAssertThrowsSpecificError(ConfigurationErrors.NoHostProvided) {
            _ = try XcodeServerConfig(json: json)
        }
    }
    
    func testInvalidSchemeProvided() {
        XCTempAssertThrowsSpecificError(ConfigurationErrors.InvalidSchemeProvided("Xcode Server generally uses https, please double check your hostname")) {
            _ = try XcodeServerConfig(host: "http://127.0.0.1")
        }
    }
    
    // MARK: Returning JSON
    func testJsonify() {
        XCTempAssertNoThrowError("Failed to initialize the server configuration") {
            let config = try XcodeServerConfig(host: "127.0.0.1", user: "ICanCreateBots", password: "superSecr3t")
            let expected = [
                "host": "https://127.0.0.1",
                "user": "ICanCreateBots",
                "password": "superSecr3t"
            ]
            
            XCTAssertEqual(config.jsonify(), expected)
        }
    }
    
    //just to have a perf test
    func testPerformance() {
        self.measureBlock { () -> Void in
            _ = try! XcodeServerConfig(host: "127.0.0.1", user: "ICanCreateBots", password: "superSecr3t")
        }
    }

}
