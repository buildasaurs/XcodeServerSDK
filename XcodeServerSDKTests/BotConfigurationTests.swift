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
    
    func testDeviceFilterToString() {
        
        var filter: DeviceFilter.FilterType
        
        filter = .AllAvailableDevicesAndSimulators
        XCTAssertEqual(filter.toString(), "All Available Devices and Simulators")
        
        filter = .AllDevices
        XCTAssertEqual(filter.toString(), "All Devices")
        
        filter = .AllSimulators
        XCTAssertEqual(filter.toString(), "All Simulators")
        
        filter = .SelectedDevicesAndSimulators
        XCTAssertEqual(filter.toString(), "Selected Devices and Simulators")
    }
    
    func testAvailableFiltersForPlatform() {
        
        XCTAssertEqual(DeviceFilter.FilterType.availableFiltersForPlatform(.iOS), [
            .AllAvailableDevicesAndSimulators,
            .AllDevices,
            .AllSimulators,
            .SelectedDevicesAndSimulators
            ])
        
        XCTAssertEqual(DeviceFilter.FilterType.availableFiltersForPlatform(.OSX), [
            .AllAvailableDevicesAndSimulators
            ])

        XCTAssertEqual(DeviceFilter.FilterType.availableFiltersForPlatform(.watchOS), [
            .AllAvailableDevicesAndSimulators
            ])
    }

}
