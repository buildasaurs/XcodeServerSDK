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
    private func sendRequestWithMethod(method: HTTP.Method, endpoint: XcodeServerEndPoints.Endpoint, params: [String: String]?, query: [String: String]?, body: NSDictionary?, completion: HTTP.Completion) {
        
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
    
    public func login(completion: (success: Bool, error: NSError?) -> ()) {
        
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
    
    public func logout(completion: (success: Bool, error: NSError?) -> ()) {
        
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
    
    public enum CreateBotResponse {
        case Success(bot: Bot)
        case BlueprintNeedsFixing(fixedBlueprint: SourceControlBlueprint)
        case Error(error: ErrorType)
    }
    
    private func replacePlaceholderPlatformInBot(bot: Bot, platforms: [DevicePlatform]) {
        
        if let filter = bot.configuration.deviceSpecification.filters.first {
            let intendedPlatform = filter.platform
            if let platform = platforms.findFirst({ $0.type == intendedPlatform.type }) {
                //replace
                filter.platform = platform
            } else {
                fatalError("Couldn't find intended platform in list of platforms: \(platforms)!")
            }
        } else {
            fatalError("Couldn't find device filter!")
        }
    }
    
    /**
    Creates a new Bot from the passed in information. First validates Bot's Blueprint to make sure
    that the credentials are sufficient to access the repository and that the communication between
    the client and XCS will work fine. This might take a couple of seconds, depending on your proximity
    to your XCS.
    */
    public func createBot(botOrder: Bot, completion: (response: CreateBotResponse) -> ()) {
        
        //first validate Blueprint
        let blueprint = botOrder.configuration.sourceControlBlueprint
        self.verifyGitCredentialsFromBlueprint(blueprint) { (response) -> () in
            
            switch response {
            case .Error(let error):
                completion(response: XcodeServer.CreateBotResponse.Error(error: error))
                return
            case .SSHFingerprintFailedToVerify(let fingerprint, _):
                blueprint.certificateFingerprint = fingerprint
                completion(response: XcodeServer.CreateBotResponse.BlueprintNeedsFixing(fixedBlueprint: blueprint))
                return
            case .Success(_, _): break
            }

            //blueprint verified, continue creating our new bot
            
            //next, we need to fetch all the available platforms and pull out the one intended for this bot. (TODO: this could probably be sped up by smart caching)
            self.getPlatforms({ (platforms, error) -> () in
                
                if let error = error {
                    completion(response: XcodeServer.CreateBotResponse.Error(error: error))
                    return
                }
                
                //we have platforms, find the one in the bot config and replace it
                self.replacePlaceholderPlatformInBot(botOrder, platforms: platforms!)
                
                //cool, let's do it.
                self.createBotNoValidation(botOrder, completion: completion)
            })
        }
    }
    
    private func createBotNoValidation(botOrder: Bot, completion: (response: CreateBotResponse) -> ()) {
        
        let body: NSDictionary = botOrder.dictionarify()
        
        self.sendRequestWithMethod(.POST, endpoint: .Bots, params: nil, query: nil, body: body) { (response, body, error) -> () in
            
            if let error = error {
                completion(response: XcodeServer.CreateBotResponse.Error(error: error))
                return
            }
            
            guard let dictBody = body as? NSDictionary else {
                let e = Error.withInfo("Wrong body \(body)")
                completion(response: XcodeServer.CreateBotResponse.Error(error: e))
                return
            }
            
            let bot = Bot(json: dictBody)
            completion(response: XcodeServer.CreateBotResponse.Success(bot: bot))
        }
    }
    
    public func getBot(botTinyId: String, completion: (bot: Bot?, error: NSError?) -> ()) {
        
        let params = [
            "bot": botTinyId
        ]
        
        self.sendRequestWithMethod(.GET, endpoint: .Bots, params: params, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(bot: nil, error: error)
                return
            }
            
            if let body = body as? NSDictionary {
                let bot = Bot(json: body)
                completion(bot: bot, error: nil)
            } else {
                completion(bot: nil, error: Error.withInfo("Wrong body \(body)"))
            }
        }
    }
    
    public func deleteBot(botId: String, revision: String, completion: (success: Bool, error: NSError?) -> ()) {
        
        let params = [
            "rev": revision,
            "bot": botId
        ]
        
        self.sendRequestWithMethod(.DELETE, endpoint: .Bots, params: params, query: nil, body: nil) { (response, body, error) -> () in
            
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
            } else {
                completion(success: false, error: Error.withInfo("Nil response"))
            }
        }
    }
    
    public func getBots(completion: (bots: [Bot]?, error: NSError?) -> ()) {
        
        self.sendRequestWithMethod(.GET, endpoint: .Bots, params: nil, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(bots: nil, error: error)
                return
            }
            
            if let body = (body as? NSDictionary)?["results"] as? NSArray {
                let bots: [Bot] = XcodeServerArray(body)
                completion(bots: bots, error: nil)
            } else {
                completion(bots: nil, error: Error.withInfo("Wrong data returned: \(body)"))
            }
        }
    }
    
    public func getBotIntegrations(botId: String, query: [String: String], completion: (integrations: [Integration]?, error: NSError?) -> ()) {
        
        let params = [
            "bot": botId
        ]
        
        self.sendRequestWithMethod(.GET, endpoint: .Integrations, params: params, query: query, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(integrations: nil, error: error)
                return
            }
            
            if let body = (body as? NSDictionary)?["results"] as? NSArray {
                let integrations: [Integration] = XcodeServerArray(body)
                completion(integrations: integrations, error: nil)
            } else {
                completion(integrations: nil, error: Error.withInfo("Wrong body \(body)"))
            }
        }
    }
    
    /**
    AKA "Integrate this bot now"
    
    :param: botId      MUST BE the full bot.id, cannot be bot.tinyId!
    */
    public func postIntegration(botId: String, completion: (integration: Integration?, error: NSError?) -> ()) {
        
        let params = [
            "bot": botId
        ]
        
        self.sendRequestWithMethod(.POST, endpoint: .Integrations, params: params, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(integration: nil, error: error)
                return
            }
            
            if let body = body as? NSDictionary {
                let integration = Integration(json: body)
                completion(integration: integration, error: nil)
            } else {
                completion(integration: nil, error: Error.withInfo("Wrong body \(body)"))
            }
        }
    }
    
    /**
    XCS API call for retrievieng specified Integration.
    
    - parameter integrationId: ID of integration which is about to be retrieved.
    - parameter completion:
    - Optional retrieved integration.
    - Optional operation error.
    */
    public func getIntegration(integrationId: String, completion: (integration: Integration?, error: NSError?) -> ()) {
        
        let params = [
            "integration": integrationId
        ]
        
        self.sendRequestWithMethod(.GET, endpoint: .Integrations, params: params, query: nil, body: nil) {
            (response, body, error) -> () in
            
            guard error == nil else {
                completion(integration: nil, error: error)
                return
            }
            
            guard let integrationBody = body as? NSDictionary else {
                completion(integration: nil, error: Error.withInfo("Wrong body \(body)"))
                return
            }
            
            let integration = Integration(json: integrationBody)
            completion(integration: integration, error: nil)
        }
    }
    
    public func cancelIntegration(integrationId: String, completion: (success: Bool, error: NSError?) -> ()) {
        
        let params = [
            "integration": integrationId
        ]
        
        self.sendRequestWithMethod(.POST, endpoint: .CancelIntegration, params: params, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(success: false, error: error)
                return
            }
            
            completion(success: true, error: nil)
        }
    }
    
    /**
    XCS API call for retrievieng all available integrations on server.
    
    - parameter integrations:   Optional array of integrations.
    - parameter error:          Optional error.
    */
    public func getIntegrations(completion: (integrations: [Integration]?, error: NSError?) -> ()) {
        
        self.sendRequestWithMethod(.GET, endpoint: .Integrations, params: nil, query: nil, body: nil) {
            (response, body, error) -> () in
            
            guard error == nil else {
                completion(integrations: nil, error: error)
                return
            }
            
            guard let integrationsBody = (body as? NSDictionary)?["results"] as? NSArray else {
                completion(integrations: nil, error: Error.withInfo("Wrong body \(body)"))
                return
            }
            
            let integrations: [Integration] = XcodeServerArray(integrationsBody)
            completion(integrations: integrations, error: nil)
        }
    }
    
    public func getDevices(completion: (devices: [Device]?, error: NSError?) -> ()) {
        
        self.sendRequestWithMethod(.GET, endpoint: .Devices, params: nil, query: nil, body: nil) { (response, body, error) -> () in
            
            if error != nil {
                completion(devices: nil, error: error)
                return
            }
            
            if let array = (body as? NSDictionary)?["results"] as? NSArray {
                let devices: [Device] = XcodeServerArray(array)
                completion(devices: devices, error: error)
            } else {
                completion(devices: nil, error: Error.withInfo("Wrong body \(body)"))
            }
        }
    }
    
    public func getUserCanCreateBots(completion: (canCreateBots: Bool, error: NSError?) -> ()) {
        
        self.sendRequestWithMethod(.GET, endpoint: .UserCanCreateBots, params: nil, query: nil, body: nil) { (response, body, error) -> () in
            
            if let error = error {
                completion(canCreateBots: false, error: error)
                return
            }
            
            if let body = body as? NSDictionary {
                if let canCreateBots = body["result"] as? Bool where canCreateBots == true {
                    completion(canCreateBots: true, error: nil)
                } else {
                    completion(canCreateBots: false, error: Error.withInfo("Specified user cannot create bots"))
                }
            } else {
                completion(canCreateBots: false, error: Error.withInfo("Wrong body \(body)"))
            }
        }
    }
    
    public func getPlatforms(completion: (platforms: [DevicePlatform]?, error: NSError?) -> ()) {
        
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
    
    /**
    XCS API call for getting all repositories stored on Xcode Server.
    
    - parameter repositories: Optional array of repositories.
    - parameter error:        Optional error
    */
    public func getRepositories(completion: (repositories: [Repository]?, error: NSError?) -> ()) {
        
        self.sendRequestWithMethod(.GET, endpoint: .Repositories, params: nil, query: nil, body: nil) { (response, body, error) -> () in
            guard error == nil else {
                completion(repositories: nil, error: error)
                return
            }
            
            guard let repositoriesBody = (body as? NSDictionary)?["results"] as? NSArray else {
                completion(repositories: nil, error: Error.withInfo("Wrong body \(body)"))
                return
            }
            
            let repos: [Repository] = XcodeServerArray(repositoriesBody)
            completion(repositories: repos, error: nil)
        }
    }
    
    //more advanced
    
    /**
    Checks whether the current user has the rights to create bots and perform other similar "write" actions.
    Xcode Server offers two tiers of users, ones for reading only ("viewers") and others for management.
    Here we check the current user can manage XCS, which is useful for projects like Buildasaur.
    */
    public func verifyXCSUserCanCreateBots(completion: (success: Bool, error: NSError?) -> ()) {
        
        //the way we check availability is first by logging out (does nothing if not logged in) and then
        //calling getUserCanCreateBots, which, if necessary, automatically authenticates with Basic auth before resolving to true or false in JSON.
        
        self.logout { (success, error) -> () in
            
            if let error = error {
                completion(success: false, error: error)
                return
            }
            
            self.getUserCanCreateBots { (canCreateBots, error) -> () in
                
                if let error = error {
                    completion(success: false, error: error)
                    return
                }
                
                completion(success: canCreateBots, error: nil)
            }
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
