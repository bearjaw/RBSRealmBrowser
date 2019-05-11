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
    private var isEditMode: Bool = false
    private var selectAll: Bool = false
    private var selectedIndexPaths: [IndexPath] = []
    private var filteredObjects: LazyFilterSequence<Results<DynamicObject>>?

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
        //        navigationItem.rightBarButtonItems = [bbi]

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

    @objc fileprivate func actionSelectAll() {
        selectAll.toggle()
        if selectAll {
            navigationItem.leftBarButtonItem?.title = "Unselect all"
        } else {
            selectedIndexPaths.removeAll()
            navigationItem.leftBarButtonItem?.title = "Select all"
        }
        viewRealm.tableView.reloadData()
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
    static let selectAll = #selector(RBSRealmObjectsBrowser.actionSelectAll)
    //    static let edit = #selector(RBSRealmObjectsBrowser.actionToggleEdit(_:))
}

extension RBSRealmObjectsBrowser: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard isEditMode else { return }
        selectedIndexPaths.append(indexPath)
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard isEditMode else { return }
        selectedIndexPaths.removeAll(where: { $0.row == indexPath.row})
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
