//
//  Repository.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 28.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public struct Repository {
    
    /**
    Enumeration describing HTTP access to the repository
    
    - None:      No users are not allowed to read or write
    - LoggedIn:  Logged in users are allowed to read and write
    */
    public enum HTTPAccessType: Int {
        
        case None = 0
        case LoggedIn
        
        public func toString() -> String {
            switch self {
            case .None:
                return "No users are not allowed to read or write"
            case .LoggedIn:
                return "Logged in users are allowed to read and write"
            }
        }
        
    }
    
    /**
    Enumeration describing HTTPS access to the repository
    
    - SelectedReadWrite:         Only selected users can read and/or write
    - LoggedInReadSelectedWrite: Only selected users can write but all logged in can read
    - LoggedInReadWrite:         All logged in users can read and write
    */
    public enum SSHAccessType: Int {
        
        case SelectedReadWrite = 0
        case LoggedInReadSelectedWrite
        case LoggedInReadWrite
        
        public func toString() -> String {
            switch self {
            case .SelectedReadWrite:
                return "Only selected users can read and/or write"
            case .LoggedInReadSelectedWrite:
                return "Only selected users can write but all logged in can read"
            case .LoggedInReadWrite:
                return "All logged in users can read and write"
            }
        }
        
    }
    
    public let name: String
    public let httpAccess: HTTPAccessType
    public let sshAccess: SSHAccessType
    public let writeAccessExternalIds: [String]
    public let readAccessExternalIds: [String]
    
    /**
    Designated initializer.
    
    - parameter name:                   Name of the repository.
    - parameter httpsAccess:            HTTPS access type for the users.
    - parameter sshAccess:              SSH access type for the users.
    - parameter writeAccessExternalIds: ID of users allowed to write to the repository.
    - parameter readAccessExternalIds:  ID of users allowed to read from the repository.
    
    - returns: Initialized repository struct.
    */
    public init(name: String, httpAccess: HTTPAccessType, sshAccess: SSHAccessType, writeAccessExternalIds: [String], readAccessExternalIds: [String]) {
        self.name = name
        self.httpAccess = httpAccess
        self.sshAccess = sshAccess
        self.writeAccessExternalIds = writeAccessExternalIds
        self.readAccessExternalIds = readAccessExternalIds
    }
    
    /**
    Repository constructor from JSON object.
    
    - parameter json: JSON dictionary representing repository.
    
    - returns: Initialized repository struct.
    */
    public init(json: NSDictionary) {
        self.name = json.stringForKey("name")
        
        self.httpAccess = HTTPAccessType(rawValue: json.intForKey("httpAccessType"))!
        self.sshAccess = SSHAccessType(rawValue: json.intForKey("posixPermissions"))!
        
        self.writeAccessExternalIds = json.arrayForKey("writeAccessExternalIDs")
        self.readAccessExternalIds = json.arrayForKey("readAccessExternalIDs")
    }
    
}