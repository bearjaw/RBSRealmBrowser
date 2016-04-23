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
 
 - warning: Realm instancesx are not thread safe and can not be shared across
 threads or dispatch queues. You must construct a new instance on each thread you want
 to interact with the realm on. For dispatch queues, this means that you must
 call it in each block which is dispatched, as a queue is not guaranteed to run
 on a consistent thread.
 
 - warning: RBSRealmBrowser only works for swift only projects as Realm does not support
 mixed Objective-C and Swift projects.
 */

public class RBSRealmBrowser: UITableViewController {
    
    private let cellIdentifier = "RBSREALMBROWSERCELL"
    private var objectsSchema:Array<AnyObject> = []
    
    /**
     Initialises the UITableViewController, sets title, registers datasource & delegates & cells
     
     -parameter realm: Realm
     */
    
    private init(realm:Realm){
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Realm Browser"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.tableView.registerClass(RBSRealmObjectBrowserCell.self, forCellReuseIdentifier: cellIdentifier)
        for object in try! Realm().schema.objectSchema {
            objectsSchema.append(object)
        }
        let bbi = UIBarButtonItem(title: "Dismiss", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(RBSRealmBrowser.dismissBrowser))
        self.navigationItem.rightBarButtonItem = bbi
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
    public static func realmBrowser()-> AnyObject{
        let realm = try! Realm()
        return self.realmBrowserForRealm(realm)
    }
    
    /**
     Instantiate the browser using a specific version of Realm.
     
     - parameter realm: Realm
     - returns an instance of realmBrowser
     */
    public static func realmBrowserForRealm(realm:Realm) -> AnyObject {
        let rbsRealmBrowser = RBSRealmBrowser(realm:realm)
        let navigationController = UINavigationController(rootViewController: rbsRealmBrowser)
        return navigationController
    }
    
    /**
     Instantiate the browser using a specific version of Realm at a specific path.
     init(path: String) is deprecated.
     
     realmBroswerForRealmAtPath now uses the convenience initialiser init(fileURL: NSURL)
     
     - parameter path: String
     - returns an instance of realmBrowser
     */
     public static func realmBroswerForRealmAtPath(path:String)-> AnyObject {
        let realm = try! Realm(fileURL: NSURL(fileURLWithPath:path))
        return self.realmBrowserForRealm(realm)
    }
    
    /**
        Dismisses the browser
     */
    func dismissBrowser(id:AnyObject) {
            self.dismissViewControllerAnimated(true) { 
                
        }
    }
    
    //MARK: TableView Datasource & Delegate
    
    /**
     TableView DataSource method
     Asks the data source for a cell to insert in a particular location of the table view.
     
     - parameter tableView: UITableView
     - parameter indexPath: NSIndexPath
     
     - returns a UITableViewCell
     */
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! RBSRealmObjectBrowserCell
        
        let objectSchema = self.objectsSchema[indexPath.row] as! ObjectSchema
        let results = self.resultsForObjectSChemaAtIndex(indexPath.row)
        
        cell.realmBrowserObjectAttributes(objectSchema.className, objectsCount: String(format: "Objects in Realm = %ld", results.count))
        
        return cell
    }
    
    /**
     TableView DataSource method
     Tells the data source to return the number of rows in a given section of a table view.
     
     - parameter tableView: UITableView
     - parameter section: Int
     
     - return number of cells per section
     */
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objectsSchema.count
    }
    
    /**
     TableView Delegate method
     
     Asks the delegate for the height to use for a row in a specified location.
     A nonnegative floating-point value that specifies the height (in points) that row should be.
     
     - parameter tableView: UITableView
     - parameter indexPath: NSIndexPath
     
     - return height of a single tableView row
     */
    
    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60;
    }
    
    /**
     TableView Delegate method to handle cell selection
     
     - parameter tableView: UITableView
     - parameter indexPath: NSIndexPath
     
     */
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
            let results = self.resultsForObjectSChemaAtIndex(indexPath.row)
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
   private func resultsForObjectSChemaAtIndex(index:Int)-> Array<Object>{
        let objectSchema = self.objectsSchema[index] as! ObjectSchema
        let results = try! Realm().dynamicObjects(objectSchema.className)
        return Array(results)
    }
}
