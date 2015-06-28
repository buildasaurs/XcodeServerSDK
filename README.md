# Xcode Server SDK

[![Latest XcodeServerSDK Release](https://img.shields.io/github/release/czechboy0/XcodeServerSDK.svg)](https://github.com/czechboy0/XcodeServerSDK/releases/latest)
[![Cocoapods](https://img.shields.io/cocoapods/v/XcodeServerSDK.svg)](https://cocoapods.org/pods/XcodeServerSDK) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)<br />

[![Stars](https://img.shields.io/github/stars/czechboy0/XcodeServerSDK.svg)](https://github.com/czechboy0/XcodeServerSDK/stargazers)
[![Forks](https://img.shields.io/github/forks/czechboy0/XcodeServerSDK.svg)](https://github.com/czechboy0/XcodeServerSDK/network/members)
[![Issues](https://img.shields.io/github/issues-raw/czechboy0/XcodeServerSDK.svg)](https://github.com/czechboy0/XcodeServerSDK/issues)

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](http://en.wikipedia.org/wiki/MIT_License)
[![Blog](https://img.shields.io/badge/blog-honzadvorsky.com-green.svg)](http://honzadvorsky.com)
[![Twitter Czechboy0](https://img.shields.io/badge/twitter-czechboy0-green.svg)](http://twitter.com/czechboy0)

> Use Xcode Server's API with native Swift objects.

First brought to you in [Buildasaur](https://github.com/czechboy0/Buildasaur), now in an independent project.
This is an unofficial, community-maintained project and is not associated with Apple.

# Xcode Server Versions
| Xcode Server API | Supported? |
| :-- | :--: | :--: |
| Xcode 6 and older | :white_check_mark: up to [0.0.4](https://github.com/czechboy0/XcodeServerSDK/releases/tag/0.0.4) |
| Xcode 7 and newer | :white_check_mark: from [0.1](https://github.com/czechboy0/XcodeServerSDK/releases/tag/v0.1-beta1) |

The latest version supporting the old, undocumented Xcode 6 version of the Xcode Server API is [0.0.4](https://github.com/czechboy0/XcodeServerSDK/tree/0.0.4). All newer versions *only* support the new, first publicly documented Xcode 7 version of the API. **Xcode 7 API support is still work in progress, our first beta release is [here](https://github.com/czechboy0/XcodeServerSDK/releases/tag/v0.1-beta1).**

# Sources
The easiest way to integrate `XcodeServerSDK` into your project is with Cocoapods. Add this to your Podfile and run `pod install`.

```
pod 'XcodeServerSDK', '0.0.4'
```

If you're using Carthage you have to create a _Cartfile_ and run `carthage update` to fetch and build dependencies

```
github "czechboy0/XcodeServerSDK"
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

# Swift Versions
The latest Swift 1.2 compatible version is [0.0.4](https://github.com/czechboy0/XcodeServerSDK/tree/0.0.4), so put this exact version in your Podfile if you're targetting Swift 1.2. All newer releases will be targetting Swift 2, because we're all just so forward-thinking.

When it comes to branches, [`master`](https://github.com/czechboy0/XcodeServerSDK/tree/master) will still host the latest stable Xcode's version (Xcode 6.3.2 with Swift 1.2), until this fall when Swift 2 will come out of beta with Xcode 7. Until then, please send pull requests and contribute to the [`swift-2`](https://github.com/czechboy0/XcodeServerSDK/tree/swift-2) branch.

# Play with Playground

We're providing a Plaground in which you can easily interact with `XcodeServerSDK` and test it's functionalities without any need to create a new app. Playground target is set to be OS X (so don't use `UIKit` inside).

# Features

| Name | Official  support | `XcodeServerSDK` |
| :-- | :--: | :--: |
| Check if user can create bots | :no_entry: | :white_check_mark: |
| _List bots on server_ | :white_check_mark: | :white_check_mark: |
| _Create a new bot_ | :white_check_mark: | :white_check_mark: |
| _Retrieve a bot_ | :white_check_mark: | :white_check_mark: |
| _Update a bot’s configuration_ | :white_check_mark: | :no_entry: |
| Delete a bot | :no_entry: | :white_check_mark: |
| _Get bot's most recent integrations_ | :white_check_mark: | :white_check_mark: |
| _Enqueue a new integration_ | :white_check_mark: | :white_check_mark: |
| _List integrations on server_ | :white_check_mark: | :no_entry: |
| _Retrieve an integration by ID_ | :white_check_mark: | :no_entry: |
| Cancel integration | :no_entry: | :white_check_mark: |
| _List the commits included in an integration_ | :white_check_mark: | :no_entry: |
| _List the build issues produced by an integration_ | :white_check_mark: | :no_entry: |
| _List devices connected to server_ | :white_check_mark: | :white_check_mark: |
| _List hosted repositories on server_ | :white_check_mark: | :no_entry: |
| _Create a new hosted repository_ | :white_check_mark: | :no_entry: |
| Get supported platforms | :no_entry: | :white_check_mark: |
| Get SCM branches from Blueprint | :no_entry: | :white_check_mark: |
| Verify user can manage server | :no_entry: | :white_check_mark: |

Opertions listed in table above in _italics_ are those provided by  in Xcode. Rest of operations are just a product of reverse engineering.

# Supported Platforms

Currently [`XcodeServerSDK`][xcodeserversdk] provides frameworks for the following platforms:

| Platform | Minimum Version | Carthage | CocoaPods |
|:--:|:--:|:--:|:--:|
|OS X | 10.10| :white_check_mark: | :white_check_mark: |
|iOS | 8.0| :white_check_mark: | :white_check_mark: |
|ᴡᴀᴛᴄʜ | 2.0 | :white_check_mark: | :no_entry: * |

*: _CocoaPods still doesn't support watchOS, but its working on it. You can check progress of the issue [here][cocoapodswatchos]_
[cocoapodswatchos]:https://github.com/CocoaPods/CocoaPods/pull/3681

# Projects using XcodeServerSDK
- [Buildasaur](https://github.com/czechboy0/Buildasaur) - connect Xcode Server with GitHub Pull Requests.
- (using XcodeServerSDK too? Send a PR with a link to your project added here!)

Want to create yours but need some inspiration? Watch [this WWDC 2015 session](https://developer.apple.com/videos/wwdc/2015/?id=410) on Xcode Server!
Using hardware buttons to start integrations? Why not! The sky is the limit.

# License
[MIT](https://github.com/czechboy0/XcodeServerSDK/blob/master/LICENSE)

# Building & Testing
We use [Carthage](https://github.com/Carthage/Carthage) to pull in some dependencies for tests. If you clone this repo and want to run tests, first you have to run `carthage update --no-build` to download the necessary dependencies.

# Contributing
Create an issue or (preferably) send a pull request.
Do you just want to get involved and help out? See the issues marked as [up-for-grabs](https://github.com/czechboy0/XcodeServerSDK/labels/up-for-grabs). These are the ones just waiting for some beautiful soul like you to build/fix it. We just don't have enough bandwidth and any help is welcome :) (You'll be in the contributors list of the release if you send a PR! :fireworks:)

# Origin Story
This code has been pulled out of [Buildasaur](https://github.com/czechboy0/Buildasaur), bringing you integration of GitHub Pull Requests to Xcode Bots.

# Author
Honza Dvorsky
[honzadvorsky.com](http://honzadvorsky.com)
[@czechboy0](https://twitter.com/czechboy0)

[xcodeserversdk]:https://github.com/czechboy0/XcodeServerSDK
