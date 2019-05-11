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

final class RealmPropertyBrowser: UIViewController, RBSRealmPropertyCellDelegate {
    private var object: Object
//    private var schema: ObjectSchema
    private var properties: [Property] = []
    private var filteredProperties: [Property] = []
    private var isEditMode: Bool = false
    private var viewRealm: RBSRealmBrowserView = {
        let view = RBSRealmBrowserView()
        return view
    }()
    private var engine: BrowserEngine

    init(object: Object, engine: BrowserEngine) {
        self.object = object
        self.engine = engine
//        properties = schema.properties
//        filteredProperties = schema.properties.filter { filters.contains($0.name) }
        super.init(nibName: nil, bundle: nil)
//        title =  schema.className
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureBarButtonItems()
    }

    public override func loadView() {
        view = viewRealm
    }

    private func configureTableView() {
        viewRealm.tableView.delegate = self
        viewRealm.tableView.dataSource = self
        viewRealm.tableView.tableFooterView = UIView()
        viewRealm.tableView.register(RealmPropertyCell.self, forCellReuseIdentifier: RealmPropertyCell.identifier)
    }

    private func configureBarButtonItems() {
        let editButton = UIBarButtonItem(title: "Edit",
                                         style: .plain,
                                         target: self,
                                         action: .toggleEdit)
        navigationItem.rightBarButtonItems = [editButton]
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func showPostOption() {
        let postController = UIAlertController(title: "Post Object", message: nil, preferredStyle: .alert)

        postController.addTextField { aTextField in
            aTextField.placeholder = "Enter a request URL"
            aTextField.textColor = .black
        }
        let alertAction  = UIAlertAction(title: "POST", style: .default) { [unowned self] _ in
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
            BrowserTools.postObject(object: object, atURL: url)
        }
    }

    // MARK: - TableView Datasource & Delegate

    public func tableView(_ tableView: UITableView,
                          willDisplay cell: UITableViewCell,
                          forRowAt indexPath: IndexPath) {
        let property = properties[indexPath.row]
        let stringvalue = BrowserTools.stringForProperty(property, object: object)
        if let cell = cell as? RealmPropertyCell {
            cell.cellWithAttributes(propertyTitle: property.name,
                                    propertyValue: stringvalue,
                                    editMode:isEditMode,
                                    property:property)
        }
    }

    func textFieldDidFinishEdit(_ input: String, property: Property) {
        savePropertyChangesInRealm(input, property: property)
    }

    // MARK: - private methods

    private func savePropertyChangesInRealm(_ newValue: String, property: Property) {
        let letters = CharacterSet.letters

        switch property.type {
        case .bool:
            let propertyValue = Bool(newValue)!
            saveValueForProperty(value: propertyValue, propertyName: property.name)
        case .int:
            let range = newValue.rangeOfCharacter(from: letters)
            if  range == nil {
                let propertyValue = Int(newValue)!
                saveValueForProperty(value: propertyValue, propertyName: property.name)
            }
        case .float:
            if let propertyValue = Float(newValue) {
                saveValueForProperty(value: propertyValue, propertyName: property.name)
            }
        case .double:
            let propertyValue: Double = Double(newValue)!
            saveValueForProperty(value: propertyValue, propertyName: property.name)
        case .string:
            let propertyValue: String = newValue as String
            saveValueForProperty(value: propertyValue, propertyName: property.name)
        case .linkingObjects, .object:
            break
        default:
            break
        }

    }

    private func saveValueForProperty(value: Any, propertyName: String) {

    }

    private func fetchObjects(for propertyName:String) -> [Object] {
        let results = object.dynamicList(propertyName)
        return Array(results)
    }

    @objc func actionToggleEdit(_ id: UIBarButtonItem) {
        isEditMode.toggle()
        if isEditMode {
            id.title = "Finish"
        } else {
            id.title = "Edit"
        }
        viewRealm.tableView.reloadData()
    }

}

extension RealmPropertyBrowser: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isEditMode {
            tableView.deselectRow(at: indexPath, animated: true)
            let property = properties[indexPath.row]
            if property.isArray {
                let objects = fetchObjects(for: property.name)
                if objects.isNonEmpty {
                    let objectsViewController = RBSRealmObjectsBrowser(className: "", engine: engine)
                    navigationController?.pushViewController(objectsViewController, animated: true)
                }
            } else if property.type == .object {
                guard let object = object[property.name] as? Object else {
                    print("failed getting object for property")
                    return
                }
                let objectsViewController = RealmPropertyBrowser(object: object, engine: engine)
                navigationController?.pushViewController(objectsViewController, animated: true)
            }
        }

    }
}

extension RealmPropertyBrowser: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RealmPropertyCell.identifier) else {
            fatalError("Could not load a cell.")
        }
        if let cell = cell as? RealmPropertyCell {
            cell.delegate = self
        }

        return cell
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

fileprivate extension Selector {
    static let toggleEdit = #selector(RealmPropertyBrowser.actionToggleEdit(_:))
}
