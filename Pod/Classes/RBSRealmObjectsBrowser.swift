//
//  RBSRealmObjectsBrowser.swift
//  Pods
//
//  Created by Max Baumbach on 31/03/16.
//
//

import UIKit
import RealmSwift


class RBSRealmObjectsBrowser: UITableViewController, UIViewControllerPreviewingDelegate {
    
    private var objects: Array <Object>
    private var schema: ObjectSchema
    private var properties: Array <Property>
    private let cellIdentifier = "objectCell"
    private var isEditMode: Bool = false
    private var selectAll: Bool = false
    private var realm:Realm
    private var selectedObjects: Array<Object> = []
    
    init(objects: Array<Object>, realm: Realm) {
        
        self.objects = objects
        self.realm = realm
        schema = objects[0].objectSchema
        properties = schema.properties
        super.init(nibName: nil, bundle: nil)
        
        
        self.title = "Objects"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(RBSRealmObjectBrowserCell.self, forCellReuseIdentifier: cellIdentifier)
        
        let bbi = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(RBSRealmObjectsBrowser.actionToggleEdit(_:)))
        self.navigationItem.rightBarButtonItem = bbi
        let bbiPreview = UIBarButtonItem(barButtonSystemItem: .action, target: self, action:#selector(RBSRealmObjectsBrowser.actionTogglePreview(_:)) )
        self.navigationItem.rightBarButtonItems = [bbi, bbiPreview]
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 9.0, *) {
            switch traitCollection.forceTouchCapability {
            case .available:
                registerForPreviewing(with: self, sourceView: tableView)
                break
            case .unavailable:
                break
            case .unknown:
                break
            }
        }
    }
    
    //MARK: TableView Datasource & Delegate
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let object = objects[indexPath.row]
        let property = properties.first as! Property
        if !object.isInvalidated {
            let stringvalue = RBSTools.stringForProperty(property, object: object)
            if selectAll {
                cell.accessoryType = .checkmark
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                selectedObjects.append(objects[indexPath.row])
            } else {
                cell.isSelected = false
                cell.accessoryType = .none
            }
            (cell as! RBSRealmObjectBrowserCell).realmBrowserObjectAttributes(schema.className, objectsCount:String(format:"%@: %@", property.name, stringvalue ))
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        return cell
    }
    override  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditMode && !selectAll {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            selectedObjects.append(objects[indexPath.row])
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            let vc = RBSRealmPropertyBrowser(object:self.objects[indexPath.row], realm: realm)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isEditMode {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            var index = 0
            for object in selectedObjects {
                var hasFoundObject = false
                if object == objects[indexPath.row] {
                    hasFoundObject = true
                    selectedObjects.remove(at: index)
                }
                if hasFoundObject {
                    index = 0
                } else {
                    index += 1
                }
            }
        }
    }
    
    //MARK: private Methods
    
    func actionToggleEdit(_ id: AnyObject) {
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        isEditMode = !isEditMode
        if !isEditMode {
            if selectAll {
                deleteAllObjects()
            }else {
                deleteObjects()
                let result:Results<DynamicObject> =  realm.dynamicObjects(schema.className)
                objects = Array(result)
                let indexSet = IndexSet(integer: 0)
                tableView.reloadSections(indexSet, with: .top)
            }
            
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem?.title = "Select"
        } else {
            self.navigationItem.rightBarButtonItem?.title = "Delete"
            let bbi = UIBarButtonItem(title: "Select All", style: UIBarButtonItemStyle.plain, target: self, action: #selector(RBSRealmObjectsBrowser.actionSelectAll(_:)))
            self.navigationItem.leftBarButtonItem = bbi
        }
    }
    func actionSelectAll(_ id: AnyObject) {
        selectAll = !selectAll
        if selectAll {
            self.navigationItem.leftBarButtonItem?.title = "Unselect all"
        } else {
            selectedObjects.removeAll()
            self.navigationItem.leftBarButtonItem?.title = "Select all"
        }
        self.tableView.reloadData()
    }
    
    func actionTogglePreview(_ id: AnyObject) {
        
    }
    
    private func deleteAllObjects() {
        try! realm.write {
            realm.delete(objects)
        }
        objects = []
        tableView.reloadData()
        
    }
    
    private func deleteObjects() {
        if selectedObjects.count > 0 {
            try! realm.write {
                realm.delete(selectedObjects)
                selectedObjects = []
            }
        }
    }
    
    //MARK: UIViewControllerPreviewingDelegate
    
    @available(iOS 9.0, *)
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView?.indexPathForRow(at:location) else { return nil }
        
        guard let cell = tableView?.cellForRow(at:indexPath) else { return nil }
        
        let detailVC =  RBSRealmPropertyBrowser(object:self.objects[indexPath.row], realm: realm)
        detailVC.preferredContentSize = CGSize(width: 0.0, height: 300)
        previewingContext.sourceRect = cell.frame
        
        return detailVC;
    }
    
    @available(iOS 9.0, *)
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
}
