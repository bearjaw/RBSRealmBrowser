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

    private var objects: Array <Object>
    private var schema: ObjectSchema
    private var properties: Array <AnyObject>
    private var cellIdentifier = "objectCell"
    private var isEditMode: Bool = false
    private var selectAll: Bool = false
    private var selectedObjects: Array<Object> = []

    init(objects: Array<Object>) {

        self.objects = objects
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

    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    //MARK: TableView Datasource & Delegate
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let object = objects[indexPath.row]
        let property = properties.first as! Property
        if !object.isInvalidated {
            let stringvalue = self.stringForProperty(property, object: object )
            if selectAll {
                cell.accessoryType = .checkmark
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                selectedObjects.append(objects[indexPath.row] )
            } else {
                cell.isSelected = false
                cell.accessoryType = .none
            }
            (cell as! RBSRealmObjectBrowserCell).realmBrowserObjectAttributes(schema.className, objectsCount:String(format:"%@: %@", property.name, stringvalue ))
        }


    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! RBSRealmObjectBrowserCell
        return cell
    }
    override  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing && !selectAll {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            selectedObjects.append(objects[indexPath.row])
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            let vc = RBSRealmPropertyBrowser(object:self.objects[indexPath.row])
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }


    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isEditing {
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

    private func stringForProperty(_ property: Property, object: Object) -> String {
        var propertyValue = ""
        switch property.type {
        case .bool:

            if object[property.name] as! Int == 0 {
                propertyValue = "false"
            } else {
                propertyValue = "true"
            }
            break
        case .int, .float, .double:
            propertyValue = String(object[property.name])
            break
        case .string:
            propertyValue = object[property.name] as! String
            break
        case .any, .array, .object:
            let data = object[property.name] as! NSData
            propertyValue = data.description
            break

        default:
            return ""
        }
        return propertyValue
    }

    func actionToggleEdit(_ id: AnyObject) {
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        isEditing = !isEditing
        if !isEditing {
            self.deleteObjects()
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

    private func deleteObjects() {
        let realm = try! Realm()
        if selectedObjects.count > 0 {
            var indexSelectedObjects = 0
            var index = 0
            var newObjects = objects
            for object in objects {
                var hasFoundObject = false
                if  object == selectedObjects[indexSelectedObjects] {
                    hasFoundObject = true
                    newObjects.remove(at: index)
                    print("removed an object")
                    indexSelectedObjects += 1
                }
                if indexSelectedObjects == selectedObjects.count {
                    break
                }
                if hasFoundObject {
                    index = 0
                } else {
                    index += 1
                }

            }

            objects = newObjects

            try! realm.write {
                realm.delete(selectedObjects)
                selectedObjects = []
            }
            tableView.reloadData()
        }
    }
}
