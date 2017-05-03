## RBSRealmBrowser v 0.1.9
- fixed crash when attempting to view object with referenced object

## RBSRealmBrowser v 0.1.8
- Bug fixes
- Clean up

## RBSRealmBrowser v 0.1.7
- Bug fixes
    - fixed delete

- Layout improvements
    - added realm colors (whoop)
    - show textField borders when in edit mode
    - minor other layout improvements (like propertyValues not being displayed)

- New Features
    - added peek & pop (for properties) for supported devices
    - sort your object classes by class name

- General
    - using real world objects for pod try

## RBSRealmBrowser v 0.1.6
- Improved delete functionality 
- minor layout and logic fixes
- added quick actions

## RBSRealmBrowser v 0.1.5
- Added possibilty to delete one or multiple objects. 
- minor layout and logic fixes
- compatible with Swift 3.0
- updated to the latest realm version

## RBSRealmBrowser v 0.1.4
- Added possibilty to inspect elements contained in your objects' lists. 
- minor fixes
- Improved documentation

## RBSRealmBrowser v 0.1.3
- Added edit functionality to the browser because sometimes you want to change a value right in your debug session
- edit support for major property types
- Improved documentation

## RBSRealmBrowser v 0.1.1
- This released fix a crash which occured when no objects have yet been added to a realm database.
- Impoved general documentation.

## RBSRealmBrowser v 0.1.0

- Inital release with basic functionality. 
- The browser can be triggered using one of the three methods:

```swift
// get the RealmBrowser for default Realm 
realmBrowser()

// get the RealmBrowser for Realm 
realmBrowserForRealm(realm:Realm)

// get the RealmBrowser for Realm at a specific path
realmBroswerForRealmAtPath(path:String)
```

## Author

Max Baumbach, bearjaw@users.noreply.github.com

## License

RBSRealmBrowser is available under the MIT license. See the LICENSE file for more info.
