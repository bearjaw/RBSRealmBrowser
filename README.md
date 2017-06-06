# RBSRealmBrowser

[![CI Status](https://travis-ci.org/bearjaw/RBSRealmBrowser.svg?branch=master)](https://travis-ci.org/bearjaw/RBSRealmBrowser)
[![Version](https://img.shields.io/cocoapods/v/RBSRealmBrowser.svg?style=flat)](http://cocoapods.org/pods/RBSRealmBrowser)
[![License](https://img.shields.io/cocoapods/l/RBSRealmBrowser.svg?style=flat)](http://cocoapods.org/pods/RBSRealmBrowser)
[![Platform](https://img.shields.io/cocoapods/p/RBSRealmBrowser.svg?style=flat)](http://cocoapods.org/pods/RBSRealmBrowser)

RBSRealmBrowser is based on NBNRealmBrowser by  [Nerdish by Nature](https://github.com/nerdishbynature/NBNRealmBrowser). It's a simple lightweight browser that let's you inspect which objects currently are in your realm database on your iOS device or simulator.
Simply edit your existing object's property values by switching into edit mode.


## Features

- quickly browse realm objects
- edit realm objects
- delete realm objects
- quick actions(start the browser from the homescreen)

For editing objects these types are currently supported:

- Bool
- String
- Int
- Float
- Double

![](./screenflow/RBSRealmBrowser.gif)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

This browser only works with RealmSwift because Realm (Objective-C) and RealmSwift 'are not interoperable and using them together is not supported.'

```swift
override func viewDidLoad() {

super.viewDidLoad()
    // add a UIBarButtonItem 

let bbi = UIBarButtonItem(title: "Open", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ViewController.openBrowser))
    self.navigationItem.rightBarButtonItem = bbi
}

func openBrowser(id:AnyObject) {

    // get an instance of RBSRealmBrowser
    let rb = RBSRealmBrowser.realmBrowser()
    self.presentViewController(rb as! UIViewController, animated: true) { 

    }
}
```

Use one of the three methods to browse your Realm database

```swift
// get the RealmBrowser for default Realm 
realmBrowser()

// get the RealmBrowser for Realm 
realmBrowserForRealm(realm:Realm)

// get the RealmBrowser for Realm at a specific url
realmBroswerForRealmAtURL(path:String)
```

## Quick actions

This latest version supports dynamic quick actions on iOS 9.0 and above.
To use the quick action add this code to your AppDelegate applicationDidFinishLaunching(:) method.

```swift
// add the realmbrowser quick action to your shortcut items array
   if #available(iOS 9.0, *) {
       application.shortcutItems = [RBSRealmBrowser.addBrowserQuickAction()]
   } else {
       // Fallback on earlier versions
   }
```

Now handle the action: 

```swift
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        // handle the quick action
        guard let rb = RBSRealmBrowser.realmBrowser() else {
            print("realm browser is nil!")
            return
        }
        let vc = (window?.rootViewController)! as UIViewController
        vc.present(rb, animated: true)
        
    }
```



## Try

To try the example project, clone the repo, and run `pod try` from the Example directory first.

## Requirements

- Xcode 8
- iOS 8.0
- Swift 3.0 for any release after 0.1.4


## Installation

RBSRealmBrowser is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RBSRealmBrowser'
```
## Future features
What's on the roadmap... 🚀
- [ ] Tests
- [ ] Be able to create objects
- [ ] Clean up
- [ ] Live reload the browser if updates happen in the background
- [x] Layout improvements
- [ ] Search 

## Documentation
Available method documentation [here](http://cocoadocs.org/docsets/RBSRealmBrowser/0.1.7/)

## RealmBrowser for Android

Realm browser by Jonas Rottmann for your Android projects available [jonasrottmann/realm-browser](https://github.com/jonasrottmann/realm-browser)

## Author

Max Baumbach, bearjaw.dev@gmail.com

## License

RBSRealmBrowser is available under the MIT license. See the LICENSE file for more info.
