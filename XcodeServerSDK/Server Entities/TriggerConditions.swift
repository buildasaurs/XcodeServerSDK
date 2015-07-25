//
//  TriggerConditions.swift
//  XcodeServerSDK
//
//  Created by Mateusz Zając on 13.06.2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public class TriggerConditions : XcodeServerEntity {
    
    public let status: Int
    public let onAnalyzerWarnings: Bool
    public let onBuildErrors: Bool
    public let onFailingTests: Bool
    public let onInternalErrors: Bool
    public let onSuccess: Bool
    public let onWarnings: Bool
    
    public init(status: Int = 2, onAnalyzerWarnings: Bool, onBuildErrors: Bool, onFailingTests: Bool, onInternalErrors: Bool, onSuccess: Bool, onWarnings: Bool) {
        
        self.status = status
        self.onAnalyzerWarnings = onAnalyzerWarnings
        self.onBuildErrors = onBuildErrors
        self.onFailingTests = onFailingTests
        self.onInternalErrors = onInternalErrors
        self.onSuccess = onSuccess
        self.onWarnings = onWarnings
        
        super.init()
    }
    
    public override func dictionarify() -> NSDictionary {
        
        let dict = NSMutableDictionary()
        
        dict["status"] = self.status
        dict["onAnalyzerWarnings"] = self.onAnalyzerWarnings
        dict["onBuildErrors"] = self.onBuildErrors
        dict["onFailingTests"] = self.onFailingTests
        dict["onInternalErrors"] = self.onInternalErrors
        dict["onSuccess"] = self.onSuccess
        dict["onWarnings"] = self.onWarnings
        
        return dict
    }
    
    public required init(json: NSDictionary) {
        
        self.status = json.optionalIntForKey("status") ?? 2
        self.onAnalyzerWarnings = json.boolForKey("onAnalyzerWarnings")
        self.onBuildErrors = json.boolForKey("onBuildErrors")
        self.onFailingTests = json.boolForKey("onFailingTests")
        self.onInternalErrors = json.boolForKey("onInternalErrors")
        self.onSuccess = json.boolForKey("onSuccess")
        self.onWarnings = json.boolForKey("onWarnings")
        
        super.init(json: json)
    }
}