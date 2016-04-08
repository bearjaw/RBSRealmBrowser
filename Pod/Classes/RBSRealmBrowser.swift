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
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: returns an instance of RBSRealmBrowser
    
    public static func realmBrowser()-> AnyObject{
        let realm = try! Realm()
        return self.realmBrowserForRealm(realm)
    }
    
    public static func realmBrowserForRealm(realm:Realm) -> AnyObject {
        let rbsRealmBrowser = RBSRealmBrowser(realm:realm)
        let navigationController = UINavigationController(rootViewController: rbsRealmBrowser)
        return navigationController
    }
    
     public static func realmBroswerForRealmAtPath(path:String)-> AnyObject {
        let realm = try! Realm(path: path)
        return self.realmBrowserForRealm(realm)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func dismissBrowser(id:AnyObject) {
            self.dismissViewControllerAnimated(true) { 
                
        }
    }
    
    //MARK: TableView Datasource & Delegate
    
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! RBSRealmObjectBrowserCell
        
        let objectSchema = self.objectsSchema[indexPath.row] as! ObjectSchema
        let results = self.resultsForObjectSChemaAtIndex(indexPath.row)
        
        cell.realmBrowserObjectAttributes(objectSchema.className, objectsCount: String(format: "Objects in Realm = %ld", results.count))
        
        return cell
    }
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objectsSchema.count
    }
    
    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60;
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
            let results = self.resultsForObjectSChemaAtIndex(indexPath.row)
        let vc = RBSRealmObjectsBrowser(objects: results)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: private Methods
    
    func resultsForObjectSChemaAtIndex(index:Int)-> Array<Object>{
        let objectSchema = self.objectsSchema[index] as! ObjectSchema
        let results = try! Realm().dynamicObjects(objectSchema.className)
        return Array(results)
    }
}
