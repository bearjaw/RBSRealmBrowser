## RBSRealmBrowser v 0.1.5
- Added possibilty to delete one or multiple objects. 
- minor fixes

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
