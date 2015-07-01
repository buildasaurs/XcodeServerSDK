//
//  XcodeServer.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 14/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation

// MARK: XcodeServer Class
public class XcodeServer : CIServer {
    
    public let config: XcodeServerConfig
    let endpoints: XcodeServerEndPoints
    
    public init(config: XcodeServerConfig, endpoints: XcodeServerEndPoints) {
        
        self.config = config
        self.endpoints = endpoints
        
        super.init()
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let delegate: NSURLSessionDelegate = self
        let queue = NSOperationQueue.mainQueue()
        let session = NSURLSession(configuration: sessionConfig, delegate: delegate, delegateQueue: queue)
        self.http.session = session
    }
}

// MARK: NSURLSession delegate implementation
extension XcodeServer : NSURLSessionDelegate {
    
    var credential: NSURLCredential? {
        
        if
            let user = self.config.user,
            let password = self.config.password {
                return NSURLCredential(user: user, password: password, persistence: NSURLCredentialPersistence.None)
        }
        return nil
    }
    
    public func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        
        var disposition: NSURLSessionAuthChallengeDisposition = .PerformDefaultHandling
        var credential: NSURLCredential?
        
        if challenge.previousFailureCount > 0 {
            disposition = .CancelAuthenticationChallenge
        } else {
            
            switch challenge.protectionSpace.authenticationMethod {
                
            case NSURLAuthenticationMethodServerTrust:
                credential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!)
            default:
                credential = self.credential ?? session.configuration.URLCredentialStorage?.defaultCredentialForProtectionSpace(challenge.protectionSpace)
            }
            
            if credential != nil {
                disposition = .UseCredential
            }
        }
        
        completionHandler(disposition, credential)
    }
}

// MARK: Header constants
let Headers_APIVersion = "X-XCSAPIVersion"
let SupportedAPIVersion: Int = 3 //will change with time, this codebase supports this version

// MARK: XcodeServer API methods
public extension XcodeServer {
    
    private func verifyAPIVersion(response: NSHTTPURLResponse) -> NSError? {
        
        guard let headers = response.allHeaderFields as? [String: AnyObject] else {
            return Error.withInfo("No headers provided in response")
        }
        
        guard let apiVersionString = headers[Headers_APIVersion] as? String else {
            return Error.withInfo("Couldn't find API version Int in headers")
        }
        
        guard let apiVersion = Int(apiVersionString) else {
            return Error.withInfo("Couldn't find API version Int in headers")
        }
        
        if SupportedAPIVersion != apiVersion {
            var common = "Version mismatch: response from API version \(apiVersion), but we support version \(SupportedAPIVersion). "
            
            if apiVersion > SupportedAPIVersion {
                common += "You're using a newer Xcode Server than we support. Please visit https://github.com/czechboy0/XcodeServerSDK to check whether there's a new version of the SDK for it."
            } else {
                common += "You're using an old Xcode Server which we don't support any more. Please look for an older version of the SDK at https://github.com/czechboy0/XcodeServerSDK or consider upgrading your Xcode Server to the current version."
            }
            
            return Error.withInfo(common)
        }
        
        //all good
        return nil
    }
    
    //API functionality
    internal func sendRequestWithMethod(method: HTTP.Method, endpoint: XcodeServerEndPoints.Endpoint, params: [String: String]?, query: [String: String]?, body: NSDictionary?, completion: HTTP.Completion) {
        
        var allParams = [
            "method": method.rawValue
        ]
        
        //merge the two params
        if let params = params {
            for (key, value) in params {
                allParams[key] = value
            }
        }
        
        if let request = self.endpoints.createRequest(method, endpoint: endpoint, params: allParams, query: query, body: body) {
            
            self.http.sendRequest(request, completion: { (response, body, error) -> () in
                
                //TODO: fix hack, make completion always return optionals
                let resp: NSHTTPURLResponse? = response
                
                guard let r = resp else {
                    let e = error ?? Error.withInfo("Nil response")
                    completion(response: nil, body: body, error: e)
                    return
                }
                
                if let versionError = self.verifyAPIVersion(r) {
                    completion(response: response, body: body, error: versionError)
                    return
                }
                
                if case (200...299) = r.statusCode {
                    //pass on
                    completion(response: response, body: body, error: error)
                } else {
                    //see if we haven't received a XCS failure in headers
                    if let xcsStatusMessage = r.allHeaderFields["X-XCSResponse-Status-Message"] as? String {
                        let e = Error.withInfo(xcsStatusMessage)
                        completion(response: response, body: body, error: e)
                    } else {
                        completion(response: response, body: body, error: error)
                    }
                }
            })
            
        } else {
            completion(response: nil, body: nil, error: Error.withInfo("Couldn't create Request"))
        }
    }
    
    
    //    public func reportQueueSizeAndEstimatedWaitingTime(integration: Integration, completion: ((queueSize: Int, estWait: Double), NSError?) -> ()) {
    
    //TODO: we need to call getIntegrations() -> filter pending and running Integrations -> get unique bots of these integrations -> query for the average integration time of each bot -> estimate, based on the pending/running integrations, how long it will take for the passed in integration to finish
    //    }
    
}
