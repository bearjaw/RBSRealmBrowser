//
//  RBSRealmObjectsBrowser.swift
//  Pods
//
//  Created by Max Baumbach on 31/03/16.
//
//

import UIKit
import RealmSwift
import Realm


class RBSRealmObjectsBrowser: UITableViewController {
    
    private var objects:Array <AnyObject>
    private var properties:Array <AnyObject>
    private var cellIdentifier = "objectCell"
    
    public init(objects:Array<Object>){
        self.objects = objects
        let realm = try! Realm()
        //        let object = objects.first
        properties = realm.schema.objectSchema.first!.properties
        super.init(nibName: nil, bundle: nil)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(RBSRealmObjectBrowserCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: TableView Datasource & Delegate
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! RBSRealmObjectBrowserCell
        let object = objects[indexPath.row]
        let property = properties.first as! Property
        let stringvalue = self.stringForProperty(property, object: object as! Object)
        cell.realmBrowserObjectAttributes(object.description, objectsCount:String(format:"%@: %@",property.name, stringvalue ))
        return cell
    }
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60;
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let vc = RBSRealmBrowserObjectViewController(object:self.objects[indexPath.row] as! Object)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: private Methods
    
    private func stringForProperty(property:Property, object:Object) -> String{
        var propertyValue = ""
        switch property.type {
            
        case PropertyType.Int,PropertyType.Bool,PropertyType.Float,PropertyType.Double:
            propertyValue = String(object[property.name])
            break
        case PropertyType.String:
            propertyValue = object[property.name] as! String
            break
        case PropertyType.Any,PropertyType.Array,PropertyType.Object:
            let data = object[property.name] as! NSData
            propertyValue = data.description
            break
            
        default:
            return ""
            break
        }
        return propertyValue
        
        
    }
}
