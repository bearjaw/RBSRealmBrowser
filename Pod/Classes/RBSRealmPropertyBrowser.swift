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
    private var properties: [Property]
    private let cellIdentifier = "objectCell"
    private var isEditMode: Bool = false
    private var realm:Realm
    
    init(object: Object, realm: Realm) {
        self.object = object
        self.realm = realm
        schema = object.objectSchema
        properties = schema.properties
        super.init(nibName: nil, bundle: nil)
        self.title = self.schema.className
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        configureBarButtonItems()
    }
    
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(RBSRealmPropertyCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    private func configureBarButtonItems() {
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(RBSRealmPropertyBrowser.actionToggleEdit(_:)))
        let requestButton = UIBarButtonItem(title: "POST", style: .plain, target: self, action:#selector(RBSRealmPropertyBrowser.showPostOption))
        navigationItem.rightBarButtonItems = [requestButton,editButton]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func showPostOption() {
        let postController = UIAlertController(title: "Post Object", message: nil, preferredStyle: .alert)
        
        postController.addTextField { (aTextField) in
            aTextField.placeholder = "Enter a request URL"
            aTextField.textColor = .black
        }
        let alertAction  = UIAlertAction(title: "POST", style: .default) { [unowned self](_) in
            if let textField = postController.textFields?.first {
                if let text = textField.text {
                    self.handlePOST(urlString: text)
                }
            }
        }
        postController.addAction(alertAction)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        postController.addAction(cancel)
        present(postController, animated: true, completion: nil)
    }
    
    private func handlePOST(urlString: String) {
        if let url:URL = URL(string: urlString) {
            RBSTools.postObject(object: self.object, atURL: url)
        }
    }
    
    //MARK: TableView Datasource & Delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let property = properties[indexPath.row] 
        let stringvalue = RBSTools.stringForProperty(property, object: object)
        var isArray = false
        
        if property.type == .linkingObjects {
            isArray = true
        }
        (cell as! RBSRealmPropertyCell).cellWithAttributes(property.name, propertyValue: stringvalue, editMode:isEditMode, property:property, isArray:isArray)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:RBSRealmPropertyCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? RBSRealmPropertyCell else {return UITableViewCell()}
        cell.delegate = self
        cell.isUserInteractionEnabled = true
        return cell
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
            let property = properties[indexPath.row] 
            if property.isArray {
                let results = object.dynamicList(property.name)
                var objects: [Object] = []
                for obj in results {
                    objects.append(obj)
                }
                if objects.count > 0 {
                    let objectsViewController = RBSRealmObjectsBrowser(objects: objects, realm: realm)
                    navigationController?.pushViewController(objectsViewController, animated: true)
                }
            }else if property.type == .object {
                guard let obj = object[property.name] else {
                    print("failed getting object for property")
                    return
                }
                let objectsViewController = RBSRealmPropertyBrowser(object: obj as! Object, realm: realm)
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
        case .linkingObjects:
            
            break
        case .object:
            
            break
        default:
            break
        }
        
    }
    
    private func saveValueForProperty(value:Any, propertyName:String) {
        do {
            try realm.write {
            object.setValue(value, forKey: propertyName)
            }
        }catch {
            print("saving failed")
        }
    }
    
    @objc func actionToggleEdit(_ id: UIBarButtonItem) {
        isEditMode = !isEditMode
        if isEditMode {
            id.title = "Finish"
        } else {
            id.title = "Edit"
        }
        tableView.reloadData()
    }
    
}
