//
//  LiveUpdateMessage.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 26/09/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class LiveUpdateMessage: XcodeServerEntity {
    
    static func parseMessages(message: String) -> [LiveUpdateMessage] {
        
        let messageComps = message.componentsSeparatedByString(":::")
        let count = messageComps.count
        
        //the first message is a control string, ignore
        guard count > 1 else { return [] }
        
        //just take the content messages
        let messageStrings = messageComps[1..<count]
        
        //parse from strings into dicts
        let parsedJSONs = messageStrings.map { (string: String) -> NSDictionary? in
            guard let data = string.dataUsingEncoding(NSUTF8StringEncoding) else { return nil }
            let obj = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
            let dict = obj as? NSDictionary
            return dict
        }.filter { $0 != nil }.map { $0! }
        
        //parse into objects
        let messages = parsedJSONs.map { LiveUpdateMessage(json: $0) }
        return messages
    }
    
    public enum Type: String {
        
        //bots
        case BotCreated = "botCreated"
        case BotUpdated = "botUpdated"
        case BotRemoved = "botRemoved"
        
        //devices
        case DeviceCreated = "deviceCreated"
        case DeviceUpdated = "deviceUpdated"
        case DeviceRemoved = "deviceRemoved"
        
        //integrations
        case PendingIntegrations = "pendingIntegrations"
        case IntegrationCreated = "integrationCreated"
        case IntegrationStatus = "integrationStatus"
        case IntegrationCanceled = "cancelIntegration"
        case IntegrationRemoved = "integrationRemoved"
        case AdvisoryIntegrationStatus = "advisoryIntegrationStatus"
        
        //repositories
        case ListRepositories = "listRepositories"
        case CreateRepository = "createRepository"
        
        //boilerplate
        case Ping = "ping"
        case Pong = "pong"
        case ACLUpdated = "aclUpdated"
        case RequestPortalSync = "requestPortalSync"
        
        case Unknown = ""
    }
    
    let type: Type
    var message: String? {
        return self.args?["message"] as? String
    }
    
    var progress: Double? {
        return self.args?["percentage"] as? Double
    }
    
    private var args: NSDictionary? {
        return self.originalJSON?["args"]?[0] as? NSDictionary
    }
    
    required public init(json: NSDictionary) {
        
        let typeString = json.optionalStringForKey("name") ?? ""
        self.type = Type(rawValue: typeString) ?? .Unknown
        
        super.init(json: json)
    }
    
}

extension LiveUpdateMessage: CustomStringConvertible {
    
    public var description: String {
        return "LiveUpdateMessage \"\(self.type)\", \(self.progress), \"\(self.message)\""
    }
}
