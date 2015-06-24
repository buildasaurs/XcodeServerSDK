//
//  ContainerExtensions.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 21/06/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

extension SequenceType {
    
    func mapThrows<T>(@noescape transform: (Self.Generator.Element) throws -> T) throws -> [T] {
        
        var out: [T] = []
        for i in self {
            out.append(try transform(i))
        }
        return out
    }
    
    func filterThrows(@noescape includeElement: (Self.Generator.Element) throws -> Bool) throws -> [Self.Generator.Element] {
        
        var out: [Self.Generator.Element] = []
        for i in self {
            if try includeElement(i) {
                out.append(i)
            }
        }
        return out
    }
}