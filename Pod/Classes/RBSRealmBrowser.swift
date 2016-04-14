//
//  RBSRealmBrowser.swift
//  Pods
//
//  Created by Max Baumbach on 31/03/16.
//
//

import UIKit
import RealmSwift



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
        self.tableView.registerClass(RBSRealmObjectBrowserCell.self, forCellReuseIdentifier: cellIdentifier)
        for object in try! Realm().schema.objectSchema {
            objectsSchema.append(object)
        }
        let bbi = UIBarButtonItem(title: "Dismiss", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(RBSRealmBrowser.dismissBrowser))
        self.navigationItem.rightBarButtonItem = bbi
    }
    
    /**
        required initializer
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
     
     - parameter path: String
     - returns an instance of realmBrowser
     */
     public static func realmBroswerForRealmAtPath(path:String)-> AnyObject {
        let realm = try! Realm(path: path)
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
     
     - parameter tableView: UITableView
     - parameter section: Int
     
     - return number of cells per section
     */
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objectsSchema.count
    }
    
    /**
     TableView Delegate method
     
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
