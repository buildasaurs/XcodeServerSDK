# Xcode Server SDK

[![satellite badge](https://stlt.herokuapp.com/v1/badge/czechboy0/xcodeserversdk/master)](https://github.com/czechboy0/xcodeserversdk/branches)
[![Latest XcodeServerSDK Release](https://img.shields.io/github/release/czechboy0/XcodeServerSDK.svg)](https://github.com/czechboy0/XcodeServerSDK/releases/latest)
[![CocoaPods](https://img.shields.io/cocoapods/v/XcodeServerSDK.svg)](https://cocoapods.org/pods/XcodeServerSDK) <br />

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](http://en.wikipedia.org/wiki/MIT_License)
[![Blog](https://img.shields.io/badge/blog-honzadvorsky.com-green.svg)](http://honzadvorsky.com)
[![Twitter Czechboy0](https://img.shields.io/badge/twitter-czechboy0-green.svg)](http://twitter.com/czechboy0)

> Use Xcode Server's API with native Swift objects.

First brought to you in [Buildasaur](https://github.com/czechboy0/Buildasaur), now in an independent project.
This is an unofficial, community-maintained project and is not associated with Apple. We also maintain the **[unofficial documentation](https://github.com/czechboy0/XcodeServer-API-Docs) of Xcode Server** in case you'd like to integrate using a different programming language! :wink:

# :mortar_board: Getting Started With Xcode Server 
To find out how to set up Xcode Server on your Mac in minutes (and more), check out my [series of tutorials](http://honzadvorsky.com/pages/xcode_server_tutorials/).  
To see how easy it is to integrate `XcodeServerSDK` into an iOS app, check out the [XCSDemo](https://github.com/cojoj/XCSDemo) project created by [@cojoj](https://twitter.com/cojoj).

# :signal_strength: Xcode Server API Versions
| Xcode Server API | Supported? |
| :-- | :--: | :--: |
| Xcode 7 and newer | :white_check_mark: from [0.1](https://github.com/czechboy0/XcodeServerSDK/releases/tag/v0.1) |
| Xcode 6 and older | :white_check_mark: up to [0.0.4](https://github.com/czechboy0/XcodeServerSDK/releases/tag/0.0.4) |

You'll need OS X Server of version >= 4. For Xcode 7 you need OS X >= 10.10.4.

The latest version supporting the old, undocumented Xcode 6 version of the Xcode Server API is [0.0.4](https://github.com/czechboy0/XcodeServerSDK/tree/0.0.4). All newer versions **only** support the new, first publicly documented Xcode 7 version of the API.

# :octocat: Sources
One way to integrate `XcodeServerSDK` into your project is with [CocoaPods](https://github.com/CocoaPods/CocoaPods). Add this to your Podfile (with the version being the latest released pod version: ![CocoaPods](https://img.shields.io/cocoapods/v/XcodeServerSDK.svg):

```
pod 'XcodeServerSDK'
```

# :wrench: Usage

Create the server config object with the server's URL, username and password.
```swift
do {
    let config = XcodeServerConfig(host: "https://127.0.0.1", user: "IRuleBots", password: "superSecr3t")
} catch ConfigurationErrors.NoHostProvided {
    fatalError("You haven't provided any host")
} catch ConfigurationErrors.InvalidHostProvided(let host){
    fatalError("You've provided invalid host: \(host)")
} catch ConfigurationErrors.InvalidSchemeProvided(let scheme) {
    fatalError("You've provided invalid scheme: \(scheme)")
} catch {
    fatalError("Error, not related to XcodeServerConfig; \(error)")
}
```

Instantiate `XcodeServer`.
```swift
let server = XcodeServerFactory.server(config: config)
```

Go wild!
```swift
server.getBots { bots, error in
    guard error == nil else {
        Log.error("Oh no! \(error.description)")
        return
    }
    
    // go crazy with bots
    if let firstBot = bots?.first {
        // use the first bot...
    }
}
```

# :signal_strength: Swift Versions
The latest Swift 1.2 compatible version is [0.0.4](https://github.com/czechboy0/XcodeServerSDK/tree/0.0.4), so put this exact version in your Podfile if you're targeting Swift 1.2. All newer releases will be targeting Swift 2, because we're all just so forward-thinking.

# :circus_tent: Play with Playground

We're providing a Plaground in which you can easily interact with `XcodeServerSDK` and test it's functionalities without any need to create a new app. Playground target is set to be OS X (so don't use `UIKit` inside).

# :rocket: Features

Apple has finally shipped the [**official** docs](https://developer.apple.com/library/prerelease/mac/documentation/Xcode/Conceptual/XcodeServerAPIReference/index.html#//apple_ref/doc/uid/TP40016472-CH1-SW1) for Xcode Server. They're slightly different from what has been presented on [WWDC](http://devstreaming.apple.com/videos/wwdc/2015/41097fby32x3opk/410/410_continuous_integration_and_code_coverage_in_xcode.pdf?dl=1) (slide 69).
Below is the table with _features_ described in docs - divided into categories. Last category, unofficial, is the cluster of features reverse engineered while working on `XcodesServerSDK`, so you won't find them in docs, but they're definitely in code! 😃

|Category|Description|`XcodeServerSDK` support|
|:-:|---|---|
|**Bots**|||
||Creates a new bot|✅|
||Retrieve a list of bots|✅|
||Retrieve a single bot|✅|
||Update a single bot|⛔|
||Delete a single bot|✅|
||Duplicate an existing bot|⛔|
|**Integrations**|||
||Begin an integration for the specified bot|✅|
||Retrieve a single integration|✅|
||Delete an integration|⛔|
||Cancel a integration currently being executed|✅|
||Retrieve options to perform filters, selections and calculations on all integrations for the specified bot|_partially_|
||Retrieve options to perform filters, selections and calculations on all integrations|_partially_|
||Retrieve the tests for an integration|_partially_|
||Retrieve the test information list for a given integration and device identifier|_partially_|
||Retrieve the test information list of issues for a given integration and device identifier|✅|
||Retrieve the list of files for a given integration|⛔|
|**Assets**|||
||Retrieve an asset given its relative path|⛔|
|**Code Coverage**|||
||Retrieve the Code Coverage information for a given integration|⛔|
|**Unofficial**|||
||Check if user can create bots|✅|
||List hosted repositories on server|✅|
||Create a new hosted repository|✅|
||Get supported platforms|✅|
||Get SCM branches from Blueprint|✅|
||Verify user can manage server|✅|

# :city_sunrise: Supported Platforms

Currently [`XcodeServerSDK`][xcodeserversdk] provides support for the following platforms:

| Platform | Minimum Version | CocoaPods |
|:--:|:--:|:--:|
|OS X | 10.10| :white_check_mark: |
|iOS | 8.0| :white_check_mark: |
|watchOS | 2.0 | :white_check_mark: |
|tvOS | 9.0 | :white_check_mark: |

# :tada: Projects using XcodeServerSDK
- [Buildasaur](https://github.com/czechboy0/Buildasaur) - connect Xcode Server with GitHub Pull Requests.
- (using XcodeServerSDK too? Send a PR with a link to your project added here!)

Want to create yours but need some inspiration? Watch [this WWDC 2015 session](https://developer.apple.com/videos/wwdc/2015/?id=410) on Xcode Server!
Using hardware buttons to start integrations? Why not! The sky is the limit.

# :v: License
[MIT](https://github.com/czechboy0/XcodeServerSDK/blob/master/LICENSE)

# :ship: Building & Testing
We use [CocoaPods](https://github.com/CocoaPods/CocoaPods) for dependency management. When you clone the repo, you'll need to run `pod install` to download the necessary dependencies.

# :pencil2: Contributing
Create an issue or (preferably) send a pull request.
Do you just want to get involved and help out? See the issues marked as [up-for-grabs](https://github.com/czechboy0/XcodeServerSDK/labels/up-for-grabs). These are the ones just waiting for some beautiful soul like you to build/fix it. We just don't have enough bandwidth and any help is welcome :) (You'll be in the contributors list of the release if you send a PR! :fireworks:)

# :speech_balloon: Get in touch

For things like general problems/ideas please report an **issue**, so anyone can see them and relate to them in the future. It's realy important for Open Source projects like this!
If your problem requires a deep discussion or you have a great idea and you really want to share it with someone before opening an issue you can join the official [Buildasaurs](https://github.com/buildasaurs) **Slack team**! (To do so, ping @czechboy0 on Twitter and have your e-mail address ready :e-mail:)

# :santa: Origin Story
This code has been pulled out of [Buildasaur](https://github.com/czechboy0/Buildasaur), bringing you integration of GitHub Pull Requests to Xcode Bots.

# :alien: Author
Honza Dvorsky
[honzadvorsky.com](http://honzadvorsky.com)
[@czechboy0](https://twitter.com/czechboy0)

[xcodeserversdk]:https://github.com/czechboy0/XcodeServerSDK
