# TrueTime for Swift [![Travis CI](https://travis-ci.org/instacart/TrueTime.swift.svg?branch=master)](https://travis-ci.org/instacart/TrueTime.swift)

![TrueTime](truetime.png "TrueTime for Swift")

*Make sure to check out our counterpart too: [TrueTime](https://github.com/instacart/truetime-android), an NTP library for Android.*

NTP client for Swift. Calculate the time "now" impervious to manual changes to device clock time.

In certain applications it becomes important to get the real or "true" date and time. On most devices, if the clock has been changed manually, then an `NSDate()` instance gives you a time impacted by local settings.

Users may do this for a variety of reasons, like being in different timezones, trying to be punctual and setting their clocks 5 – 10 minutes early, etc. Your application or service may want a date that is unaffected by these changes and reliable as a source of truth. TrueTime gives you that.

## How is TrueTime calculated?

It's pretty simple actually. We make a request to an NTP server that gives us the actual time. We then establish the delta between device uptime and uptime at the time of the network response. Each time `now()` is requested subsequently, we account for that offset and return a corrected `NSDate` value.

## Usage

### Swift
```swift
import TrueTime

// At an opportune time (e.g. app start):
let client = TrueTimeClient.sharedInstance
client.start()

// You can now use this instead of NSDate():
let now = client.referenceTime?.now()

// To block waiting for fetch, use the following:
client.fetchIfNeeded { result in
    switch result {
        case let .success(referenceTime):
            let now = referenceTime.now()
        case let .failure(error):
            print("Error! \(error)")
    }
}

### Notifications

You can also listen to the `TrueTimeUpdated` notification to detect when a reference time has been fetched:

```swift
let client = TrueTimeClient.sharedInstance
let _ = NSNotificationCenter.default.addObserver(forName: .TrueTimeUpdated, object: client) { _ in
    // Now guaranteed to be non-nil.
    print("Got time: \(client.referenceTime?.now()")
}
```

## Installation Options

TrueTime is currently compatible with iOS 8 and up, macOS 10.10 and tvOS 9.

#### Swift Package Manager

You can use [Swift Package Manager](https://swift.org/package-manager/) and specify dependency in `Package.swift` by adding this:

```swift
.package(url: "https://github.com/moyoteg/TrueTime.swift.git", .upToNextMinor(from: "1.3.1"))
```

See: [Package.swift - manual](http://blog.krzyzanowskim.com/2016/08/09/package-swift-manual/)

## Notes / Tips

* Since `NSDates` are just Unix timestamps, it's safe to hold onto values returned by `ReferenceTime.now()` or persist them to disk without having to adjust them later.
* Reachability events are automatically accounted for to pause/start requests.
* UDP requests are executed in parallel, with a default limit of 5 parallel calls. If one fails, we'll retry up to 3 times by default.
* TrueTime is also [available for Android](https://github.com/instacart/truetime-android).

## Contributing

This project adheres to the Contributor Covenant [code of conduct](CODE_OF_CONDUCT.md).
By participating (including but not limited to; reporting issues, commenting on issues and contributing code) you are expected to uphold this code. Please report unacceptable behavior to  opensource@instacart.com.

## License

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

## Learn more

[![NTP](ntp.gif "Read more about the NTP protocol")](https://www.eecis.udel.edu/~mills/ntp/html/index.html)
