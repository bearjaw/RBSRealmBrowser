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
    private var object: Object
    private var properties: [Property] = []
    private var filteredProperties: [Property] = []
    @objc dynamic private var isEditMode: Bool = false
    private var viewRealm: RBSRealmBrowserView = {
        let view = RBSRealmBrowserView()
        return view
    }()
    private var engine: BrowserEngine
    private var disposable: NSKeyValueObservation?
    
    // MARK: - Lifetime begin

    init(object: Object, engine: BrowserEngine) {
        self.object = object
        self.engine = engine
        properties = object.objectSchema.properties
        super.init(nibName: nil, bundle: nil)
        title =  object.objectSchema.className
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        view = viewRealm
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureBarButtonItems()
        subscribeToChanges()
        UIViewController.configureNavigationBar(navigationController)
        observeEditMode()
    }

    private func configureBarButtonItems() {
        if isEditMode {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: .actionEdit)
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: .actionEdit)
        }
        if navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: .actionDismiss)
        }
    }

    deinit {
//        NSLog("deinit \(self)")
    }
    
    // MARK: Lifetime end
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
    // Disabled
    // swiftlint:disable cyclomatic_complexity
    private func savePropertyChangesInRealm(_ newValue: String, property: Property) {
        switch property.type {
        case .bool:
            guard let propertyValue = Bool(newValue) else { return }
            engine.saveValueForProperty(value: propertyValue, propertyName: property.name, object: object)
        case .int:
            guard let propertyValue = Int(newValue) else { return }
            engine.saveValueForProperty(value: propertyValue, propertyName: property.name, object: object)
        case .float:
            guard let propertyValue = Float(newValue) else { return }
            engine.saveValueForProperty(value: propertyValue, propertyName: property.name, object: object)
        case .double:
            guard let propertyValue = Double(newValue) else { return }
            engine.saveValueForProperty(value: propertyValue, propertyName: property.name, object: object)
        case .string:
            engine.saveValueForProperty(value: newValue, propertyName: property.name, object: object)
        case .linkingObjects, .object:
            break
        default:
            break
        }
    }

    private func fetchObjects(for propertyName: String) -> [Object] {
        let results = object.dynamicList(propertyName)
        return Array(results)
    }
    
    // MARK: - Observing
    
    private func observeEditMode() {
        disposable = observe(\.isEditMode, onChange: { [unowned self] _ in
            self.configureBarButtonItems()
            self.viewRealm.tableView.reloadData()
        })
    }
    
    // MARK: - Actions

    @objc fileprivate func toggleEdit() {
        isEditMode.toggle()
    }
    
    @objc fileprivate func toggleDismiss() {
        engine.deleteObjects(objects: [object]) {
            self.dismiss(animated: true)
        }
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
                    let object = objects[0]
                    let objectsViewController = RealmObjectsBrowser(className: object.objectSchema.className, engine: engine)
                    navigationController?.pushViewController(objectsViewController, animated: true)
                }
            } else if property.type == .object {
                guard let object = object[property.name] as? Object else { return }
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
    static let actionEdit = #selector(RealmPropertyBrowser.toggleEdit)
    static let actionDismiss = #selector(RealmPropertyBrowser.toggleDismiss)
}

extension RealmPropertyBrowser: RBSRealmPropertyCellDelegate {
    func textFieldDidFinishEdit(_ input: String, property: Property) {
        savePropertyChangesInRealm(input, property: property)
    }
}
