//
//  XcodeServerConfig.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 13.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

public enum AvailabilityCheckState: Equatable {
    case Unchecked
    case Checking
    case Failed(NSError?)
    case Succeeded
}

/// Added `Equatable` to the enum to better test properties of this enum.
public func == (a:AvailabilityCheckState, b:AvailabilityCheckState) -> Bool {
    switch(a,b) {
        case (.Unchecked, .Unchecked) : return true
        case (.Checking, .Checking) : return true
        case (.Failed(let fa), .Failed(let fb)) : return fa == fb
        case (.Succeeded, .Succeeded) : return true
        default: return false
    }
}

/// Posible errors thrown by `XcodeServerConfig`
public enum ConfigurationErrors : ErrorType {
    /// Thrown when no host was provided
    case NoHostProvided
    /// Thrown when an invalid host is provided (host is returned)
    case InvalidHostProvided(String)
    /// Thrown when a host is provided with an invalid scheme (explanation message returned)
    case InvalidSchemeProvided(String)
}

public class XcodeServerConfig : JSONSerializable {
    
    public let host: String
    public let user: String?
    public let password: String?
    public let port: Int = 20343
    
    //if set to false, fails if server certificate is not trusted yet
    public let automaticallyTrustSelfSignedCertificates: Bool = true
    
    public var availabilityState: AvailabilityCheckState = .Unchecked
    
    public func jsonify() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict["host"] = self.host
        dict.optionallyAddValueForKey(self.user, key: "user")
        dict.optionallyAddValueForKey(self.password, key: "password")
        return dict
    }
    
    /**
    Initializes a server configuration with the provided host.
    - parameter host: `Xcode` server host.
    - paramater user: Username that will be used to authenticate against the `host` provided.
    Can be `nil`.
    
    - parameter password: Password that will be used to authenticate against the `host` provided.
    Can be `nil`.
    
    - returns: A fully initialized `XcodeServerConfig` instance.
    
    - throws:
        - `InvalidHostProvided`: When the host provided doesn't produce a valid `URL`
        - `InvalidSchemeProvided`: When the provided scheme is not `HTTPS`
    */
    public required init(var host: String, user: String?=nil, password: String?=nil) throws {
        guard let url = NSURL(string: host) else {
            /*******************************************************************
             **   Had to be added to silence the compiler ¯\_(ツ)_/¯
             **   Radar: http://openradar.me/21514477
             **   Reply: https://twitter.com/jckarter/status/613491369311535104
             ******************************************************************/
            self.host = ""; self.user = nil; self.password = nil
            
            throw ConfigurationErrors.InvalidHostProvided(host)
        }
        
        guard url.scheme.isEmpty || url.scheme == "https" else {
            let errMsg = "Xcode Server generally uses https, please double check your hostname"
            Log.error(errMsg)
            
            /*******************************************************************
            **   Had to be added to silence the compiler ¯\_(ツ)_/¯
            **   Radar: http://openradar.me/21514477
            **   Reply: https://twitter.com/jckarter/status/613491369311535104
            ******************************************************************/
            self.host = ""; self.user = nil; self.password = nil
            
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
    
    /**
    Initializes a server configuration with the provided `json`.
    - parameter json: `NSDictionary` containing the `XcodeServerConfig` «configuration».
    
    - returns: A fully initialized `XcodeServerConfig` instance.
    
    - throws:
        - `NoHostProvided`: When no `host` key was found on the provided `json` dictionary.
        - `InvalidHostProvided`: When the host provided doesn't produce a valid `URL`
        - `InvalidSchemeProvided`: When the provided scheme is not `HTTPS`
    */
    public required convenience init(json: NSDictionary) throws {
        guard let host = json.optionalStringForKey("host") else {
            throw ConfigurationErrors.NoHostProvided
        }

        try self.init(host: host, user: json.optionalStringForKey("user"), password: json.optionalStringForKey("password"))
    }
}