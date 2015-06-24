//
//  BotConfigurationTests.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 24.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
import XcodeServerSDK

class BotConfigurationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: Cleaning policy tests
    func testCleaningPolicyToString() {
        var policy: BotConfiguration.CleaningPolicy
        
        policy = .Never
        XCTAssertEqual(policy.toString(), "Never")
        
        policy = .Always
        XCTAssertEqual(policy.toString(), "Always")
        
        policy = .Once_a_Day
        XCTAssertEqual(policy.toString(), "Once a day (first build)")
        
        policy = .Once_a_Week
        XCTAssertEqual(policy.toString(), "Once a week (first build)")
    }
    
    // MARK: Testing destination tests
    func testTestingDestinationToString() {
        var destination: BotConfiguration.TestingDestinationIdentifier
        
        destination = .iOS_AllDevicesAndSimulators
        XCTAssertEqual(destination.toString(), "iOS: All Devices and Simulators")
        
        destination = .iOS_AllDevices
        XCTAssertEqual(destination.toString(), "iOS: All Devices")
        
        destination = .iOS_AllSimulators
        XCTAssertEqual(destination.toString(), "iOS: All Simulators")
        
        destination = .iOS_SelectedDevicesAndSimulators
        XCTAssertEqual(destination.toString(), "iOS: Selected Devices and Simulators")
        
        destination = .Mac
        XCTAssertEqual(destination.toString(), "Mac")
        
        destination = .AllCompatible
        XCTAssertEqual(destination.toString(), "All Compatible (Mac + iOS)")
    }
    
    func testAllowedDevicesTypes() {
        let allCompatible = BotConfiguration.TestingDestinationIdentifier.AllCompatible
        let selected = BotConfiguration.TestingDestinationIdentifier.iOS_SelectedDevicesAndSimulators
        let allDevicesAndSimulators = BotConfiguration.TestingDestinationIdentifier.iOS_AllDevicesAndSimulators
        let allDevices = BotConfiguration.TestingDestinationIdentifier.iOS_AllDevices
        let allSimulators = BotConfiguration.TestingDestinationIdentifier.iOS_AllSimulators
        let mac = BotConfiguration.TestingDestinationIdentifier.Mac
        
        let allCompatibleExpected: [BotConfiguration.DeviceType] = [.iPhone, .Simulator, .Mac]
        let selectedExpected: [BotConfiguration.DeviceType] = [.iPhone, .Simulator]
        let allDevicesAndSimulatorsExpected: [BotConfiguration.DeviceType] = [.iPhone, .Simulator]
        let allDevicesExpected: [BotConfiguration.DeviceType] = [.iPhone]
        let allSimulatorsExpected: [BotConfiguration.DeviceType] = [.Simulator]
        let macExpected: [BotConfiguration.DeviceType] = [.Mac]
        
        XCTAssertEqual(allCompatible.allowedDeviceTypes(), allCompatibleExpected)
        XCTAssertEqual(selected.allowedDeviceTypes(), selectedExpected)
        XCTAssertEqual(allDevices.allowedDeviceTypes(), allDevicesExpected)
        XCTAssertEqual(allSimulators.allowedDeviceTypes(), allSimulatorsExpected)
        XCTAssertEqual(allDevicesAndSimulators.allowedDeviceTypes(), allDevicesAndSimulatorsExpected)
        XCTAssertEqual(mac.allowedDeviceTypes(), macExpected)
    }

}
