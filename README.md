# (unofficial) Xcode Server SDK

Use Xcode Server's API with ease. First brought to you in [Buildasaur](https://github.com/czechboy0/Buildasaur), now in an independent project.

**Supports both Xcode Server with Xcode 6 and 7!**

# Usage

Create the server config object with the server's URL, username and password.
```swift
let config = XcodeServerConfig(host: "https://127.0.0.1", apiVersion: .Xcode6, user: "IRuleBots", password: "superSecr3t")
let server = XcodeServerFactory.server(config)
```

Go wild!
```swift
server.getBots { (bots, error) -> () in
    if let error = error {
        Log.error("Oh no! \(error.description)")
        return
    }
    
    //go crazy with bots
    if let firstBot = bots?.first {
        //use the first bot...
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
MIT

# Contributing
Create an issue or (preferably) send a pull request.

# Origin Story
This code has been pulled out of [Buildasaur](https://github.com/czechboy0/Buildasaur), bringing you integration of GitHub Pull Requests to Xcode Bots.

# Author
Honza Dvorsky
[honzadvorsky.com](http://honzadvorsky.com)
[@czechboy0](https://twitter.com/czechboy0)
