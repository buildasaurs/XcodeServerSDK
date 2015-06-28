//
//  ContainerExtensions.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 21/06/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

extension SequenceType {
    
    func mapThrows<T>(@noescape transform: (Self.Generator.Element) throws -> T) rethrows -> [T] {
        
        var out: [T] = []
        for i in self {
            out.append(try transform(i))
        }
        return out
    }
    
    func filterThrows(@noescape includeElement: (Self.Generator.Element) throws -> Bool) rethrows -> [Self.Generator.Element] {
        
        var out: [Self.Generator.Element] = []
        for i in self {
            if try includeElement(i) {
                out.append(i)
            }
        }
        return out
    }
    
    /**
    Basically `filter` that stops when it finds the first one.
    */
    func findFirst(@noescape test: (Self.Generator.Element) -> Bool) -> Self.Generator.Element? {
        
        for i in self {
            if test(i) {
                return i
            }
        }
        return nil
    }
}