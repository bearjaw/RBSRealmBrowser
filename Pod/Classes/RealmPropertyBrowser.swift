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

final class RealmPropertyBrowser: UIViewController {
    private var object: DynamicObject
    private var properties: [Property] = []
    private var filteredProperties: [Property] = []
    private var isEditMode: Bool = false
    private var viewRealm: RBSRealmBrowserView = {
        let view = RBSRealmBrowserView()
        return view
    }()
    private var engine: BrowserEngine
    
    // MARK: - Lifetime begin

    init(object: DynamicObject, engine: BrowserEngine) {
        self.object = object
        self.engine = engine
        properties = object.objectSchema.properties
        super.init(nibName: nil, bundle: nil)
        title =  object.objectSchema.className
    }

    public override func loadView() {
        view = viewRealm
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureBarButtonItems()
        subscribeToChanges()
    }

    private func configureBarButtonItems() {
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: .toggleEdit)
        editButton.style = .done
        navigationItem.rightBarButtonItems = [editButton]
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifetime begin
    // MARK: - View Setup
    
    private func subscribeToChanges() {
        engine.observe(object: object) { [unowned self] in
            self.viewRealm.tableView.reloadData()
        }
    }

    private func configureTableView() {
        viewRealm.tableView.delegate = self
        viewRealm.tableView.dataSource = self
        viewRealm.tableView.tableFooterView = UIView()
        viewRealm.tableView.register(RealmPropertyCell.self, forCellReuseIdentifier: RealmPropertyCell.identifier)
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
    
    // MARK: - Actions

    @objc func actionToggleEdit(_ id: UIBarButtonItem) {
        isEditMode.toggle()
        if isEditMode {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: .toggleEdit)
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: .toggleEdit)
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
                guard let object = object[property.name] as? DynamicObject else {
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
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let property = properties[indexPath.row]
        let stringvalue = BrowserTools.stringForProperty(property, object: object)
        if let cell = cell as? RealmPropertyCell {
            cell.cellWithAttributes(propertyTitle: property.name,
                                    propertyValue: stringvalue,
                                    editMode:isEditMode,
                                    property:property)
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dequeued = tableView.dequeueReusableCell(withIdentifier: RealmPropertyCell.identifier),
            let cell = dequeued as? RealmPropertyCell else {
                fatalError("Error: Cell dequeued did not match required type \(RealmPropertyCell.self)")
        }
        cell.delegate = self
        return cell
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

private extension Selector {
    static let toggleEdit = #selector(RealmPropertyBrowser.actionToggleEdit(_:))
}

extension RealmPropertyBrowser: RBSRealmPropertyCellDelegate {
    func textFieldDidFinishEdit(_ input: String, property: Property) {
        savePropertyChangesInRealm(input, property: property)
    }
}
