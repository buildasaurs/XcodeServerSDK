//
//  XcodeServer+Toolchain.swift
//  XcodeServerSDK
//
//  Created by Laurent Gaches on 21/04/16.
//  Copyright © 2016 Laurent Gaches. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - Toolchain XcodeSever API Routes
extension XcodeServer {
    
    /**
     XCS API call for getting all available toolchains.
     
     - parameter toolchains: Optional array of available toolchains.
     - parameter error:      Optional error.
     */
    public final func getToolchains(completion: (toolchains: [Toolchain]?,error: NSError?) -> ()) {
        self.sendRequestWithMethod(.GET, endpoint: .Toolchains, params: nil, query: nil, body: nil) { (response, body, error) in
            if error != nil {
                completion(toolchains: nil, error: error)
                return
            }
          
            if let body = (body as? NSDictionary)?["results"] as? NSArray {
                let toolchains: [Toolchain] = XcodeServerArray(body)
                completion(toolchains: toolchains, error: nil)
            } else {
                completion(toolchains: nil, error: Error.withInfo("Wrong body \(body)"))
            }
        }
    }
}