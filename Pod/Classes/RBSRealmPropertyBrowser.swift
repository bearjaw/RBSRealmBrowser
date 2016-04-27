//
//  RBSRealmBrowserObjectViewController.swift
//  Pods
//
//  Created by Max Baumbach on 06/04/16.
//
//

import UIKit
import RealmSwift
import Realm

class RBSRealmPropertyBrowser: UITableViewController, RBSRealmPropertyCellDelegate {
    
    private var object: Object
    private var schema: ObjectSchema
    private var properties:Array <AnyObject>
    private var cellIdentifier = "objectCell"
    private var isEditing = false
    
    init(object:Object){
        self.object = object
        schema = object.objectSchema
        properties = schema.properties
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = self.schema.className
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        let bbi = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(RBSRealmPropertyBrowser.actionToggleEdit(_:)))
        self.navigationItem.rightBarButtonItem = bbi
        tableView.registerClass(RBSRealmPropertyCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: TableView Datasource & Delegate
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let property = properties[indexPath.row] as! Property
        let stringvalue = self.stringForProperty(property, object: object)
        (cell as! RBSRealmPropertyCell).cellWithAttributes(property.name, propertyValue: stringvalue, editMode:isEditing, property:property)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: cellIdentifier) as! RBSRealmPropertyCell
        }
        (cell as! RBSRealmPropertyCell).delegate = self
        return cell!
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let property = properties[indexPath.row] as! Property
        if property.type == PropertyType.Array {
            let results = object.dynamicList(property.name)
            var objects:Array<Object> = []
            for obj in results {
                objects.append(obj)
            }
            
            let objectsViewController = RBSRealmObjectsBrowser(objects: objects)
            self.navigationController?.pushViewController(objectsViewController, animated: true)
        }
        
    }
    
    func textFieldDidFinishEdit(input: String, property:Property) {
        self.savePropertyChangesInRealm(input, property: property)
        //        self.actionToggleEdit((self.navigationItem.rightBarButtonItem)!)
    }
    
    //MARK: private Methods
    
    private func savePropertyChangesInRealm(newValue:String, property:Property){
        var propertyValue:AnyObject
        let letters = NSCharacterSet.letterCharacterSet()
        switch property.type {
        case .Bool:
            propertyValue = Int(newValue)!
            let realm = try! Realm()
            try! realm.write{
                object.setValue(propertyValue, forKey: property.name)
            }
            break
        case .Int:
            let range = newValue.rangeOfCharacterFromSet(letters)
            if  range == nil {
                propertyValue = Int(newValue)!
                let realm = try! Realm()
                try! realm.write{
                    object.setValue(propertyValue, forKey: property.name)
                }
            }
            
            break
        case .Float:
            propertyValue = Float(newValue)!
            
            let realm = try! Realm()
            try! realm.write{
                object.setValue(propertyValue, forKey: property.name)
            }
            break
        case .Double:
            propertyValue = Double(newValue)!
            
            let realm = try! Realm()
            try! realm.write{
                object.setValue(propertyValue, forKey: property.name)
            }
            break
        case PropertyType.String:
            propertyValue = newValue
            
            let realm = try! Realm()
            try! realm.write{
                object.setValue(propertyValue, forKey: property.name)
            }
            break
        case PropertyType.Any,PropertyType.Array,PropertyType.Object:
            break
        default:
            break
        }
        
    }
    
    private func stringForProperty(property:Property, object:Object) -> String{
        var propertyValue = ""
        switch property.type {
        case .Bool:
            
            if object[property.name] as! Int == 0 {
                propertyValue = "false"
            }else{
                propertyValue = "true"
            }
            break
        case .Int,.Float,.Double:
            propertyValue = String(object[property.name] as! NSNumber)
            break
        case .String:
            propertyValue = object[property.name] as! String
            break
        case .Any,.Array,.Object:
            let data =  object[property.name]
            propertyValue = String(data?.description)
            break
        default:
            return ""
        }
        return propertyValue
        
        
    }
    
    func actionToggleEdit(id:AnyObject){
        isEditing = !isEditing
        if isEditing{
            (id as! UIBarButtonItem).title = "Finish"
        }else{
            (id as! UIBarButtonItem).title = "Edit"
        }
        tableView.reloadData()
    }
}
