//
//  XcodeServer+LiveUpdates.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 25/09/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

// MARK: - XcodeSever API Routes for Live Updates
extension XcodeServer {
    
    public typealias MessageHandler = (messages: [LiveUpdateMessage]) -> ()
    public typealias StopHandler = () -> ()
    public typealias ErrorHandler = (error: ErrorType) -> ()
    
    private class LiveUpdateState {
        var task: NSURLSessionTask?
        var messageHandler: MessageHandler?
        var errorHandler: ErrorHandler?
        var pollId: String?
        var terminated: Bool = false
        
        func cancel() {
            self.task?.cancel()
            self.task = nil
            self.terminated = true
        }
        
        func error(error: ErrorType) {
            self.cancel()
            self.errorHandler?(error: error)
        }
        
        deinit {
            self.cancel()
        }
    }
    
    /**
    *   Returns StopHandler - call it when you want to stop receiving updates.
    */
    public func startListeningForLiveUpdates(message: MessageHandler, error: ErrorHandler? = nil) -> StopHandler {
        
        let state = LiveUpdateState()
        state.errorHandler = error
        state.messageHandler = message
        self.startPolling(state)
        return {
            state.cancel()
        }
    }
    
    private func queryWithTimestamp() -> [String: String] {
        let timestamp = Int(NSDate().timeIntervalSince1970)*1000
        return [
            "t": "\(timestamp)"
        ]
    }
    
    private func sendRequest(state: LiveUpdateState, params: [String: String]?, completion: (message: String) -> ()) {
        
        let query = queryWithTimestamp()
        let task = self.sendRequestWithMethod(.GET, endpoint: .LiveUpdates, params: params, query: query, body: nil, portOverride: 443) {
            (response, body, error) -> () in
            
            if let error = error {
                state.error(error)
                return
            }
            
            guard let message = body as? String else {
                let e = Error.withInfo("Wrong body: \(body)")
                state.error(e)
                return
            }
            
            completion(message: message)
        }
        state.task = task
    }
    
    private func startPolling(state: LiveUpdateState) {
        
        self.sendRequest(state, params: nil) { [weak self] (message) -> () in
            self?.processInitialResponse(message, state: state)
        }
    }
    
    private func processInitialResponse(initial: String, state: LiveUpdateState) {
        if let pollId = initial.componentsSeparatedByString(":").first {
            state.pollId = pollId
            self.poll(state)
        } else {
            state.error(Error.withInfo("Unexpected initial poll message: \(initial)"))
        }
    }
    
    private func poll(state: LiveUpdateState) {
        precondition(state.pollId != nil)
        let params = [
            "poll_id": state.pollId!
        ]
        
        self.sendRequest(state, params: params) { [weak self] (message) -> () in
            
            let packets = SocketIOHelper.parsePackets(message)
            self?.handlePackets(packets, state: state)
        }
    }
    
    private func handlePackets(packets: [SocketIOPacket], state: LiveUpdateState) {
        
        //check for errors
        if let lastPacket = packets.last where lastPacket.type == .Error {
            let (_, advice) = lastPacket.parseError()
            if
                let advice = advice,
                case .Reconnect = advice {
                    //reconnect!
                    self.startPolling(state)
                    return
            }
            print("Unrecognized socket.io error: \(lastPacket.stringPayload)")
        }
        
        //we good?
        let events = packets.filter { $0.type == .Event }
        let validEvents = events.filter { $0.jsonPayload != nil }
        let messages = validEvents.map { LiveUpdateMessage(json: $0.jsonPayload!) }
        if messages.count > 0 {
            state.messageHandler?(messages: messages)
        }
        if !state.terminated {
            self.poll(state)
        }
    }
}

