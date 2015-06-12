# (unofficial) Xcode Server SDK

Use Xcode Server's API with ease. First brought to you in [Buildasaur](https://github.com/czechboy0/Buildasaur), now in an independent project.

Supports both Xcode Server with Xcode 6 and 7!

# Usage

Create the server config object with the server's URL, username and password.
```
let config = XcodeServerConfig(host: "https://127.0.0.1", user: "IRuleBots", password: "superSecr3t")
let server = XcodeServerFactory.server(config)
```

Go wild!
```
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
honzadvorsky.com
@czechboy0
