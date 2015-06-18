//
//  TestUtils.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 17/06/15.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import XCTest
import XcodeServerSDK

struct StringError: ErrorType {
    
    let description: String
    let _domain: String = ""
    let _code: Int = 0
    
    init(_ description: String) {
        self.description = description
    }
}

extension XCTestCase {
    
    func loadJSONWithName(name: String) -> NSDictionary {
        
        let bundle = NSBundle(forClass: BotParsingTests.classForCoder())
        do {
            
            if let url = bundle.URLForResource(name, withExtension: "json") {
                
                let data = try NSData(contentsOfURL: url, options: NSDataReadingOptions())                
                if let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSDictionary {
                    return json
                }
                
            } else {
                throw StringError("File with name \(name) not found in the bundle")
            }
            
        } catch {
            XCTFail("Error reading file with name \(name), error: \(error)")
        }
        return NSDictionary()
    }
    
    func botInFileWithName(name: String) -> Bot {
        let json = self.loadJSONWithName(name)
        let bot = Bot(json: json)
        return bot
    }
    
    func configurationFromBotWithName(name: String) -> BotConfiguration {
        let bot = self.botInFileWithName(name)
        let configuration = bot.configuration
        return configuration
    }
}