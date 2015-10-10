//
//  XcodeServer+Miscs.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 10/10/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

import BuildaUtils

// MARK: - Miscellaneous XcodeSever API Routes
extension XcodeServer {
    
    /**
    XCS API call for retrieving its canonical hostname.
    */
    public final func getHostname(completion: (hostname: String?, error: NSError?) -> ()) {
        
        self.sendRequestWithMethod(.GET, endpoint: .Hostname, params: nil, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(hostname: nil, error: error)
                return
            }
            
            if let hostname = (body as? NSDictionary)?["hostname"] as? String {
                completion(hostname: hostname, error: nil)
            } else {
                completion(hostname: nil, error: Error.withInfo("Wrong body \(body)"))
            }
        }
    }
    
}

