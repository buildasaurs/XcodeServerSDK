//
//  XcodeServer.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 14/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: XcodeServer Class
public class XcodeServer : CIServer {
    
    public var config: XcodeServerConfig
    let endpoints: XcodeServerEndpoints
    
    public var availabilityState: AvailabilityCheckState = .Unchecked
    
    public init(config: XcodeServerConfig, endpoints: XcodeServerEndpoints) {
        
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
let VerifiedAPIVersions: Set<Int> = [6, 7, 9, 10] //will change with time, this codebase supports these versions

// MARK: XcodeServer API methods
public extension XcodeServer {
    
    private func verifyAPIVersion(response: NSHTTPURLResponse) -> NSError? {
        
        guard let headers = response.allHeaderFields as? [String: AnyObject] else {
            return Error.withInfo("No headers provided in response")
        }
        
        let apiVersionString = (headers[Headers_APIVersion] as? String) ?? "-1"
        let apiVersion = Int(apiVersionString)
        
        if let apiVersion = apiVersion where
            apiVersion > 0 && !VerifiedAPIVersions.contains(apiVersion) {
            var common = "Version mismatch: response from API version \(apiVersion), but we only verified versions \(VerifiedAPIVersions). "
            
            let maxVersion = VerifiedAPIVersions.sort().last!
            if apiVersion > maxVersion {
                Log.info("You're using a newer Xcode Server than we've verified (\(apiVersion), last verified is \(maxVersion)). Please visit https://github.com/czechboy0/XcodeServerSDK to check whether there's a new version of the SDK for it. If not, please file an issue in the XcodeServerSDK repository. The requests are still going through, however we haven't verified this API version, so here be dragons.")
            } else {
                common += "You're using an old Xcode Server which we don't support any more. Please look for an older version of the SDK at https://github.com/czechboy0/XcodeServerSDK or consider upgrading your Xcode Server to the current version."
                return Error.withInfo(common)
            }
        }
        
        //all good
        return nil
    }
    
    /**
    Internal usage generic method for sending HTTP requests.
    
    - parameter method:     HTTP method.
    - parameter endpoint:   API endpoint.
    - parameter params:     URL paramaters.
    - parameter query:      URL query.
    - parameter body:       POST method request body.
    - parameter completion: Completion.
    */
    internal func sendRequestWithMethod(method: HTTP.Method, endpoint: XcodeServerEndpoints.Endpoint, params: [String: String]?, query: [String: String]?, body: NSDictionary?, portOverride: Int? = nil, completion: HTTP.Completion) -> NSURLSessionTask? {
        if let request = self.endpoints.createRequest(method, endpoint: endpoint, params: params, query: query, body: body, portOverride: portOverride) {
            
            return self.http.sendRequest(request, completion: { (response, body, error) -> () in
                
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
            return nil
        }
    }
    
}
