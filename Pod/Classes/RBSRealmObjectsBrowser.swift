//
//  RBSRealmObjectsBrowser.swift
//  Pods
//
//  Created by Max Baumbach on 31/03/16.
//
//

import UIKit
import RealmSwift


class RBSRealmObjectsBrowser: UITableViewController {
    
    private var objects:Array <AnyObject>
    private var schema:ObjectSchema
    private var properties:Array <AnyObject>
    private var cellIdentifier = "objectCell"
    
     init(objects:Array<Object>){
        
        
        for list in objects {
            self.objects = objects
        }
        
        self.objects = objects
        schema = objects[0].objectSchema
        properties = schema.properties
        super.init(nibName: nil, bundle: nil)
        
        
        self.title = "Objects"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.registerClass(RBSRealmObjectBrowserCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    //MARK: TableView Datasource & Delegate
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let object = objects[indexPath.row]
        let property = properties.first as! Property
        let stringvalue = self.stringForProperty(property, object: object as! Object)
        (cell as! RBSRealmObjectBrowserCell).realmBrowserObjectAttributes(schema.className, objectsCount:String(format:"%@: %@",property.name, stringvalue ))
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! RBSRealmObjectBrowserCell
        return cell
    }
    override  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let vc = RBSRealmPropertyBrowser(object:self.objects[indexPath.row] as! Object)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: private Methods
    
    private func stringForProperty(property:Property, object:Object) -> String{
        var propertyValue = ""
        switch property.type {
        case PropertyType.Bool:
            
            if object[property.name] as! Int == 0 {
                propertyValue = "false"
            }else{
                propertyValue = "true"
            }
            break
        case PropertyType.Int,PropertyType.Float,PropertyType.Double:
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
        }
        return propertyValue
    }
}
