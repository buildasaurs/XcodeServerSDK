//
//  XcodeServer+Platform.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 01/07/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - XcodeSever API Routes for Platform management
extension XcodeServer {
    
    /**
    XCS API method for getting available testing platforms on OS X Server.
    
    - parameter platforms:  Optional array of platforms.
    - parameter error:      Optional error indicating some problems.
    */
    public final func getPlatforms(completion: (platforms: [DevicePlatform]?, error: NSError?) -> ()) {
        
        self.sendRequestWithMethod(.GET, endpoint: .Platforms, params: nil, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(platforms: nil, error: error)
                return
            }
            
            if let array = (body as? NSDictionary)?["results"] as? NSArray {
                let platforms: [DevicePlatform] = XcodeServerArray(array)
                completion(platforms: platforms, error: error)
            } else {
                completion(platforms: nil, error: Error.withInfo("Wrong body \(body)"))
            }
        }
    }
    
}
