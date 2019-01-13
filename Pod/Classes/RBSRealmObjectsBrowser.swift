//
//  RBSRealmObjectsBrowser.swift
//  Pods
//
//  Created by Max Baumbach on 31/03/16.
//
//

import UIKit
import RealmSwift

final class RBSRealmObjectsBrowser: UIViewController, UIViewControllerPreviewingDelegate {
    private var objects: [Object]
    private var schema: ObjectSchema
    private var properties: [Property]
    private var filteredProperties: [Property]
    private var filteredObjects: [Object]
    private let cellIdentifier = "objectCell"
    private var isEditMode: Bool = false
    private var selectAll: Bool = false
    private var realm: Realm
    private var selectedObjects: [Object] = []
    private var realmView = RBSRealmBrowserView()
    
    fileprivate var searchController : UISearchController?
    
    init(objects: [Object], realm: Realm) {
        self.objects = objects
        self.realm = realm
        schema = objects[0].objectSchema
        properties = schema.properties
        filteredProperties = properties
        filteredObjects = []
        super.init(nibName: nil, bundle: nil)
        
        title = "Objects"
        let bbi = UIBarButtonItem(title: "Select", style: .plain, target: self, action: .edit)
        navigationItem.rightBarButtonItem = bbi
        let bbiPreview = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: .togglePreview)
        navigationItem.rightBarButtonItems = [bbi, bbiPreview]
        
    }
    
    public override func loadView() {
        view = realmView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupSearch()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTableView() {
        realmView.tableView.delegate = self
        realmView.tableView.dataSource = self
        realmView.tableView.tableFooterView = UIView()
        realmView.tableView.register(RBSRealmObjectBrowserCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 9.0, *) {
            switch traitCollection.forceTouchCapability {
            case .available:
                registerForPreviewing(with: self, sourceView: realmView.tableView)
            case .unavailable, .unknown:
                break
            }
        }
    }
    
    // MARK: - private Methods
    
    @objc func actionToggleEdit(_ id: AnyObject) {
        realmView.tableView.allowsMultipleSelection = true
        realmView.tableView.allowsMultipleSelectionDuringEditing = true
        isEditMode.toggle()
        if !isEditMode {
            if selectAll {
                deleteAllObjects()
            } else {
                deleteObjects()
                let result:Results<DynamicObject> =  realm.dynamicObjects(schema.className)
                objects = Array(result)
                let indexSet = IndexSet(integer: 0)
                realmView.tableView.reloadSections(indexSet, with: .top)
            }
            
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem?.title = "Select"
        } else {
            navigationItem.rightBarButtonItem?.title = "Delete"
            let bbi = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: .selectAll)
            navigationItem.leftBarButtonItem = bbi
        }
    }
    @objc func actionSelectAll(_ id: AnyObject) {
        selectAll.toggle()
        if selectAll {
            self.navigationItem.leftBarButtonItem?.title = "Unselect all"
        } else {
            selectedObjects.removeAll()
            self.navigationItem.leftBarButtonItem?.title = "Select all"
        }
        realmView.tableView.reloadData()
    }
    
    @objc func actionTogglePreview(_ id: AnyObject) {
        
    }
    
    private func deleteAllObjects() {
        if objects.isNonEmpty {
            do {
                try realm.write {
                    realm.delete(data())
                    objects = []
                    realmView.tableView.reloadData()
                }
            } catch {
                print("Couldn't delete all realm objects.")
            }
        }
    }
    
    private func deleteObjects() {
        if selectedObjects.isNonEmpty {
            do {
                try realm.write {
                    realm.delete(selectedObjects)
                    selectedObjects = []
                }
            } catch {
                print("Could not perform deletion. Error \(error)")
            }
            
        }
    }
    
    // MARK: - UIViewControllerPreviewingDelegate
    
    @available(iOS 9.0, *)
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                                  viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = realmView.tableView.indexPathForRow(at:location) else { return nil }
        guard let cell = realmView.tableView.cellForRow(at:indexPath) else { return nil }
        
        let detailVC =  RBSRealmPropertyBrowser(object: data()[indexPath.row], realm: realm)
        detailVC.preferredContentSize = CGSize(width: 0.0, height: 300.0)
        previewingContext.sourceRect = cell.frame
        
        return detailVC
    }
    
    @available(iOS 9.0, *)
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                                  commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

internal extension Selector {
    static let selectAll = #selector(RBSRealmObjectsBrowser.actionSelectAll(_:))
    static let togglePreview = #selector(RBSRealmObjectsBrowser.actionTogglePreview(_:))
    static let edit = #selector(RBSRealmObjectsBrowser.actionToggleEdit(_:))
}

extension RBSRealmObjectsBrowser: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditMode && !selectAll {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
                cell.tintColor = RealmStyle.tintColor
            }
            selectedObjects.append(data()[indexPath.row])
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            let viewController = RBSRealmPropertyBrowser(object: data()[indexPath.row], realm: realm)
            
            if let searchController = searchController {
                if searchController.isActive {
                    searchController.dismiss(animated: true) { [weak self] in
                        self?.navigationController?.pushViewController(viewController, animated: true)
                    }
                } else {
                    navigationController?.pushViewController(viewController, animated: true)
                }
            } else {
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isEditMode {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            var index = 0
            for object in selectedObjects {
                var hasFoundObject = false
                if object == data()[indexPath.row] {
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
    
    private func data() -> [Object] {
        if filteredObjects.isNonEmpty {
            return filteredObjects
        }
        return objects
    }
}

extension RBSRealmObjectsBrowser: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let cell = cell as? RBSRealmObjectBrowserCell {
            let object = data()[indexPath.row]
            if !object.isInvalidated {
                let detailText = filteredProperties.map { (property) -> String in
                    return "\(property.name): \(BrowserTools.stringForProperty(property, object: object))\n\n"
                    }.reduce("", +)
                if selectAll {
                    cell.accessoryType = .checkmark
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                    selectedObjects.append(data()[indexPath.row])
                } else {
                    cell.isSelected = false
                    cell.accessoryType = .none
                }
                cell.realmBrowserObjectAttributes(schema.className, detailText: detailText)
            }
            return cell
        } else {
            fatalError("Wrong cell got dequeued")
        }
    }
    public  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data().count
    }
    
    public  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension RBSRealmObjectsBrowser: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    private func setupSearch() {
        searchController = UISearchController(searchResultsController: nil)
        if let searchController = searchController {
            searchController.searchResultsUpdater = self
            searchController.searchBar.delegate = self
            searchController.delegate = self
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.definesPresentationContext = true
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.sizeToFit()
            searchController.searchBar.tintColor = .white
            searchController.searchBar.showsCancelButton = true
            if #available(iOS 11.0, *) {
                navigationItem.searchController = searchController
            } else {
                realmView.tableView.tableHeaderView = searchController.searchBar
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchForText(searchController.searchBar.text)
        if filteredObjects.isNonEmpty {
            realmView.tableView.reloadData()
        }
    }
    
    private func searchForText(_ searchText:String?) {
        if let searchText = searchText {
            if searchText.isNonEmpty {
                filteredObjects = objects.filter({ isIncluded(for: searchText, concerning: $0) })
            }
        }
    }
    
    private func isIncluded(for searchText: String, concerning object: Object) -> Bool {
        return object.objectSchema.properties
            .filter({ "\($0.name.lowercased()) \(String(describing: object[$0.name]).lowercased()))"
            .contains(searchText.lowercased()) }).isNonEmpty
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let searchController = searchController else { return }
        updateSearchResults(for: searchController)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredObjects = []
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.textField?.textColor = .white
    }
}
