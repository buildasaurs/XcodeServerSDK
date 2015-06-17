//
//  TestUtils.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 17/06/15.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import XCTest

extension XCTestCase {
    
    func loadJSONWithName(name: String) -> NSDictionary {
        
        let bundle = NSBundle(forClass: BotParsingTests.classForCoder())
        var error: NSError?
        if
            let url = bundle.URLForResource(name, withExtension: "json"),
            let data = NSData(contentsOfURL: url, options: NSDataReadingOptions.allZeros, error: &error),
            let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error) as? NSDictionary
        {
            return json
        } else {
            XCTFail("Error reading file with name \(name), error: \(error?.description)")
            return NSDictionary()
        }
    }
}