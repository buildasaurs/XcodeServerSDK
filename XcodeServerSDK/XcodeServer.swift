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
    
    /**
    Verifies that the blueprint contains valid Git credentials and that the blueprint contains a valid
    server certificate fingerprint for client <-> XCS communication.
    */
    public func verifyGitCredentialsFromBlueprint(blueprint: SourceControlBlueprint, completion: (response: SCMBranchesResponse) -> ()) {
        
        //just a proxy with a more explicit name
        self.postSCMBranchesWithBlueprint(blueprint, completion: completion)
    }
    
    public enum SCMBranchesResponse {
        case Error(ErrorType)
        case SSHFingerprintFailedToVerify(fingerprint: String, repository: String)
        
        //the valid blueprint will have the right certificateFingerprint
        case Success(branches: [(name: String, isPrimary: Bool)], validBlueprint: SourceControlBlueprint)
    }
    
    public func postSCMBranchesWithBlueprint(blueprint: SourceControlBlueprint, completion: (response: SCMBranchesResponse) -> ()) {
        
        let blueprintDict = blueprint.dictionarifyRemoteAndCredentials()
        
        self.sendRequestWithMethod(.POST, endpoint: .SCM_Branches, params: nil, query: nil, body: blueprintDict) { (response, body, error) -> () in
            
            if let error = error {
                completion(response: XcodeServer.SCMBranchesResponse.Error(error))
                return
            }
            
            guard let responseObject = body as? NSDictionary else {
                let e = Error.withInfo("Wrong body: \(body)")
                completion(response: XcodeServer.SCMBranchesResponse.Error(e))
                return
            }
            
            //take the primary repository's key. XCS officially supports multiple checkouts (submodules)
            let primaryRepoId = blueprint.projectWCCIdentifier
            
            //communication worked, now let's see what we got
            //check for errors first
            if
                let repoErrors = responseObject["repositoryErrors"] as? [NSDictionary],
                let repoErrorWrap = repoErrors.findFirst({ $0["repository"] as? String == primaryRepoId }),
                let repoError = repoErrorWrap["error"] as? NSDictionary
                where repoErrors.count > 0 {
                    
                    if let code = repoError["code"] as? Int {
                        
                        //ok, we got an error. do we recognize it?
                        switch code {
                        case -1004:
                            //ok, this is failed fingerprint validation
                            //pull out the new fingerprint and complete.
                            if let fingerprint = repoError["fingerprint"] as? String {
                                
                                //optionally offer to resolve this issue by adopting the new fingerprint
                                if self.config.automaticallyTrustSelfSignedCertificates {
                                    
                                    blueprint.certificateFingerprint = fingerprint
                                    self.postSCMBranchesWithBlueprint(blueprint, completion: completion)
                                    return
                                    
                                } else {
                                    completion(response: XcodeServer.SCMBranchesResponse.SSHFingerprintFailedToVerify(fingerprint: fingerprint, repository: primaryRepoId))
                                }
                                
                            } else {
                                completion(response: XcodeServer.SCMBranchesResponse.Error(Error.withInfo("No fingerprint provided in error \(repoError)")))
                            }
                            
                        default:
                            completion(response: XcodeServer.SCMBranchesResponse.Error(Error.withInfo("Unrecognized error: \(repoError)")))
                        }
                    } else {
                        completion(response: XcodeServer.SCMBranchesResponse.Error(Error.withInfo("No code provided in error \(repoError)")))
                    }
                    return
            }
            
            //cool, no errors. now try to parse branches!
            guard
                let branchesAllRepos = responseObject["branches"] as? NSDictionary,
                let branches = branchesAllRepos[primaryRepoId] as? NSArray else {
                    
                    completion(response: XcodeServer.SCMBranchesResponse.Error(Error.withInfo("No branches provided for our primary repo id: \(primaryRepoId).")))
                    return
            }
            
            //cool, we gots ourselves some branches, let's parse 'em
            let parsedBranches = branches.map({ (name: $0["name"] as! String, isPrimary: $0["primary"] as! Bool) })
            completion(response: XcodeServer.SCMBranchesResponse.Success(branches: parsedBranches, validBlueprint: blueprint))
        }
    }
    
    
    
    //    public func reportQueueSizeAndEstimatedWaitingTime(integration: Integration, completion: ((queueSize: Int, estWait: Double), NSError?) -> ()) {
    
    //TODO: we need to call getIntegrations() -> filter pending and running Integrations -> get unique bots of these integrations -> query for the average integration time of each bot -> estimate, based on the pending/running integrations, how long it will take for the passed in integration to finish
    //    }
    
}
