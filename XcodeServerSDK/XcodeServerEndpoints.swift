//
//  XcodeServerEndpoints.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 14/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

public class XcodeServerEndPoints {
    
    enum Endpoint {
        case Bots
        case Integrations
        case CancelIntegration
        case UserCanCreateBots
        case Devices
        case Login
        case Logout
        case Platforms
        case SCM_Branches
        case Repositories
    }
    
    let serverConfig: XcodeServerConfig
    
    /**
    Designated initializer.
    
    - parameter serverConfig: Object of XcodeServerConfig class
    
    - returns: Initialized object of XcodeServer endpoints
    */
    public init(serverConfig: XcodeServerConfig) {
        self.serverConfig = serverConfig
    }
    
    private func endpointURL(endpoint: Endpoint, params: [String: String]? = nil) -> String {
        
        let base = "/api"
        
        switch endpoint {
            
        case .Bots:
            
            let bots = "\(base)/bots"
            if let bot = params?["bot"] {
                let bot = "\(bots)/\(bot)"
                if let rev = params?["rev"] {
                    let rev = "\(bot)/\(rev)"
                    return rev
                }
                return bot
            }
            return bots
            
        case .Integrations:
            
            if let _ = params?["bot"] {
                //gets a list of integrations for this bot
                let bots = self.endpointURL(.Bots, params: params)
                return "\(bots)/integrations"
            }
            
            let integrations = "\(base)/integrations"
            if let integration = params?["integration"] {
                
                let oneIntegration = "\(integrations)/\(integration)"
                return oneIntegration
            }
            return integrations
            
        case .CancelIntegration:
            
            let integration = self.endpointURL(.Integrations, params: params)
            let cancel = "\(integration)/cancel"
            return cancel
            
        case .Devices:
            
            let devices = "\(base)/devices"
            return devices
            
        case .UserCanCreateBots:
            
            let users = "\(base)/auth/isBotCreator"
            return users
            
        case .Login:
            
            let login = "\(base)/auth/login"
            return login
            
        case .Logout:
            
            let logout = "\(base)/auth/logout"
            return logout
            
        case .Platforms:
            
            let platforms = "\(base)/platforms"
            return platforms
            
        case .SCM_Branches:
            
            let branches = "\(base)/scm/branches"
            return branches
            
        case .Repositories:
            
            let repositories = "\(base)/repositories"
            return repositories
            
        }
    }
    
    /**
    Builder method for URlrequests based on input parameters.
    
    - parameter method:      HTTP method used for request (GET, POST etc.)
    - parameter endpoint:    Endpoint object
    - parameter params:      URL params (default is nil)
    - parameter query:       Query parameters (default is nil)
    - parameter body:        Request's body (default is nil)
    - parameter doBasicAuth: Requirement of authorization (default is true)
    
    - returns: NSMutableRequest or nil if wrong URL was provided
    */
    func createRequest(method: HTTP.Method, endpoint: Endpoint, params: [String : String]? = nil, query: [String : String]? = nil, body: NSDictionary? = nil, doBasicAuth auth: Bool = true) -> NSMutableURLRequest? {
        let endpointURL = self.endpointURL(endpoint, params: params)
        let queryString = HTTP.stringForQuery(query)
        let wholePath = "\(self.serverConfig.host):\(self.serverConfig.port)\(endpointURL)\(queryString)"
        
        guard let url = NSURL(string: wholePath) else {
            return nil
        }
        
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = method.rawValue
        
        if auth {
            //add authorization header
            let user = self.serverConfig.user ?? ""
            let password = self.serverConfig.password ?? ""
            let plainString = "\(user):\(password)" as NSString
            let plainData = plainString.dataUsingEncoding(NSUTF8StringEncoding)
            let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            request.setValue("Basic \(base64String!)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted)
                request.HTTPBody = data
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                let error = error as NSError
                Log.error("Parsing error \(error.description)")
                return nil
            }
        }
        
        return request
    }
    
}
