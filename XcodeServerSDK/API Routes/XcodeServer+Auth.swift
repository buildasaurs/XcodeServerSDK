//
//  XcodeServer+Auth.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 30.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

// MARK: - XcodeSever API Routes for Authorization
extension XcodeServer {
    
    // MARK: Sign in/Sign out
    
    /**
    XCS API call for user sign in.
    
    - parameter success:    Indicates whether sign in was successful.
    - parameter error:      Error indicating failure of sign in.
    */
    public final func login(completion: (success: Bool, error: NSError?) -> ()) {
        
        self.sendRequestWithMethod(.POST, endpoint: .Login, params: nil, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(success: false, error: error)
                return
            }
            
            if let response = response {
                if response.statusCode == 204 {
                    completion(success: true, error: nil)
                } else {
                    completion(success: false, error: Error.withInfo("Wrong status code: \(response.statusCode)"))
                }
                return
            }
            completion(success: false, error: Error.withInfo("Nil response"))
        }
    }
    
    /**
    XCS API call for user sign out.
    
    - parameter success:    Indicates whether sign out was successful.
    - parameter error:      Error indicating failure of sign out.
    */
    public final func logout(completion: (success: Bool, error: NSError?) -> ()) {
        
        self.sendRequestWithMethod(.POST, endpoint: .Logout, params: nil, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(success: false, error: error)
                return
            }
            
            if let response = response {
                if response.statusCode == 204 {
                    completion(success: true, error: nil)
                } else {
                    completion(success: false, error: Error.withInfo("Wrong status code: \(response.statusCode)"))
                }
                return
            }
            completion(success: false, error: Error.withInfo("Nil response"))
        }
    }
    
}