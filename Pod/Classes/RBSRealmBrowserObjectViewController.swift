//
//  RBSRealmBrowserObjectViewController.swift
//  Pods
//
//  Created by Max Baumbach on 06/04/16.
//
//

import UIKit
import RealmSwift

class RBSRealmBrowserObjectViewController: UITableViewController {
    
    private var object: Object
    private var schema: ObjectSchema
    private var properties:Array <AnyObject>
    private var cellIdentifier = "objectCell"
    
    public init(object:Object){
        self.object = object
        schema = object.objectSchema
        properties = schema.properties
        
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
        let property = properties[indexPath.row] as! Property
        let stringvalue = self.stringForProperty(property, object: object as! Object)
        cell.realmBrowserObjectAttributes(property.name, objectsCount:String(format:"%@", stringvalue ))
        return cell
    }
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60;
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    //MARK: private Methods
    
    private func stringForProperty(property:Property, object:Object) -> String{
        var propertyValue = ""
        switch property.type {
            
        case PropertyType.Int,PropertyType.Bool,PropertyType.Float,PropertyType.Double:
            propertyValue = String(object[property.name] as! NSNumber)
            break
        case PropertyType.String:
            propertyValue = object[property.name] as! String
            break
        case PropertyType.Any,PropertyType.Array,PropertyType.Object:
            let data =  object[property.name]
            propertyValue = data!.description
            break
        default:
            return ""
            break
        }
        return propertyValue
        
        
    }
}
