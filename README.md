# (unofficial) Xcode Server SDK

[![Stars](https://img.shields.io/github/stars/czechboy0/XcodeServerSDK.svg)](https://github.com/czechboy0/XcodeServerSDK/stargazers)
[![Forks](https://img.shields.io/github/forks/czechboy0/XcodeServerSDK.svg)](https://github.com/czechboy0/XcodeServerSDK/network/members)
[![Issues](https://img.shields.io/github/issues-raw/czechboy0/XcodeServerSDK.svg)](https://github.com/czechboy0/XcodeServerSDK/issues)
[![Latest XcodeServerSDK Release](https://img.shields.io/github/release/czechboy0/XcodeServerSDK.svg)](https://github.com/czechboy0/XcodeServerSDK/releases/latest)

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](http://en.wikipedia.org/wiki/MIT_License)
[![Blog](https://img.shields.io/badge/blog-honzadvorsky.com-green.svg)](http://honzadvorsky.com)
[![Twitter Czechboy0](https://img.shields.io/badge/twitter-czechboy0-green.svg)](http://twitter.com/czechboy0)

Use Xcode Server's API with native Swift objects. First brought to you in [Buildasaur](https://github.com/czechboy0/Buildasaur), now in an independent project.

**Supports both Xcode Server with Xcode 6 and 7!**

# Swift Versions
The latest Swift 1.2 compatible version is [0.0.4](https://github.com/czechboy0/XcodeServerSDK/tree/0.0.4), so put this exact version in your Podfile if you're targetting Swift 1.2. All newer releases will be targetting Swift 2, because we're all just so forward-thinking.

When it comes to branches, [`master`](https://github.com/czechboy0/XcodeServerSDK/tree/master) will still host the latest stable Xcode's version (Xcode 6.3.2 with Swift 1.2), until this fall when Swift 2 will come out of beta with Xcode 7. Until then, please send pull requests and contribute to the [`swift-2`](https://github.com/czechboy0/XcodeServerSDK/tree/swift-2) branch.

# Sources
The easiest way to integrate `XcodeServerSDK` into your project is with Cocoapods. Add this to your Podfile and run `pod install`.

```
pod 'XcodeServerSDK', '0.0.4'
```

# Usage

Create the server config object with the server's URL, username and password.
```swift
let config = XcodeServerConfig(host: "https://127.0.0.1", user: "IRuleBots", password: "superSecr3t")
let server = XcodeServerFactory.server(config)
```

Go wild!
```swift
server.getBots { (bots, error) -> () in
    if let error = error {
        Log.error("Oh no! \(error.description)")
        return
    }
    
    // go crazy with bots
    if let firstBot = bots?.first {
        // use the first bot...
    }
}
```

Need inspiration? Watch [this WWDC 2015 session](https://developer.apple.com/videos/wwdc/2015/?id=410) on Xcode Server!
Using hardware buttons to start integrations? Why not! The sky is the limit.

# Features

- createBot
- getBot
- deleteBot
- getBots
- getIntegrations
- postIntegration
- cancelIntegration
- getDevices
- getUserCanCreateBots

# License
[MIT](https://github.com/czechboy0/XcodeServerSDK/blob/master/LICENSE)

# Contributing
Create an issue or (preferably) send a pull request.

# Origin Story
This code has been pulled out of [Buildasaur](https://github.com/czechboy0/Buildasaur), bringing you integration of GitHub Pull Requests to Xcode Bots.

# Author
Honza Dvorsky
[honzadvorsky.com](http://honzadvorsky.com)
[@czechboy0](https://twitter.com/czechboy0)
