//
//  Repository.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 28.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class Repository: XcodeServerEntity {
    
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
    public var httpAccess: HTTPAccessType = HTTPAccessType.None
    // XCS's defualt if SelectedReadWrite but if you don't provide 
    // array of IDs, nobody will have access to the repository
    public var sshAccess: SSHAccessType = SSHAccessType.LoggedInReadWrite
    public var writeAccessExternalIds: [String] = []
    public var readAccessExternalIds: [String] = []
    
    /**
    Designated initializer.
    
    - parameter name:                   Name of the repository.
    - parameter httpsAccess:            HTTPS access type for the users.
    - parameter sshAccess:              SSH access type for the users.
    - parameter writeAccessExternalIds: ID of users allowed to write to the repository.
    - parameter readAccessExternalIds:  ID of users allowed to read from the repository.
    
    - returns: Initialized repository struct.
    */
    public init(name: String, httpAccess: HTTPAccessType?, sshAccess: SSHAccessType?, writeAccessExternalIds: [String]?, readAccessExternalIds: [String]?) {
        self.name = name
        
        if let httpAccess = httpAccess {
            self.httpAccess = httpAccess
        }
        
        if let sshAccess = sshAccess {
            self.sshAccess = sshAccess
        }
        
        if let writeIDs = writeAccessExternalIds {
            self.writeAccessExternalIds = writeIDs
        }
        
        if let readIDs = readAccessExternalIds {
            self.readAccessExternalIds = readIDs
        }
        
        super.init()
    }
    
    /**
    Convenience initializer.
    This initializer will only allow you to provie name and will create a
    deault repository with values set to:
    - **HTTP Access** - No user is allowed to read/write to repository
    - **SSH Access** - Only selected users are allowed to read/write to repository
    - **Empty arrays** of write and rad external IDs
    
    - parameter name: Name of the repository.
    
    - returns: Initialized default repository wwith provided name
    */
    public convenience init(name: String) {
        self.init(name: name, httpAccess: nil, sshAccess: nil, writeAccessExternalIds: nil, readAccessExternalIds: nil)
    }
    
    /**
    Repository constructor from JSON object.
    
    - parameter json: JSON dictionary representing repository.
    
    - returns: Initialized repository struct.
    */
    public required init(json: NSDictionary) {
        self.name = json.stringForKey("name")
        
        self.httpAccess = HTTPAccessType(rawValue: json.intForKey("httpAccessType"))!
        self.sshAccess = SSHAccessType(rawValue: json.intForKey("posixPermissions"))!
        
        self.writeAccessExternalIds = json.arrayForKey("writeAccessExternalIDs")
        self.readAccessExternalIds = json.arrayForKey("readAccessExternalIDs")
        
        super.init(json: json)
    }
    
    /**
    Method for returning object in form of Dictionary.
    
    - returns: Dictionary representing JSON value of Repository object.
    */
    public override func dictionarify() -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        
        dict["name"] = self.name
        dict["httpAccessType"] = self.httpAccess.rawValue
        dict["posixPermissions"] = self.sshAccess.rawValue
        dict["writeAccessExternalIDs"] = self.writeAccessExternalIds
        dict["readAccessExternalIDs"] = self.readAccessExternalIds
        
        return dict
    }
    
}