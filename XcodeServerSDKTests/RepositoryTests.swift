//
//  Repository.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 28.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
import XcodeServerSDK

class RepositoryTests: XCTestCase {
    
    let json = [
        "readAccessExternalIDs": [],
        "writeAccessExternalIDs": [
            "FDF283F5-B9C3-4B43-9000-EF6A54934D4E",
            "ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050"
        ],
        "name": "Test3",
        "posixPermissions": 1,
        "httpAccessType": 1
    ]

    // MARK: Initialization
    func testInit() {
        let repo = Repository(json: json)
        
        XCTAssertEqual(repo.name, "Test3")
        XCTAssertEqual(repo.httpAccess, Repository.HTTPAccessType.LoggedIn)
        XCTAssertEqual(repo.sshAccess, Repository.SSHAccessType.LoggedInReadSelectedWrite)
        XCTAssertEqual(repo.writeAccessExternalIds, [ "FDF283F5-B9C3-4B43-9000-EF6A54934D4E", "ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050" ])
        XCTAssertEqual(repo.readAccessExternalIds, [])
    }
    
    func testManualInit() {
        let repo = Repository(name: "Test3", httpAccess: .LoggedIn, sshAccess: .LoggedInReadSelectedWrite, writeAccessExternalIds: [ "FDF283F5-B9C3-4B43-9000-EF6A54934D4E", "ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050" ], readAccessExternalIds: [])
        
        XCTAssertEqual(repo.name, "Test3")
        XCTAssertEqual(repo.httpAccess, Repository.HTTPAccessType.LoggedIn)
        XCTAssertEqual(repo.sshAccess, Repository.SSHAccessType.LoggedInReadSelectedWrite)
        XCTAssertEqual(repo.writeAccessExternalIds, [ "FDF283F5-B9C3-4B43-9000-EF6A54934D4E", "ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050" ])
        XCTAssertEqual(repo.readAccessExternalIds, [])
    }

}
