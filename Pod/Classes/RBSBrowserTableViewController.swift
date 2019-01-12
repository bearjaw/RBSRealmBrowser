//
//  RBSBrowserTableViewController.swift
//  RBSRealmBrowser
//
//  Created by Max Baumbach on 12/01/2019.
//

import UIKit
import RealmSwift

final class RBSBrowserTableViewController<Element>: UITableViewController where Element: Displayable {
    
    private var elements: [Element] = []
    private var realm: Realm?
    typealias SelectionHandler = (Element) -> Void
    private var selectionHandler: SelectionHandler?
    
    init(style: UITableView.Style,
         elementName: String,
         elements: [Element],
         selectionHandler: @escaping SelectionHandler) {
        super.init(style: style)
        
        title = elementName
        self.selectionHandler = selectionHandler
        self.elements = elements
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        clearsSelectionOnViewWillAppear = false
        tableView.register(RBSBrowserTableViewCell<Element>.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        let element = elements[indexPath.row]
        if let cell = cell as? RBSBrowserTableViewCell<Element> {
            cell.update(element: element)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectionHandler = selectionHandler {
            let element = elements[indexPath.row]
            selectionHandler(element)
        }
    }
}

internal protocol Displayable {
    var title: String { get set }
    var subtitle: String { get set }
    var value: String { get set }
    var type: ElementType { get set }
}

//internal enum ElementType {
//    case bool
//    case collection
//    case double
//    case int
//    case float
//    case string
//    case undefined
//}

internal enum ElementType {
    case aClass
    case property
    case undefined
}
