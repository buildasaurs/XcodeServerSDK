//
//  XcodeServer+Bot.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 01.07.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - XcodeSever API Routes for Bot management
extension XcodeServer {
    
    // MARK: Bot management
    
    /**
    Creates a new Bot from the passed in information. First validates Bot's Blueprint to make sure
    that the credentials are sufficient to access the repository and that the communication between
    the client and XCS will work fine. This might take a couple of seconds, depending on your proximity
    to your XCS.
    
    - parameter botOrder:   Bot object which is wished to be created.
    - parameter response:   Response from the XCS.
    */
    public final func createBot(botOrder: Bot, completion: (response: CreateBotResponse) -> ()) {
        
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
                
                do {
                    //we have platforms, find the one in the bot config and replace it
                    try self.replacePlaceholderPlatformInBot(botOrder, platforms: platforms!)
                } catch {
                    completion(response: .Error(error: error))
                    return
                }
                
                //cool, let's do it.
                self.createBotNoValidation(botOrder, completion: completion)
            })
        }
    }

    /**
    XCS API call for getting all available bots.
    
    - parameter bots:       Optional array of available bots.
    - parameter error:      Optional error.
    */
    public final func getBots(completion: (bots: [Bot]?, error: NSError?) -> ()) {
        
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
    
    /**
    XCS API call for getting specific bot.
    
    - parameter botTinyId:  ID of bot about to be received.
    - parameter bot:        Optional Bot object.
    - parameter error:      Optional error.
    */
    public final func getBot(botTinyId: String, completion: (bot: Bot?, error: NSError?) -> ()) {
        
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
    
    /**
    XCS API call for deleting bot on specified revision.
    
    - parameter botId:      Bot's ID.
    - parameter revision:   Revision which should be deleted.
    - parameter success:    Operation result indicator.
    - parameter error:      Optional error.
    */
    public final func deleteBot(botId: String, revision: String, completion: (success: Bool, error: NSError?) -> ()) {
        
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
    
    // MARK: Helpers
    
    /**
    Enum for handling Bot creation response.
    
    - Success:              Bot has been created successfully.
    - BlueprintNeedsFixing: Source Control needs fixing.
    - Error:                Couldn't create Bot.
    */
    public enum CreateBotResponse {
        case Success(bot: Bot)
        case BlueprintNeedsFixing(fixedBlueprint: SourceControlBlueprint)
        case Error(error: ErrorType)
    }
    
    enum PlaceholderError: ErrorType {
        case PlatformMissing
        case DeviceFilterMissing
    }
    
    private func replacePlaceholderPlatformInBot(bot: Bot, platforms: [DevicePlatform]) throws {
        
        if let filter = bot.configuration.deviceSpecification.filters.first {
            let intendedPlatform = filter.platform
            if let platform = platforms.findFirst({ $0.type == intendedPlatform.type }) {
                //replace
                filter.platform = platform
            } else {
                // Couldn't find intended platform in list of platforms
                throw PlaceholderError.PlatformMissing
            }
        } else {
            // Couldn't find device filter
            throw PlaceholderError.DeviceFilterMissing
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

}
