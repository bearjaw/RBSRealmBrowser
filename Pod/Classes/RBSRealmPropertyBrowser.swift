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

public final class RBSRealmPropertyBrowser: UIViewController, RBSRealmPropertyCellDelegate, UITableViewDataSource, UITableViewDelegate {
    private var object: Object
    private var schema: ObjectSchema
    private var properties: [Property]
    private let cellIdentifier = "objectCell"
    private var isEditMode: Bool = false
    private var realm:Realm
    private var realmView:RBSRealmBrowserView = RBSRealmBrowserView()
    
    init(object: Object, realm: Realm) {
        self.object = object
        self.realm = realm
        schema = object.objectSchema
        properties = schema.properties
        super.init(nibName: nil, bundle: nil)
        self.title = self.schema.className
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureBarButtonItems()
    }
    
    public override func loadView() {
        view = realmView
    }
    
    private func configureTableView() {
        realmView.tableView.delegate = self
        realmView.tableView.dataSource = self
        realmView.tableView.tableFooterView = UIView()
        realmView.tableView.register(RBSRealmPropertyCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    private func configureBarButtonItems() {
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(RBSRealmPropertyBrowser.actionToggleEdit(_:)))
//        let requestButton = UIBarButtonItem(title: "POST", style: .plain, target: self, action:#selector(RBSRealmPropertyBrowser.showPostOption))
        navigationItem.rightBarButtonItems = [editButton]
    }
    
    required public init?(coder aDecoder: NSCoder) {
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
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let property = properties[indexPath.row] 
        let stringvalue = RBSTools.stringForProperty(property, object: object)
        (cell as! RBSRealmPropertyCell).cellWithAttributes(property.name, propertyValue: stringvalue, editMode:isEditMode, property:property)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:RBSRealmPropertyCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? RBSRealmPropertyCell else { return UITableViewCell() }
        cell.delegate = self
        return cell
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isEditMode {
            tableView.deselectRow(at: indexPath, animated: true)
            let property = properties[indexPath.row] 
            if property.isArray {
                let objects = fetchObjects(for: property.name)
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
        savePropertyChangesInRealm(input, property: property)
        
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
        case .linkingObjects,.object:
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
    
    private func fetchObjects(for propertyName:String) -> [Object] {
        let results = object.dynamicList(propertyName)
        var objects: [Object] = []
        for obj in results {
            objects.append(obj)
        }
        return objects
    }
    
    @objc func actionToggleEdit(_ id: UIBarButtonItem) {
        isEditMode = !isEditMode
        if isEditMode {
            id.title = "Finish"
        } else {
            id.title = "Edit"
        }
        realmView.tableView.reloadData()
    }
    
}
