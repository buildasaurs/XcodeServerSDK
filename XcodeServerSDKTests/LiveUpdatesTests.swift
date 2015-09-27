//
//  LiveUpdatesTests.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 27/09/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import XCTest
import Foundation
@testable import XcodeServerSDK

class LiveUpdatesTests: XCTestCase {
    
    func testParsing_ConnectPacket() {
        
        let message = "1::"
        let packets: [SocketIOPacket] = SocketIOHelper.parsePackets(message)
        XCTAssertEqual(packets.count, 1)
        let packet = packets.first!
        XCTAssertEqual(packet.type, SocketIOPacket.PacketType.Connect)
        XCTAssertNil(packet.jsonPayload)
        XCTAssertEqual(packet.stringPayload, "")
    }
    
    func testParsing_ErrorPacket() {
        let message = "7:::1+0"
        let packets: [SocketIOPacket] = SocketIOHelper.parsePackets(message)
        XCTAssertEqual(packets.count, 1)
        let packet = packets.first!
        XCTAssertEqual(packet.type, SocketIOPacket.PacketType.Error)
        let (reason, advice) = packet.parseError()
        XCTAssertEqual(reason, SocketIOPacket.ErrorReason.ClientNotHandshaken)
        XCTAssertEqual(advice, SocketIOPacket.ErrorAdvice.Reconnect)
    }
    
    func testParsing_SingleEventMessage() {
        
        let message = "5:::{\"name\":\"advisoryIntegrationStatus\",\"args\":[{\"message\":\"BuildaKit : Linking\",\"_id\":\"07a63fae4ff2d5a37eee830be556d143\",\"percentage\":0.7578125,\"botId\":\"07a63fae4ff2d5a37eee830be50c502a\"},null]}"
        let packets: [SocketIOPacket] = SocketIOHelper.parsePackets(message)
        XCTAssertEqual(packets.count, 1)
        let packet = packets.first!
        XCTAssertNotNil(packet.jsonPayload)
        let msg = LiveUpdateMessage(json: packet.jsonPayload!)
        XCTAssertEqual(msg.type, LiveUpdateMessage.MessageType.AdvisoryIntegrationStatus)
        XCTAssertEqual(msg.message, "BuildaKit : Linking")
        XCTAssertEqual(msg.integrationId, "07a63fae4ff2d5a37eee830be556d143")
        XCTAssertEqual(msg.progress, 0.7578125)
        XCTAssertEqual(msg.botId, "07a63fae4ff2d5a37eee830be50c502a")
    }
    
    func testParsing_MultipleEventMessages() {
        let message = "�205�5:::{\"name\":\"advisoryIntegrationStatus\",\"args\":[{\"message\":\"Buildasaur : Linking\",\"_id\":\"07a63fae4ff2d5a37eee830be556d143\",\"percentage\":0.8392857360839844,\"botId\":\"07a63fae4ff2d5a37eee830be50c502a\"},null]}�218�5:::{\"name\":\"advisoryIntegrationStatus\",\"args\":[{\"message\":\"Buildasaur : Copying 1 of 3 files\",\"_id\":\"07a63fae4ff2d5a37eee830be556d143\",\"percentage\":0.8571428680419921,\"botId\":\"07a63fae4ff2d5a37eee830be50c502a\"},null]}�218�5:::{\"name\":\"advisoryIntegrationStatus\",\"args\":[{\"message\":\"Buildasaur : Copying 2 of 3 files\",\"_id\":\"07a63fae4ff2d5a37eee830be556d143\",\"percentage\":0.8607142639160156,\"botId\":\"07a63fae4ff2d5a37eee830be50c502a\"},null]}�228�5:::{\"name\":\"advisoryIntegrationStatus\",\"args\":[{\"message\":\"BuildaUtils : Compiling Swift source files\",\"_id\":\"07a63fae4ff2d5a37eee830be556d143\",\"percentage\":0.05511363506317139,\"botId\":\"07a63fae4ff2d5a37eee830be50c502a\"},null]}"
        let packets: [SocketIOPacket] = SocketIOHelper.parsePackets(message)
        XCTAssertEqual(packets.count, 4)
        for packet in packets {
            XCTAssertNotNil(packet.jsonPayload)
            let msg = LiveUpdateMessage(json: packet.jsonPayload!)
            XCTAssertEqual(msg.type, LiveUpdateMessage.MessageType.AdvisoryIntegrationStatus)
        }
    }
}
