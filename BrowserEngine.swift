//
//  BrowserEngine.swift
//  Pods-RBSRealmBrowser_Example
//
//  Created by Max Baumbach on 11/05/2019.
//

import Foundation
import RealmSwift

final class BrowserEngine {
    
    private var realm: Realm
    private(set) var objectSchemas: [ObjectSchema] = []
    private var filter: [String]? = nil
    private var tokenObjects: NotificationToken?
    
    
    init(realm: Realm, filter: [String]? = nil) {
        self.realm = realm
        self.fetchObjects(filter)
    }
    
    func update(filter: [String]? = nil) {
        fetchObjects(filter)
    }
    
    func objectSchema(at index: Int) -> ObjectSchema {
        if index >= objectSchemas.count || index < 0 {
            fatalError("Error: Invalid Index passed. Was: \(index).")
        }
        return objectSchemas[index]
    }
    
    func objectCount(for objectSchema: ObjectSchema) -> Int {
        return realm.dynamicObjects(objectSchema.className).count
    }
    
    func className(for objectSchema: ObjectSchema) -> String {
        return objectSchema.className
    }
    
    
    /// Fetch object schemas from realm.
    /// Optionally pass in an array of strings
    /// to filter out classes
    ///
    /// - Parameter filter: Class names as Strings. Names must match
    private func fetchObjects(_ filter: [String]?) {
        self.filter = filter
        objectSchemas = realm.schema.objectSchema
        if let filter = filter, filter.isNonEmpty {
            objectSchemas = objectSchemas.filter { filter.contains($0.className) }
        }
    }
}

extension BrowserEngine {
    func observe(className: String, onInitial: @escaping (Results<DynamicObject>) -> Void, onUpdate: @escaping  (Results<DynamicObject>, [Int], [Int], [Int]) -> Void) {
        
        let results = realm.dynamicObjects(className)
        tokenObjects = results.observe { updateCallback in
            switch updateCallback {
            case .initial(let collecttion):
                onInitial(collecttion)
            case .update(let collection, let deletions, let insertions, let modifications):
                onUpdate(collection, deletions, insertions, modifications)
            case .error(let error):
                fatalError("Error: Encountered error while observing collection. Was \(error)")
            }
        }
    }
}
