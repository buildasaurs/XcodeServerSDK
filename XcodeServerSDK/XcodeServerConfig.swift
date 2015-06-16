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
    
    public init(var host: String, user: String?, password: String?) {
        
        // validate if host is a valid URL
        if let url = NSURL(string: host) {
            if url.scheme.isEmpty {
                // exted host with https scheme
                host.extend("https://")
            } else if url.scheme != "https" {
                Log.error("Xcode Server generally uses https, please double check your hostname")
            }
        }
        
        self.host = host
        self.user = user
        self.password = password
        self.availabilityState = .Unchecked
    }
    
    public required init?(json: NSDictionary) {
        
        self.availabilityState = .Unchecked
        
        if let host = json.optionalStringForKey("host") {
            self.host = host
            self.user = json.optionalStringForKey("user")
            self.password = json.optionalStringForKey("password")
            
        } else {
            self.host = ""
            self.user = nil
            self.password = nil
            return nil
        }
    }
}