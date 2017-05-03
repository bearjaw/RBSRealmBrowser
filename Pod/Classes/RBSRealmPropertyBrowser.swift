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
    private var properties: Array <AnyObject>
    private let cellIdentifier = "objectCell"
    private var isEditMode = false
    
    init(object: Object) {
        self.object = object
        schema = object.objectSchema
        properties = schema.properties
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = self.schema.className
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        let bbi = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(RBSRealmPropertyBrowser.actionToggleEdit(_:)))
        navigationItem.rightBarButtonItem = bbi
        tableView.register(RBSRealmPropertyCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: TableView Datasource & Delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let property = properties[indexPath.row] as! Property
        let stringvalue = RBSTools.stringForProperty(property, object: object)
        var isArray = false
        if property.type == .array {
            isArray = true
        }
        (cell as! RBSRealmPropertyCell).cellWithAttributes(property.name, propertyValue: stringvalue, editMode:isEditMode, property:property, isArray:isArray)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: cellIdentifier) as! RBSRealmPropertyCell
        }
        (cell as! RBSRealmPropertyCell).delegate = self
        cell?.isUserInteractionEnabled = true
        return cell!
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isEditMode {
            tableView.deselectRow(at: indexPath, animated: true)
            let property = properties[indexPath.row] as! Property
            if property.type == .array {
                let results = object.dynamicList(property.name)
                var objects: Array<Object> = []
                for obj in results {
                    objects.append(obj)
                }
                if objects.count > 0 {
                    let objectsViewController = RBSRealmObjectsBrowser(objects: objects)
                    navigationController?.pushViewController(objectsViewController, animated: true)
                }
            }else if property.type == .object {
                guard let obj = object[property.name] else {
                    print("failed getting object for property")
                    return
                }
                let objectsViewController = RBSRealmPropertyBrowser(object: obj as! Object)
                navigationController?.pushViewController(objectsViewController, animated: true)
            }
        }
        
    }
    
    func textFieldDidFinishEdit(_ input: String, property: Property) {
        self.savePropertyChangesInRealm(input, property: property)
        
        //        self.actionToggleEdit((self.navigationItem.rightBarButtonItem)!)
    }
    
    //MARK: private Methods
    
    private func savePropertyChangesInRealm(_ newValue: String, property: Property) {
        let letters = CharacterSet.letters

        switch property.type {
        case .bool:
            let propertyValue = Int(newValue)!
            saveValueForProperty(value: propertyValue, propertyName: property.name)
            break
        case .int:
            let range = newValue.rangeOfCharacter(from: letters)
            if  range == nil {
                let propertyValue = Int(newValue)!
                saveValueForProperty(value: propertyValue, propertyName: property.name)
            }
            break
        case .float:
            let propertyValue = Float(newValue)!
            saveValueForProperty(value: propertyValue, propertyName: property.name)
            break
        case .double:
            let propertyValue:Double = Double(newValue)!
            saveValueForProperty(value: propertyValue, propertyName: property.name)
            break
        case .string:
            let propertyValue:String = newValue as String
            saveValueForProperty(value: propertyValue, propertyName: property.name)
            break
        case .array:
            
            break
        case .object:
            
            break
        default:
            break
        }
        
    }
    
    private func saveValueForProperty(value:Any, propertyName:String) {
        do {
            let realm = try Realm()
            try realm.write {
            object.setValue(value, forKey: propertyName)
            }
        }catch {
            print("saving failed")
        }
    }
    
    func actionToggleEdit(_ id: UIBarButtonItem) {
        isEditMode = !isEditMode
        if isEditMode {
            id.title = "Finish"
        } else {
            id.title = "Edit"
        }
        tableView.reloadData()
    }
    
}
