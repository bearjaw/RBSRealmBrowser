//
//  RBSRealmBrowser.swift
//  Pods
//
//  Created by Max Baumbach on 31/03/16.
//
//

import UIKit
import RealmSwift

    /**

    RBSRealmBrowser is a lightweight database browser for RealmSwift based on
    NBNRealmBrowser by Nerdish by Nature.
    Use one of the three methods below to get an instance of RBSRealmBrowser and
    use it for debug pruposes.

    RBSRealmBrowser displays objects and their properties as well as their properties'
    values.

    Easily modify properties by switching into 'Edit' mode. Your changes will be commited
    as soon as you finish editing.
    Currently only Bool, Int, Float, Double and String are editable with an option to expand.

    - warning: This browser only works with RealmSwift because Realm (Objective-C) and RealmSwift
    'are not interoperable and using them together is not supported.'

    */

public class RBSRealmBrowser: UITableViewController {

    private let cellIdentifier = "RBSREALMBROWSERCELL"
    private var objectsSchema: Array<ObjectSchema> = []
    private var objectPonsos: Array<RBSObjectPonso> = []
    private var ascending = false

    /**
     Initialises the UITableViewController, sets title, registers datasource & delegates & cells

     -parameter realm: Realm
     */

    private init(realm: Realm) {
        super.init(nibName: nil, bundle: nil)

        self.title = "Realm Browser"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.tableView.register(RBSRealmObjectBrowserCell.self, forCellReuseIdentifier: cellIdentifier)
        
        var mutableObjectPonsos:[RBSObjectPonso] = []
        for object in try! Realm().schema.objectSchema {
            let objectPonso = RBSObjectPonso()
            objectPonso.objectClassName = object.className
            objectsSchema.append(object)
            mutableObjectPonsos.append(objectPonso)
        }
        objectPonsos = mutableObjectPonsos
        
        let bbiDismiss = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(RBSRealmBrowser.dismissBrowser))
        let bbiSort = UIBarButtonItem(title: "Sort A-Z", style: .plain, target: self, action: #selector(RBSRealmBrowser.sortObjects))
        self.navigationItem.rightBarButtonItems = [bbiDismiss, bbiSort]
    }

    /**
     required initializer
     Returns an object initialized from data in a given unarchiver.
     self, initialized using the data in decoder.

     - parameter coder:NSCoder
     - returns self, initialized using the data in decoder.
     */

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: Realm browser convenience method(s)

    /**
     Instantiate the browser using default Realm.

     - return an instance of realmBrowser
     */
    public static func realmBrowser() -> UINavigationController? {
        do {
            let realm = try Realm()
            return self.realmBrowserForRealm(realm)
        }catch {
            print("realm init failed")
            return nil
        }
    }

    /**
     Instantiate the browser using a specific version of Realm.

     - parameter realm: Realm
     - returns an instance of realmBrowser
     */
    public static func realmBrowserForRealm(_ realm: Realm) -> UINavigationController? {
        let rbsRealmBrowser = RBSRealmBrowser(realm:realm)
        let navigationController = UINavigationController(rootViewController: rbsRealmBrowser)
        navigationController.navigationBar.barTintColor = UIColor(red:0.35, green:0.34, blue:0.62, alpha:1.0)
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.isTranslucent = false
        return navigationController
    }

    /**
     Instantiate the browser using a specific version of Realm at a specific path.
     init(path: String) is deprecated.

     realmBroswerForRealmAtPath now uses the convenience initialiser init(fileURL: NSURL)

     - parameter url: URL
     - returns an instance of realmBrowser
     */
    public static func realmBroswerForRealmURL(_ url: URL) -> UINavigationController? {
        do {
            let realm = try Realm(fileURL: url)
            return self.realmBrowserForRealm(realm)
        }catch {
            print("realm instacne at url not found.")
            return nil
        }
    }

    
    /**
     Use this function to add the browser quick action to your shortcut
     items array. This is a dynamic shortcut and can be added at runtime.
     Use in AppDelegate
     
     - Availability: iOS 9.0
     - Returns: UIApplicationShortcutItem to open the realmBrowser from your homescreen
     */
    @available(iOS 9.0, *)
    public static func addBrowserQuickAction() -> UIApplicationShortcutItem {
        let browserShortcut = UIMutableApplicationShortcutItem(type: "org.cocoapods.bearjaw.RBSRealmBrowser.open",
                                                         localizedTitle: "Realm browser",
                                                         localizedSubtitle: "",
                                                         icon: UIApplicationShortcutIcon(type: .search),
                                                         userInfo: nil
        )
        
        return browserShortcut
    }

    /**
     Dismisses the browser
     
     - parameter id: a UIBarButtonItem
     */
    func dismissBrowser(_ id:UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    /**
     Sorts the objects classes by name
     
     - parameter id: a UIBarButtonItem
     */
    func sortObjects(_ id:UIBarButtonItem) {
        id.title = ascending == false ?"Sort Z-A": "Sort A-Z"
        ascending = !ascending
        let sortDescriptor = NSSortDescriptor(key:"objectClassName", ascending: ascending)
        let array = NSArray(array: objectPonsos)
        objectPonsos = array.sortedArray(using: [sortDescriptor]) as! [RBSObjectPonso]
        tableView.reloadData()
    }

    //MARK: TableView Datasource & Delegate

    /**
     TableView DataSource method
     Asks the data source for a cell to insert in a particular location of the table view.

     - parameter tableView: UITableView
     - parameter indexPath: NSIndexPath

     - returns a UITableViewCell
     */
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! RBSRealmObjectBrowserCell

        let objectSchema = objectPonsos[indexPath.row]
        let results = self.resultsForObjectSchemaAtIndex(indexPath.row)

        cell.realmBrowserObjectAttributes(objectSchema.objectClassName!, objectsCount: String(format: "Objects in Realm = %ld", results.count))

        return cell
    }

    /**
     TableView DataSource method
     Tells the data source to return the number of rows in a given section of a table view.

     - parameter tableView: UITableView
     - parameter section: Int

     - return number of cells per section
     */
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectPonsos.count
    }

    /**
     TableView Delegate method

     Asks the delegate for the height to use for a row in a specified location.
     A nonnegative floating-point value that specifies the height (in points) that row should be.

     - parameter tableView: UITableView
     - parameter indexPath: NSIndexPath

     - return height of a single tableView row
     */
    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    /**
     TableView Delegate method to handle cell selection

     - parameter tableView: UITableView
     - parameter indexPath: NSIndexPath

     */
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let results = self.resultsForObjectSchemaAtIndex(indexPath.row)
        if results.count > 0 {
            let vc = RBSRealmObjectsBrowser(objects: results)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    //MARK: private Methods

    /**
     Used to get all objects for a specific object type in Realm

     - parameter index: Int
     - return all objects for a an Realm object at an index
     */
    private func resultsForObjectSchemaAtIndex(_ index: Int)-> Array<Object> {
        let ponso = objectPonsos[index]
        let results = try! Realm().dynamicObjects(ponso.objectClassName!)
        return Array(results)
    }
}
