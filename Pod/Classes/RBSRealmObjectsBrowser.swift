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
        
    }
    
    //MARK: private Methods
    
    private func stringForProperty(property:Property, object:Object) -> String{
        var propertyValue = ""
        switch property.type {
            
        case PropertyType.Int,PropertyType.Bool,PropertyType.Float,PropertyType.Double:
            propertyValue = performSelector(Selector("\(property.name)"), withObject: object) as! String
            break
        case PropertyType.String:
            propertyValue = object[property.name] as! String
            break
        case PropertyType.Any,PropertyType.Array,PropertyType.Object:
            let data = performSelector(Selector("\(property.name)"), withObject: object) as! NSData
            propertyValue = data.description
            break
            
        default:
            return ""
            break
        }
        return propertyValue
    }
    //
//    - (NSString *)stringForProperty:(RLMProperty *)aProperty inObject:(RLMObject *)object {
//        NSString *stringValue;
    //    switch (aProperty.type) {
    //        case RLMPropertyTypeInt:
    //        case RLMPropertyTypeFloat:
    //        case RLMPropertyTypeBool:
    //        case RLMPropertyTypeDouble:
    //            stringValue = [(NSNumber *)[object objectForKeyedSubscript:aProperty.name] stringValue];
    //            break;
    //        case RLMPropertyTypeString:
    //            stringValue = (NSString *)[object objectForKeyedSubscript:aProperty.name];
    //            break;
    //        case RLMPropertyTypeData:
    //        case RLMPropertyTypeAny:
    //        case RLMPropertyTypeDate:
    //        case RLMPropertyTypeObject:
    //        case RLMPropertyTypeArray:
//                stringValue = [(NSData *)[object objectForKeyedSubscript:aProperty.name] description];
    //            break;
    //    }
//        return stringValue;
//    }
}
