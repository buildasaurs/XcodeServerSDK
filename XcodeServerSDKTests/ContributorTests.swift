//
//  ContributorTests.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 21/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
@testable import XcodeServerSDK

class ContributorTests: XCTestCase {

    let singleEmailContributor = [
        kContributorName: "Foo Bar",
        kContributorDisplayName: "Foo",
        kContributorEmails: [
            "foo@bar.com"
        ]
    ]
    
    let multiEmailContributor = [
        kContributorName: "Baz Bar",
        kContributorDisplayName: "Baz",
        kContributorEmails: [
            "baz@bar.com",
            "baz@example.com"
        ]
    ]
    
    var singleEmail: Contributor!
    var multiEmail: Contributor!
    
    override func setUp() {
        super.setUp()
        
        singleEmail = try! Contributor(json: singleEmailContributor)
        multiEmail = try! Contributor(json: multiEmailContributor)
    }
    
    // MARK: Test cases
    func testInitialization() {
        XCTAssertEqual(singleEmail.name, "Foo Bar")
        XCTAssertEqual(singleEmail.emails.count, 1)
        
        XCTAssertEqual(multiEmail.name, "Baz Bar")
        XCTAssertEqual(multiEmail.emails.count, 2)
    }
    
    // MARK: Dictionarify
    func testDictionarify() {
        XCTAssertEqual(singleEmail.dictionarify(), singleEmailContributor)
        XCTAssertEqual(multiEmail.dictionarify(), multiEmailContributor)
    }
    
    func testDescription() {
        XCTAssertEqual(multiEmail.description(), "Baz [baz@bar.com]")
    }
    
}
