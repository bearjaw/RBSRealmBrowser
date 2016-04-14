# RBSRealmBrowser

[![CI Status](http://img.shields.io/travis/bearjaw/RBSRealmBrowser.svg?style=flat)](https://travis-ci.org/bearjaw/RBSRealmBrowser)
[![Version](https://img.shields.io/cocoapods/v/RBSRealmBrowser.svg?style=flat)](http://cocoapods.org/pods/RBSRealmBrowser)
[![License](https://img.shields.io/cocoapods/l/RBSRealmBrowser.svg?style=flat)](http://cocoapods.org/pods/RBSRealmBrowser)
[![Platform](https://img.shields.io/cocoapods/p/RBSRealmBrowser.svg?style=flat)](http://cocoapods.org/pods/RBSRealmBrowser)

![](./screenflow/RBSRealmBrowser.gif)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

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
Requires iOS 8.0

## Installation

RBSRealmBrowser is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RBSRealmBrowser"
```
## Future features
Implementing search for objects.
Layout improvements.

## Author

Max Baumbach, bearjaw@users.noreply.github.com

## License

RBSRealmBrowser is available under the MIT license. See the LICENSE file for more info.
