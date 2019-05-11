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
    private var objects: Results<DynamicObject>?
    private var properties: [Property] = []
    private var filteredProperties: [Property] = []
    private var filteredObjects: [Object] = []
    private var isEditMode: Bool = false
    private var selectAll: Bool = false
    private var selectedObjects: [Object] = []

    private lazy var viewRealm: RBSRealmBrowserView = {
        let view = RBSRealmBrowserView()
        return view
    }()
    private var engine: BrowserEngine
    private var className: String

    fileprivate var searchController : UISearchController?

    init(className: String, engine: BrowserEngine) {
        self.engine = engine
        self.className = className
        super.init(nibName: nil, bundle: nil)

        title = className
//        let bbi = UIBarButtonItem(title: "Select", style: .plain, target: self, action: .edit)
//        navigationItem.rightBarButtonItem = bbi
//        let bbiPreview = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: .togglePreview)
//        navigationItem.rightBarButtonItems = [bbi, bbiPreview]

    }

    override func loadView() {
        view = viewRealm
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupSearch()
        subscribeToCollectionChanges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewRealm.tableView.reloadData()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureTableView() {
        viewRealm.tableView.delegate = self
        viewRealm.tableView.dataSource = self
        viewRealm.tableView.tableFooterView = UIView()
        viewRealm.tableView.register(RealmObjectBrowserCell.self, forCellReuseIdentifier: RealmObjectBrowserCell.identifier)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 9.0, *) {
            switch traitCollection.forceTouchCapability {
            case .available:
                registerForPreviewing(with: self, sourceView: viewRealm.tableView)
            case .unavailable, .unknown:
                break
            @unknown default:
                break
            }
        }
    }

    // MARK: - private Methods

    private func subscribeToCollectionChanges() {
        engine.observe(className: className, onInitial: { [unowned self] objects in
            self.objects = objects
            self.viewRealm.tableView.reloadData()
        }, onUpdate: { [unowned self] _, deletions, _, _ in
            if #available(iOS 11.0, *) {
                self.viewRealm.tableView.performBatchUpdates({
                    self.viewRealm.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0)}, with: .automatic)
                })
            } else {
                self.viewRealm.tableView.beginUpdates()
                self.viewRealm.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0)}, with: .automatic)
                self.viewRealm.tableView.insertRows(at: deletions.map { IndexPath(row: $0, section: 0)}, with: .automatic)
                self.viewRealm.tableView.reloadRows(at: deletions.map { IndexPath(row: $0, section: 0)}, with: .automatic)
                self.viewRealm.tableView.endUpdates()
            }
        })
    }

    @objc func actionSelectAll(_ id: AnyObject) {
        selectAll.toggle()
        if selectAll {
            navigationItem.leftBarButtonItem?.title = "Unselect all"
        } else {
            selectedObjects.removeAll()
            navigationItem.leftBarButtonItem?.title = "Select all"
        }
        viewRealm.tableView.reloadData()
    }

    @objc func actionTogglePreview(_ id: AnyObject) {

    }

    private func deleteAllObjects() {

    }

    private func deleteObjects() {

    }

    // MARK: - UIViewControllerPreviewingDelegate

    @available(iOS 9.0, *)
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                                  viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = viewRealm.tableView.indexPathForRow(at:location) else { return nil }
        guard let cell = viewRealm.tableView.cellForRow(at:indexPath) else { return nil }
        guard let object = objects?[indexPath.row] else { return nil }
        let detailVC =  RealmPropertyBrowser(object: object, engine: engine)
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
//    static let edit = #selector(RBSRealmObjectsBrowser.actionToggleEdit(_:))
}

extension RBSRealmObjectsBrowser: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if isEditMode && !selectAll {
//            if let cell = tableView.cellForRow(at: indexPath) {
//                cell.accessoryType = .checkmark
//                cell.tintColor = RealmStyle.tintColor
//            }
//            selectedObjects.append(data()[indexPath.row])
//        } else {
//            tableView.deselectRow(at: indexPath, animated: true)
//            let viewController = RealmPropertyBrowser(object: data()[indexPath.row], engine: engine)
//
//            if let searchController = searchController {
//                if searchController.isActive {
//                    searchController.dismiss(animated: true) { [weak self] in
//                        self?.navigationController?.pushViewController(viewController, animated: true)
//                    }
//                } else {
//                    navigationController?.pushViewController(viewController, animated: true)
//                }
//            } else {
//                navigationController?.pushViewController(viewController, animated: true)
//            }
//        }
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isEditMode {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            var index = 0
            for object in selectedObjects {
                var hasFoundObject = false
                guard let objects = objects else { return }
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
}

extension RBSRealmObjectsBrowser: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dequeue = tableView.dequeueReusableCell(withIdentifier: RealmObjectBrowserCell.identifier, for: indexPath)
        guard let cell = dequeue as? RealmObjectBrowserCell else {
            fatalError("Error: Invalid cell passed. Expected \(RealmObjectBrowserCell.self). Cot: \(dequeue)")
        }
        guard let objects = objects else { fatalError("Error") }
            let object = objects[indexPath.row]
            if !object.isInvalidated {
                let detailText = filteredProperties.map { property -> String in
                    return "\(property.name): \(BrowserTools.stringForProperty(property, object: object))\n\n"
                    }.reduce("", +)
                if selectAll {
                    cell.accessoryType = .checkmark
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                    selectedObjects.append(objects[indexPath.row])
                } else {
                    cell.isSelected = false
                    cell.accessoryType = .none
                }
                cell.updateWith(title: object.objectSchema.className, detailText: detailText)
            }
            return cell
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let objects = objects else { return 0 }
        return objects.count
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
            if #available(iOS 11.0, *) {
                navigationItem.searchController = searchController
            } else {
                viewRealm.tableView.tableHeaderView = searchController.searchBar
            }
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        searchForText(searchController.searchBar.text)
        if filteredObjects.isNonEmpty {
            viewRealm.tableView.reloadData()
        }
    }

    private func searchForText(_ searchText: String?) {
        guard let searchText = searchText,
        searchText.isNonEmpty,
        let objects = objects else { return }
        filteredObjects = objects.filter({ isIncluded(for: searchText, concerning: $0) })
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
        UIView.animate(withDuration: 0.2) {
            searchController.searchBar.showsCancelButton = true
        }
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        viewRealm.tableView.reloadData()
        UIView.animate(withDuration: 0.2) {
            searchController.searchBar.showsCancelButton = false
        }
    }
}
