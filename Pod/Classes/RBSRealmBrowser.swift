//
//  RBSRealmBrowser.swift
//  Pods
//
//  Created by Max Baumbach on 31/03/16.
//
//

import UIKit
import RealmSwift

/// RBSRealmBrowser is a lightweight database browser for RealmSwift based on
/// NBNRealmBrowser by Nerdish by Nature.
/// Use one of the three methods below to get an instance of RBSRealmBrowser and
/// use it for debug pruposes.
///
/// RBSRealmBrowser displays objects and their properties as well as their properties'
/// values.
///
/// Easily modify properties by switching into 'Edit' mode. Your changes will be commited
/// as soon as you finish editing.
/// Currently only Bool, Int, Float, Double and String are editable with an option to expand.
///
/// - warning: This browser only works with RealmSwift because Realm (Objective-C) and RealmSwift
/// 'are not interoperable and using them together is not supported.'
public final class RBSRealmBrowser: UIViewController {

    @objc dynamic private var ascending: Bool = true
    private var viewRealm: RBSRealmBrowserView = RBSRealmBrowserView()
    private var engine: BrowserEngine
    private var disposable: NSKeyValueObservation?

    private var filterOptions: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["All", "Hide base Realm models"])
        segmentedControl.tintColor =  .white
        let attributes = [NSAttributedString.Key.foregroundColor: RealmStyle.tintColor]
        segmentedControl.setTitleTextAttributes(attributes, for: .selected)
        return segmentedControl
    }()

    /// Initialises the UITableViewController, sets title, registers datasource & delegates & cells
    ///
    /// - Parameter realm: a realm instance
    private init(realm: Realm, filteredClasses: [String]?) {
        engine = BrowserEngine(realm: realm, filter: filteredClasses)
        super.init(nibName: nil, bundle: nil)
        title = "Realm Browser"
        filterOptions.selectedSegmentIndex = 0
    }

    public override func loadView() {
        view = viewRealm
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        BrowserTools.checkForUpdates()
        observeSortSetting()
    }

    public override func viewWillTransition(to size: CGSize,
                                            with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        viewRealm.tableView.reloadData()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        NSLog("deinit \(self)")
    }

    // MARK: - Realm browser convenience method(s)

    /// Instantiate the browser using default Realm.
    ///
    /// - Returns: UINavigationController with an instance of realmBrowser
    public static func realmBrowser() -> UINavigationController? {
        return realmBrowser(showing: nil)
    }

    public static func realmBrowser(showing classes: [String]?, aURL URL: URL) -> UINavigationController? {
        do {
            let realm = try Realm(fileURL: URL)
            return realmBrowserForRealm(realm, showing: classes)
        } catch {
            NSLog("Error occured: \(error)")
            return nil
        }
    }

    public static func realmBrowser(showing classes: [String]?) -> UINavigationController? {
        do {
            let realm = try Realm()
            return realmBrowserForRealm(realm, showing: classes)
        } catch {
            NSLog("Error occured: \(error)")
            return nil
        }
    }

    /// Instantiate the browser using a specific version of Realm.
    ///
    /// - Parameter realm: A realm custom realm
    /// - Parameter filteredClasses: filter results based on classNames
    /// - Returns: UINavigationController with an instance of realmBrowser
    public static func realmBrowserForRealm(_ realm: Realm,
                                            showing classes:[String]?) -> UINavigationController? {
        let rbsRealmBrowser = RBSRealmBrowser(realm:realm, filteredClasses: classes)
        let navigationController = UINavigationController(rootViewController: rbsRealmBrowser)
        configureNavigationBar(navigationController)
        return navigationController
    }

    /// Instantiate the browser using a specific version of Realm and
    /// use no pre-filtering
    ///
    /// - Parameter realm: a realm instance
    /// - Returns: an instance of UINavigationController containing a browser
    public static func realmBrowserForRealm(_ realm: Realm ) -> UINavigationController? {
        let rbsRealmBrowser = realmBrowserForRealm(realm, showing: nil)
        return rbsRealmBrowser
    }

    ///  Instantiate the browser using a specific version of Realm at a specific path.
    ///init(path: String) is deprecated.
    ///
    /// realmBroswerForRealmAtPath now uses the convenience initialiser init(fileURL: NSURL)
    ///
    /// - Parameter url: URL to realm file
    /// - Returns: UINavigationController with an instance of realmBrowser
    public static func realmBroswerForRealmURL(_ url: URL) -> UINavigationController? {
        return realmBrowser(showing:nil, aURL: url)
    }

    /// Use this function to add the browser quick action to your shortcut
    /// items array. This is a dynamic shortcut and can be added at runtime.
    /// Use in AppDelegate
    ///
    /// - Returns: UIApplicationShortcutItem to open the realmBrowser from your homescreen
    public static func addBrowserQuickAction() -> UIApplicationShortcutItem {
        let browserShortcut = UIApplicationShortcutItem(type: "org.cocoapods.bearjaw.RBSRealmBrowser.open",
                                                        localizedTitle: "Realm browser",
                                                        localizedSubtitle: "",
                                                        icon: UIApplicationShortcutIcon(type: .search),
                                                        userInfo: nil
        )

        return browserShortcut
    }

    // MARK: - View setup

    private func configureNavigationBar() {
        navigationItem.titleView = filterOptions
        let bbiDismiss = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: .actionDismiss)
        let title = ascending ? RBSSortStyle.ascending.rawValue : RBSSortStyle.descending.rawValue
        let bbiSort = UIBarButtonItem(title: title, style: .plain, target: self, action: .actionSort)
        self.navigationItem.rightBarButtonItems = [bbiDismiss, bbiSort]
    }

    private func configureTableView() {
        viewRealm.tableView.delegate = self
        viewRealm.tableView.dataSource = self
        viewRealm.tableView.tableFooterView = UIView()
        viewRealm.tableView.register(RealmObjectBrowserCell.self,
                                            forCellReuseIdentifier: RealmObjectBrowserCell.identifier)
        filterOptions.addTarget(self, action: .actionFilter, for: .valueChanged)

    }
    
    // MARK: - Observing
    
    private func observeSortSetting() {
        disposable = observe(\.ascending) { [unowned self] newValue in
            self.engine.sort(ascending: newValue)
            self.configureNavigationBar()
            self.viewRealm.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @objc fileprivate func dismissBrowser() {
        dismiss(animated: true)
    }
    
    @objc fileprivate func toggleFilter() {
        switch filterOptions.selectedSegmentIndex {
        case 0:
            engine.filterBaseModels(false)
        case 1:
            engine.filterBaseModels(true)
        default:
            return
        }
        viewRealm.tableView.reloadData()
    }
    
    @objc fileprivate func toggleSort() {
        ascending.toggle()
    }
}

private enum RBSSortStyle: String {
    case ascending = "A-Z"
    case descending = "Z-A"
}

final class RBSRealmBrowserView: UIView {
    private(set) var tableView: UITableView
    init() {
        tableView = UITableView(frame: .zero, style: .plain)
        super.init(frame: .zero)
        tableView.backgroundColor = .white
        addSubview(tableView)
        backgroundColor = .white
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        let maxWidth: CGFloat = 414.0
        let size = CGSize(width: min(maxWidth, bounds.size.width), height: bounds.size.height)
        var xPos: CGFloat = 0.0
        if size.width >= maxWidth {
            xPos = (bounds.size.width - size.width)/2.0
        }
        let origin = (CGPoint(x: xPos, y: 0.0))
        tableView.frame = (CGRect(origin: origin, size: size))
    }
}

// MARK: - TableView Datasource & Delegate

extension RBSRealmBrowser: UITableViewDelegate {
    /// TableView Delegate method to handle cell selection
    ///
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: NSIndexPath
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let objectSchema = engine.objectSchema(at: indexPath.row)
        let viewController = RealmObjectsBrowser(className: objectSchema.className, engine: engine)
        navigationController?.pushViewController(viewController, animated: true)
    }

    /// TableView Delegate method
    ///
    /// Asks the delegate for the height to use for a row in a specified location.
    /// A nonnegative floating-point value that specifies the height (in points) that row should be.
    ///
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: NSIndexPath
    /// - Returns: height of a single tableView row
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension RBSRealmBrowser: UITableViewDataSource {
    /// TableView DataSource method
    /// Tells the data source to return the number of rows in a given section of a table view.
    ///
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - section: Int
    /// - Returns: number of cells per section
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return engine.objectSchemas.count
    }

    /// TableView DataSource method
    /// Asks the data source for a cell to insert in a particular location of the table view.
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: NSIndexPath
    /// - Returns: a UITableViewCell
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RealmObjectBrowserCell.identifier) else {
            fatalError("Error: Could dequeue tableViewCell as \(RealmObjectBrowserCell.self)")
        }
        if let cell = cell as? RealmObjectBrowserCell {
            let objectSchema = engine.objectSchema(at: indexPath.row)
            let className = engine.className(for: objectSchema)
            let count = engine.objectCount(for: objectSchema)
            cell.updateWith(title: className, detailText: "Objects in Realm = \(count)")
        }
        return cell
    }
}

private extension Selector {
    static let actionDismiss = #selector(RBSRealmBrowser.dismissBrowser)
    static let actionFilter = #selector(RBSRealmBrowser.toggleFilter)
    static let actionSort = #selector(RBSRealmBrowser.toggleSort)
}
