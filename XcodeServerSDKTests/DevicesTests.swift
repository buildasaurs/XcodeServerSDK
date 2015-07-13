//
//  DevicesTests.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 13/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
import XcodeServerSDK

class DevicesTests: XCTestCase {
    
    func testDictionarify() {
        let json = [
            "osVersion" : "10.11",
            "connected" : true,
            "simulator" : false,
            "modelCode" : "Macmini6,1",
            "deviceType" : "com.apple.mac",
            "modelName" : "Mac mini",
            "_id" : "1ad0e8785cacca73d980cdb23600383e",
            "modelUTI" : "com.apple.macmini-unibody-no-optical",
            "doc_type" : "device",
            "trusted" : true,
            "name" : "bozenka",
            "supported" : true,
            "processor" : "2,5 GHz Intel Core i5",
            "identifier" : "A89DE14F-0F3C-5893-AF8A-D9CFF068B82C-x86_64",
            "enabledForDevelopment" : true,
            "serialNumber" : "C07JT7H5DWYL",
            "platformIdentifier" : "com.apple.platform.macosx",
            "_rev" : "3-6a49ba8135f3f4ddcbaefe1b469f479c",
            "architecture" : "x86_64",
            "retina" : false,
            "isServer" : true,
            "tinyID" : "7DCD98A"
        ]
        let macMini = Device(json: json)
        let expected = [ "device_id": "1ad0e8785cacca73d980cdb23600383e" ]
        
        XCTAssertEqual(macMini.dictionarify(), expected)
    }
    
    func testGetDevices() {
        let expectation = self.expectationWithDescription("Get Devices")
        let server = self.getRecordingXcodeServer("get_devices")
        
        server.getDevices { (devices, error) -> () in
            XCTAssertNil(error)
            XCTAssertNotNil(devices)
            
            if let devices = devices {
                XCTAssertEqual(devices.count, 13, "There should be 13 devices")
            }
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
}
