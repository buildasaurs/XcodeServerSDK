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
        "name": "Test",
        "posixPermissions": 1,
        "httpAccessType": 1
    ]

    // MARK: Initialization
    func testInit() {
        let repo = Repository(json: json)
        
        XCTAssertEqual(repo.name, "Test")
        XCTAssertEqual(repo.httpAccess, Repository.HTTPAccessType.LoggedIn)
        XCTAssertEqual(repo.sshAccess, Repository.SSHAccessType.LoggedInReadSelectedWrite)
        XCTAssertEqual(repo.writeAccessExternalIds, [ "FDF283F5-B9C3-4B43-9000-EF6A54934D4E", "ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050" ])
        XCTAssertEqual(repo.readAccessExternalIds, [])
    }
    
    func testManualInit() {
        let repo = Repository(name: "Test", httpAccess: .LoggedIn, sshAccess: .LoggedInReadSelectedWrite, writeAccessExternalIds: [ "FDF283F5-B9C3-4B43-9000-EF6A54934D4E", "ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050" ], readAccessExternalIds: [])
        
        XCTAssertEqual(repo.name, "Test")
        XCTAssertEqual(repo.httpAccess, Repository.HTTPAccessType.LoggedIn)
        XCTAssertEqual(repo.sshAccess, Repository.SSHAccessType.LoggedInReadSelectedWrite)
        XCTAssertEqual(repo.writeAccessExternalIds, [ "FDF283F5-B9C3-4B43-9000-EF6A54934D4E", "ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050" ])
        XCTAssertEqual(repo.readAccessExternalIds, [])
    }
    
    func testConvenienceInit() {
        let repo = Repository(name: "Test")
        
        XCTAssertEqual(repo.name, "Test")
        XCTAssertEqual(repo.httpAccess, Repository.HTTPAccessType.None)
        XCTAssertEqual(repo.sshAccess, Repository.SSHAccessType.LoggedInReadWrite)
        XCTAssertEqual(repo.writeAccessExternalIds, [])
        XCTAssertEqual(repo.readAccessExternalIds, [])
    }
    
    // MARK: JSONifying
    func testDictionarify() {
        let repo = Repository(name: "Test", httpAccess: .LoggedIn, sshAccess: .LoggedInReadSelectedWrite, writeAccessExternalIds: [ "FDF283F5-B9C3-4B43-9000-EF6A54934D4E", "ABCDEFAB-CDEF-ABCD-EFAB-CDEF00000050" ], readAccessExternalIds: [])
        
        XCTAssertEqual(repo.dictionarify(), json)
    }
    
    // MARK: Enum tests
    func testHTTPEnum() {
        var httpEnum = Repository.HTTPAccessType.None
        XCTAssertEqual(httpEnum.toString(), "No users are not allowed to read or write")
        
        httpEnum = .LoggedIn
        XCTAssertEqual(httpEnum.toString(), "Logged in users are allowed to read and write")
    }
    
    func testSSHEnum() {
        var sshEnum = Repository.SSHAccessType.SelectedReadWrite
        XCTAssertEqual(sshEnum.toString(), "Only selected users can read and/or write")
        
        sshEnum = .LoggedInReadSelectedWrite
        XCTAssertEqual(sshEnum.toString(), "Only selected users can write but all logged in can read")
        
        sshEnum = .LoggedInReadWrite
        XCTAssertEqual(sshEnum.toString(), "All logged in users can read and write")
    }

}
