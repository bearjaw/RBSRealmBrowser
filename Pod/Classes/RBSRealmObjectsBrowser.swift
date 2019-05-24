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
    private var selectAll: Bool = false
    private var filteredObjects: LazyFilterSequence<Results<DynamicObject>>?
    private var engine: BrowserEngine
    private var className: String
    private var disposable: NSKeyValueObservation?
    
    private lazy var viewRealm: RBSRealmBrowserView = {
        let view = RBSRealmBrowserView()
        return view
    }()
    
    @objc dynamic private var isEditMode: Bool = false {
        willSet {
            viewRealm.tableView.allowsMultipleSelection = newValue
        }
    }
    
    fileprivate var searchController : UISearchController?
    
    init(className: String, engine: BrowserEngine) {
        self.engine = engine
        self.className = className
        super.init(nibName: nil, bundle: nil)
        title = className
    }
    
    override func loadView() {
        view = viewRealm
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        subscribeToCollectionChanges()
        configureBarButtonItems()
        observeEditMode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewRealm.tableView.reloadData()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View setup
    
    private func observeEditMode() {
        disposable = observe(\.isEditMode, onChange: { [unowned self] _ in
            self.configureBarButtonItems()
        })
    }
    
    private func configureBarButtonItems() {
        configureNavigationBar()
        configureToolBar(showTrash: false)
    }
    
    private func configureToolBar(showTrash: Bool) {
        let menu = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: .actionMenu)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let items: [UIBarButtonItem]
        if showTrash {
            let trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: .actionTrash)
            items = [menu, space, trash]
        } else {
            items = [menu, space]
        }
        
        setToolbarItems(items, animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
        navigationController?.toolbar.tintColor = RealmStyle.tintColor
    }
    
    private func configureNavigationBar() {
        //        setupSearch()
        let editMode: UIBarButtonItem
        if isEditMode {
            editMode = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: .actionEdit)
        } else {
            editMode = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: .actionEdit)
        }
        let addBBi = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: .actionAdd)
        editMode.style = .done
        navigationItem.rightBarButtonItems = [addBBi, editMode]
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
            }, onUpdate: { [unowned self] _, deletions, insertions, modifications in
                if #available(iOS 11.0, *) {
                    self.viewRealm.tableView.performBatchUpdates({
                        self.updateRows(deletions, insertions, modifications)
                    })
                } else {
                    self.viewRealm.tableView.beginUpdates()
                    self.updateRows(deletions, insertions, modifications)
                    self.viewRealm.tableView.endUpdates()
                }
        })
    }
    
    private func updateRows(_ deletions: [Int], _ insertions: [Int], _ modifications: [Int]) {
        self.viewRealm.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0)}, with: .automatic)
        self.viewRealm.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0)}, with: .automatic)
        self.viewRealm.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0)}, with: .automatic)
    }
    
    // MARK: - Actions
    
    private func toggleSelectAll() {
        guard objects?.isNonEmpty == true else { return }
        selectAll.toggle()
        isEditMode = true
        let last = viewRealm.tableView.numberOfRows(inSection: 0)-1
        let range = Range(uncheckedBounds: (0, last))
        let selectedRows = range.map { IndexPath(item: $0, section: 0) }
        if selectAll {
            selectedRows.forEach { self.viewRealm.tableView.selectRow(at: $0, animated: true, scrollPosition: .none) }
        } else {
            selectedRows.forEach { self.viewRealm.tableView.deselectRow(at: $0, animated: true) }
        }
    }
    
    @objc fileprivate func toggleEditMode(_ sender: UIBarButtonItem) {
        isEditMode.toggle()
        configureNavigationBar()
        configureToolBar(showTrash: true)
    }
    
    private func deleteAll() {
        guard let objects = objects else { return }
        engine.deleteObjects(objects: objects) {}
    }
    
    @objc fileprivate func toggleDelete(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionDelete = UIAlertAction(title: "Delete all", style: .destructive) { [unowned self] _ in
            self.deleteAll()
        }
        let actionDeleteSelected = UIAlertAction(title: "Delete selected", style: .destructive) { [unowned self] _ in
            
        }
        alertController.addAction(actionDelete)
        alertController.addAction(actionDeleteSelected)
        showAlert(alertController: alertController, source: self, barButtonItem: sender)
    }
    
    @objc fileprivate func toggleMenu(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionSelect = UIAlertAction(title: "Select all", style: .default) { [unowned self] _ in
            self.toggleSelectAll()
        }
        alertController.addAction(actionSelect)
        alertController.view.tintColor = .black
        showAlert(alertController: alertController, source: self, barButtonItem: sender)
    }
    
    @objc fileprivate func toggleAdd() {
        guard let objects = objects else { return }
        let object = objects[0]
        let result = engine.create(named: object.objectSchema.className)
        let propertyBrowser = RealmPropertyBrowser(object: result, engine: engine)
        present(propertyBrowser, animated: true)
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

extension RBSRealmObjectsBrowser: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        if isEditMode {
            cell.accessoryType = cell.isSelected ? .checkmark : .none
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            cell.accessoryType = .none
            guard let objects = objects else { return }
            let object = objects[indexPath.row]
            let propertyBrowser = RealmPropertyBrowser(object: object, engine: engine)
            show(propertyBrowser, sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.accessoryType = cell.isSelected ? .checkmark : .none
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
        let properties = object.objectSchema.properties
        let detail = properties.map ({ BrowserTools.stringForProperty($0, object: object) }).reduce("", +)
        cell.updateWith(title: object.objectSchema.className, detailText: detail)
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
            self.definesPresentationContext = true
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
    }
    
    private func searchForText(_ searchText: String?) {
        guard let searchText = searchText,
            searchText.isNonEmpty,
            let objects = objects else { return }
        filteredObjects = objects.filter { self.isIncluded(for: searchText, concerning: $0) }
    }
    
    private func isIncluded(for searchText: String, concerning object: DynamicObject) -> Bool {
        let isIncluded = object.objectSchema.properties
            .filter({ "\($0.name.lowercased()) \(String(describing: object[$0.name]).lowercased()))"
                .contains(searchText.lowercased()) }).isNonEmpty
        return isIncluded
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let searchController = searchController else { return }
        updateSearchResults(for: searchController)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredObjects = nil
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.textField?.textColor = .white
        UIView.animate(withDuration: 0.2) {
            searchController.searchBar.showsCancelButton = true
        }
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        filteredObjects = nil
        viewRealm.tableView.reloadData()
        UIView.animate(withDuration: 0.2) {
            searchController.searchBar.showsCancelButton = false
        }
    }
}

private extension Selector {
    static let actionEdit = #selector(RBSRealmObjectsBrowser.toggleEditMode(_:))
    static let actionMenu = #selector(RBSRealmObjectsBrowser.toggleMenu(sender:))
    static let actionTrash = #selector(RBSRealmObjectsBrowser.toggleDelete(sender:))
    static let actionAdd = #selector(RBSRealmObjectsBrowser.toggleAdd)
}
