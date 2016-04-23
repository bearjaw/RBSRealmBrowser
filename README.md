# RBSRealmBrowser

RBSRealmBrowser is based on NBNRealmBrowser by  [Nerdish by Nature](https://github.com/nerdishbynature/NBNRealmBrowser). It's a simple lightweight browser that let's you inspect which objects currently are in your realm database on your iOS device or simulator.
Simply edit your existing object's properties' values by switching into edit mode.

Currently the following types are supported:

- Bool
- String
- Int
- Float
- Double

[![CI Status](http://img.shields.io/travis/bearjaw/RBSRealmBrowser.svg?style=flat)](https://travis-ci.org/bearjaw/RBSRealmBrowser)
[![Version](https://img.shields.io/cocoapods/v/RBSRealmBrowser.svg?style=flat)](http://cocoapods.org/pods/RBSRealmBrowser)
[![License](https://img.shields.io/cocoapods/l/RBSRealmBrowser.svg?style=flat)](http://cocoapods.org/pods/RBSRealmBrowser)
[![Platform](https://img.shields.io/cocoapods/p/RBSRealmBrowser.svg?style=flat)](http://cocoapods.org/pods/RBSRealmBrowser)

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

// get the RealmBrowser for Realm at a specific path
realmBroswerForRealmAtPath(path:String)
```

## Try

To try the example project, clone the repo, and run `pod try` from the Example directory first.

## Requirements

- Xcode 7
- iOS 8.0


## Installation

RBSRealmBrowser is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RBSRealmBrowser"
```
## Future features
Implementing search for objects.
Layout improvements.

## Documentation
Available method documentation [here](http://cocoadocs.org/docsets/RBSRealmBrowser/0.1.1/)


## Author

Max Baumbach, bearjaw@users.noreply.github.com

## License

RBSRealmBrowser is available under the MIT license. See the LICENSE file for more info.
