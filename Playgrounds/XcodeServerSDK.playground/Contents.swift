//: Playground - noun: a place where people can play

import Foundation
import XcodeServerSDK
import XCPlayground

let serverConfig = try! XcodeServerConfig(host: "https://127.0.0.1", user: "MacUser", password: "Secr3t")

let server = XcodeServerFactory.server(serverConfig)

server.getBots { (bots, error) -> () in
    
    print(error)
    print(bots)
}

XCPSetExecutionShouldContinueIndefinitely(true)
