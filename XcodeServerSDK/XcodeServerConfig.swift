//
//  XcodeServerConfig.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 13.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public enum AvailabilityCheckState {
    case Unchecked
    case Checking
    case Failed(NSError?)
    case Succeeded
}

public enum ConfigurationErrors : ErrorType {
    case NoHostProvided
    case InvalidHostProvided(String)
    case InvalidSchemeProvided(String)
}

public class XcodeServerConfig : JSONSerializable {
    
    public let host: String
    public let user: String?
    public let password: String?
    public let port: Int = 20343
    
    public var availabilityState: AvailabilityCheckState
    
    public func jsonify() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict["host"] = self.host
        dict.optionallyAddValueForKey(self.user, key: "user")
        dict.optionallyAddValueForKey(self.password, key: "password")
        return dict
    }
    
    public required init(var host: String, user: String?, password: String?) throws {
        guard let url = NSURL(string: host) else {
            throw ConfigurationErrors.InvalidHostProvided(host)
        }
        
        guard url.scheme.isEmpty || url.scheme == "https" else {
            let errMsg = "Xcode Server generally uses https, please double check your hostname"
            Log.error(errMsg)
            
            throw ConfigurationErrors.InvalidSchemeProvided(errMsg)
        }
        
        // validate if host is a valid URL
        if url.scheme.isEmpty {
            // exted host with https scheme
            host = "https://" + host
        }
        
        self.host = host
        self.user = user
        self.password = password
        self.availabilityState = .Unchecked
    }
    
    public required convenience init?(json: NSDictionary) throws {
        guard let host = json.optionalStringForKey("host") else {
            throw ConfigurationErrors.NoHostProvided
        }

        try self.init(host: host, user: json.optionalStringForKey("user"), password: json.optionalStringForKey("password"))
    }
}