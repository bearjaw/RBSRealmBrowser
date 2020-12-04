## RBSRealmBrowser v 0.5.0
### Breaking
- iOS 9 Support dropped 

### New
- Add support for iOS 14
- Add support for Realm 10 and later
- Display optional types
- Display super class of Objects
- Select a property to be pinned in the objects browser

### Improvements
- Clean up code
- Layout improvements

## RBSRealmBrowser v 0.4.0
### New
- Add support for iOS 13
- Add support for Dark Mode
- Layout improvements

## RBSRealmBrowser v 0.3.0
### New
- Create objects of a given type
- Add observing for realm objects 
- Add swipe to delete

### Improvements
- Use a toolbar to place common actions
- Add observation for certain properties
- Generate a preview string based on the first 2 properties
- Improve tableView cell layout

### Removed
- Search was removed in 0.3.0. Will be added in the next version again

## RBSRealmBrowser v 0.2.9

### Improvements
- Update project to Swift 5.0

## RBSRealmBrowser v 0.2.8

### Improvements
- Add a toggle to handle Booleans
- Improved edit mode layout
- Fix search bar cancel button flickering

## RBSRealmBrowser v 0.2.7
### New
- Search for specific property names or values when inspecting a List of Objects

### Improvements
- Fix array out of bounds
- Reset & refetch data after performing delete action
- UI improvements

## RBSRealmBrowser v 0.2.6
### New
- Search for specific property names or values when inspecting a List of Objects

### Improvements
- Code clean up, swiftier coding style
- Add SwiftLint
- UI improvements

## RBSRealmBrowser v 0.2.5
- minor update to use swift 4.2

## RBSRealmBrowser v 0.2.4
- minor layout improvements
- clean up
- updated readme with Swift 4.1 code
-  removed explicit Swift 4.0 support as it is 4.1 from now on by default
- New feature:  Inspect (a) specific class(es) by passing an optional String array of classNames
```swift
// only show the objects of the Person class
guard let realmBrowser = RBSRealmBrowser.realmBrowser(showing: ["Person"]) else { return }
```
A `className` `String` must match a `String` representation of a given Class. If no `String` in `[String]` matches a className in the realm schema, all objects are returned.

## RBSRealmBrowser v 0.2.3
- minor layout improvements
- clean up
- filter objects (your own models vs all)

## RBSRealmBrowser v 0.2.2
- Sort Objects crash fix
- Clean up
- iOS 11 style when available
- Updated to Swift 4.1

## RBSRealmBrowser v 0.2.1
- realm 3.0 support

## RBSRealmBrowser v 0.2.0
- multiple bug fixes
- swift 4 support

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
