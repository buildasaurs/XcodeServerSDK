//
//  SocketIOHelper.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 27/09/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

/*
inspired by: /Applications/Xcode.app/Contents/Developer/usr/share/xcs/xcsd/node_modules/socket.io/lib/parser.js
also helped: https://github.com/Crphang/Roadents/blob/df59d10bd102f04962e933f9a477066ea0c84da7/socket.IO-objc-master/SocketIOTransportXHR.m
*/

public struct SocketIOPacket {
    
    public enum PacketType: Int {
        case Disconnect = 0
        case Connect = 1
        case Heartbeat = 2
        case Message = 3
        case JSON = 4
        case Event = 5
        case Ack = 6
        case Error = 7
        case Noop = 8
    }
    
    public enum ErrorReason: Int {
        case TransportNotSupported = 0
        case ClientNotHandshaken = 1
        case Unauthorized = 2
    }
    
    public enum ErrorAdvice: Int {
        case Reconnect = 0
    }

    private let dataString: String
    public let type: PacketType
    public let stringPayload: String
    public var jsonPayload: NSDictionary? {
        guard let data = self.stringPayload.dataUsingEncoding(NSUTF8StringEncoding) else { return nil }
        let obj = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
        let dict = obj as? NSDictionary
        return dict
    }
    
    public init?(data: String) {
        self.dataString = data
        guard let comps = SocketIOPacket.parseComps(data) else { return nil }
        (self.type, self.stringPayload) = comps
    }
    
    private static func countInitialColons(data: String) -> Int {
        var initialColonsCount = 0
        for i in data.characters {
            if i == ":" {
                initialColonsCount += 1
            } else {
                if initialColonsCount > 0 {
                    break
                }
            }
        }
        return initialColonsCount
    }
    
    private static func parseComps(data: String) -> (type: PacketType, stringPayload: String)? {
        
        //find the initial sequence of colons and count them, to know how to split the packet
        let initialColonsCount = self.countInitialColons(data)
        let splitter = String(count: initialColonsCount, repeatedValue: Character(":"))
        
        let comps = data
            .componentsSeparatedByString(splitter)
            .filter { $0.characters.count > 0 }
        guard comps.count > 0 else { return nil }
        guard
            let typeString = comps.first,
            let typeInt = Int(typeString),
            let type = PacketType(rawValue: typeInt)
            else { return nil }
        let stringPayload = comps.count == 1 ? "" : (comps.last ?? "")
        return (type, stringPayload)
    }
    
    //e.g. "7:::1+0"
    public func parseError() -> (reason: ErrorReason?, advice: ErrorAdvice?) {
        let comps = self.stringPayload.componentsSeparatedByString("+")
        let reasonString = comps.first ?? ""
        let reasonInt = Int(reasonString) ?? -1
        let adviceString = comps.count == 2 ? comps.last! : ""
        let adviceInt = Int(adviceString) ?? -1
        let reason = ErrorReason(rawValue: reasonInt)
        let advice = ErrorAdvice(rawValue: adviceInt)
        return (reason, advice)
    }
}

public class SocketIOHelper {
    
    public static func parsePackets(message: String) -> [SocketIOPacket] {
        
        let packetStrings = self.parsePacketStrings(message)
        let packets = packetStrings.map { SocketIOPacket(data: $0) }.filter { $0 != nil }.map { $0! }
        return packets
    }
    
    private static func parsePacketStrings(message: String) -> [String] {
        
        // Sometimes Socket.IO "batches" up messages in one packet, so we have to split them.
        // "Batched" format is:
        // �[packet_0 length]�[packet_0]�[packet_1 length]�[packet_1]�[packet_n length]�[packet_n]
        let splitChar = "\u{fffd}"
        guard message.hasPrefix(splitChar) else { return [message] }
        
        let comps = message
            .substringFromIndex(message.startIndex.advancedBy(1))
            .componentsSeparatedByString(splitChar)
            .filter { $0.componentsSeparatedByString(":::").count > 1 }
        return comps
    }
}
