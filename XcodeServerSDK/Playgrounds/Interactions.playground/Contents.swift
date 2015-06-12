//: Playground - noun: a place where people can play

import UIKit

func generateHost(var host: String) {
    
    guard let url = NSURL(string: host) else {
        print("Not a valid URL")
        return
    }
    
    if url.scheme.isEmpty {
       host.extend("https://")
    } else if url.scheme != "https" {
        print("Xcode Server generally uses https, please double check your hostname")
    }
    
    print(url)
    
//    if let url = NSURL(string: host) {
//        if let scheme = url.scheme {
//            if scheme != "https" {
//                //show a popup that it should be https!
//                Log.error("Xcode Server generally uses https, please double check your hostname")
//            }
//        } else {
//            //no scheme, add https://
//            host = "https://" + host
//        }
//        print(url, appendNewline: false)
//    }
    
    print(host, appendNewline: false)
}

generateHost("http://127.0.0.1")
