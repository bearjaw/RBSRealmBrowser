//
//  RBSRealmBrowser.swift
//  Pods
//
//  Created by Max Baumbach on 31/03/16.
//
//

import UIKit
import RealmSwift

/// RBSRealmBrowser is a lightweight database browser for RealmSwift based on
/// NBNRealmBrowser by Nerdish by Nature.
/// Use one of the three methods below to get an instance of RBSRealmBrowser and
/// use it for debug pruposes.
///
/// RBSRealmBrowser displays objects and their properties as well as their properties'
/// values.
///
/// Easily modify properties by switching into 'Edit' mode. Your changes will be commited
/// as soon as you finish editing.
/// Currently only Bool, Int, Float, Double and String are editable with an option to expand.
///
/// - warning: This browser only works with RealmSwift because Realm (Objective-C) and RealmSwift
/// 'are not interoperable and using them together is not supported.'
public class RBSRealmBrowser: UITableViewController {

    private let cellIdentifier = "RBSREALMBROWSERCELL"
    private var objectsSchema: Array<ObjectSchema> = []
    private var objectPonsos: Array<RBSObjectPonso> = []
    private var ascending = false
    private var realm:Realm

    /// Initialises the UITableViewController, sets title, registers datasource & delegates & cells
    ///
    /// - Parameter realm: a realm instance
    private init(realm: Realm) {
        self.realm = realm
        super.init(nibName: nil, bundle: nil)
        self.title = "Realm Browser"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.tableView.register(RBSRealmObjectBrowserCell.self, forCellReuseIdentifier: cellIdentifier)
        
        var mutableObjectPonsos:[RBSObjectPonso] = []
        for object in realm.schema.objectSchema {
            let objectPonso = RBSObjectPonso()
            objectPonso.objectClassName = object.className
            objectsSchema.append(object)
            mutableObjectPonsos.append(objectPonso)
        }
        objectPonsos = mutableObjectPonsos
        
        RBSTools.checkForUpdates()
        
        let bbiDismiss = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: .dismissBrowser)
        let bbiSort = UIBarButtonItem(title: "Sort A-Z", style: .plain, target: self, action: .sortObjects)
        self.navigationItem.rightBarButtonItems = [bbiDismiss, bbiSort]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Realm browser convenience method(s)

    /// Instantiate the browser using default Realm.
    ///
    /// - Returns: UINavigationController with an instance of realmBrowser
    public static func realmBrowser() -> UINavigationController? {
        do {
            let realm = try Realm()
            return self.realmBrowserForRealm(realm)
        }catch {
            print("realm init failed")
            return nil
        }
    }

    /// Instantiate the browser using a specific version of Realm.
    ///
    /// - Parameter realm: A realm custom realm
    /// - Returns: UINavigationController with an instance of realmBrowser
    public static func realmBrowserForRealm(_ realm: Realm) -> UINavigationController? {
        let rbsRealmBrowser = RBSRealmBrowser(realm:realm)
        let navigationController = UINavigationController(rootViewController: rbsRealmBrowser)
        navigationController.navigationBar.barTintColor = UIColor(red:0.35, green:0.34, blue:0.62, alpha:1.0)
        navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.isTranslucent = false
        if #available(iOS 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
             navigationController.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
        return navigationController
    }
    
    ///  Instantiate the browser using a specific version of Realm at a specific path.
    ///init(path: String) is deprecated.
    ///
    /// realmBroswerForRealmAtPath now uses the convenience initialiser init(fileURL: NSURL)
    ///
    /// - Parameter url: URL to realm file
    /// - Returns: UINavigationController with an instance of realmBrowser
    public static func realmBroswerForRealmURL(_ url: URL) -> UINavigationController? {
        do {
            let realm = try Realm(fileURL: url)
            return self.realmBrowserForRealm(realm)
        }catch {
            print("realm instance at url not found.")
            return nil
        }
    }

    /// Use this function to add the browser quick action to your shortcut
    /// items array. This is a dynamic shortcut and can be added at runtime.
    /// Use in AppDelegate
    ///
    /// - Returns: UIApplicationShortcutItem to open the realmBrowser from your homescreen
    public static func addBrowserQuickAction() -> UIApplicationShortcutItem {
        let browserShortcut = UIMutableApplicationShortcutItem(type: "org.cocoapods.bearjaw.RBSRealmBrowser.open",
                                                         localizedTitle: "Realm browser",
                                                         localizedSubtitle: "",
                                                         icon: UIApplicationShortcutIcon(type: .search),
                                                         userInfo: nil
        )
        
        return browserShortcut
    }
    
    /// Dismisses the browser
    ///
    /// - Parameter id: a UIBarButtonItem
    @objc func dismissBrowser(_ id:UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    /// Sorts the objects classes by name
    ///
    /// - Parameter id: a UIBarButtonItem
    @objc func sortObjects(_ id:UIBarButtonItem) {
        id.title = ascending == false ?"Sort Z-A": "Sort A-Z"
        ascending = !ascending
        if ascending {
            objectPonsos = objectPonsos.sorted { $0.objectClassName > $1.objectClassName }
        }else {
            objectPonsos = objectPonsos.sorted { $0.objectClassName < $1.objectClassName }
        }
        
        tableView.reloadData()
    }

    //MARK: - TableView Datasource & Delegate
    
    /// TableView DataSource method
    /// Asks the data source for a cell to insert in a particular location of the table view.
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: NSIndexPath
    /// - Returns: a UITableViewCell
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! RBSRealmObjectBrowserCell

        let objectSchema = objectPonsos[indexPath.row]
        let results = self.resultsForObjectSchemaAtIndex(indexPath.row)

        cell.realmBrowserObjectAttributes(objectSchema.objectClassName, objectsCount: String(format: "Objects in Realm = %ld", results.count))

        return cell
    }
    
    /// TableView DataSource method
    /// Tells the data source to return the number of rows in a given section of a table view.
    ///
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - section: Int
    /// - Returns: number of cells per section
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectPonsos.count
    }
    
    /// TableView Delegate method
    ///
    /// Asks the delegate for the height to use for a row in a specified location.
    /// A nonnegative floating-point value that specifies the height (in points) that row should be.
    ///
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: NSIndexPath
    /// - Returns: height of a single tableView row
    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    /// TableView Delegate method to handle cell selection
    ///
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: NSIndexPath
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let results = self.resultsForObjectSchemaAtIndex(indexPath.row)
        if results.count > 0 {
            let vc = RBSRealmObjectsBrowser(objects: results, realm: realm)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    //MARK: - private Methods
    
    /// Used to get all objects for a specific object type in Realm
    ///
    /// - Parameter index: index of the object as Int
    /// - Returns: all objects for a an Realm object at an index
    private func resultsForObjectSchemaAtIndex(_ index: Int)-> Array<Object> {
        let ponso = objectPonsos[index]
        let results = realm.dynamicObjects(ponso.objectClassName)
        return Array(results)
    }
}

// MARK: - Just a more beautiful way of working with selectors
fileprivate extension Selector {
    static let dismissBrowser = #selector(RBSRealmBrowser.dismissBrowser(_:))
    static let sortObjects = #selector(RBSRealmBrowser.sortObjects(_:))
}
