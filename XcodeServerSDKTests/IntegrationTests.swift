//
//  IntegrationTests.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 17/07/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import XcodeServerSDK
import XCTest

class IntegrationTests: XCTestCase {
    
    func test_GetIntegration() {
        
        let exp = self.expectationWithDescription("Network")
        let server = self.getRecordingXcodeServer("get_integration")
        server.getIntegration("ad2fac04895bd1bb06c1d50e3400fd35") { (integration, error) in
            print()
            exp.fulfill()
        }
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    // MARK: Commits
    
    var expectedDate: NSDate = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
        
        return formatter.dateFromString("2015-07-24T09:40:58.462Z")!
    }()
    
    func testGetIntegrationCommits() {
        
        let exp = self.expectationWithDescription("Network")
        let server = self.getRecordingXcodeServer("get_integration_commits")
        server.getIntegrationCommits("56ad016e2e3993ca0b8ed276050150e8") { (integrationCommits, error) in
            XCTAssertNil(error, "Error should be nil")
            
            guard let integrationCommits = integrationCommits else {
                XCTFail("Integration commits are empty")
                return
            }
            
            // Casette assertions
            if let expectationDate = integrationCommits.endedTimeDate {
                XCTAssertEqual(expectationDate, self.expectedDate)
            }
            
            guard let commits = integrationCommits.commits["A36AEFA3F9FF1F738E92F0C497C14977DCE02B97"] else {
                XCTFail("Commits dictionary is empty but should have one key")
                return
            }
            
            XCTAssertEqual(commits.count, 6)
            
            let commiters = Set(commits.map { $0.contributor.name })
            XCTAssertEqual(commiters.count, 2)
            
            exp.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
        
    }
    
}
