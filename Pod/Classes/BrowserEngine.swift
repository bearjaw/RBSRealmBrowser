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
    private var filter: [String]?
    private var tokenObjects: NotificationToken?
    private var tokenObject: NotificationToken?
    
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

// MARK: - Observing
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
    
    func observe(object: DynamicObject, onUpdate: @escaping  () -> Void) {
        tokenObject = object.observe { updateCallback in
            switch updateCallback {
            case .change:
                onUpdate()
            case .deleted:
                dump("Object delete")
            case .error(let error):
                fatalError("Error: Encountered error while observing collection. Was \(error)")
            }
        }
    }
}

extension BrowserEngine {
    func deleteObjects(objects: Results<DynamicObject>, completed: @escaping () -> Void) {
        do {
            try realm.write {
                realm.delete(objects)
            }
        } catch {
            fatalError("Error: Could not access realm. \(error)")
        }
    }
    
    func addObjects(objects: Results<DynamicObject>, completed: @escaping () -> Void) {
        do {
            try realm.write {
                realm.add(objects)
            }
        } catch {
            fatalError("Error: Could not access realm. \(error)")
        }
    }
    
    func addObjects(object: DynamicObject, completed: @escaping () -> Void) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            fatalError("Error: Could not access realm. \(error)")
        }
    }
    
    func create(named className: String) -> DynamicObject {
        do {
            realm.beginWrite()
            let object = realm.dynamicCreate(className)
            realm.add(object)
            try realm.commitWrite()
            return object
        } catch {
            fatalError("Error: Could not commit write transaction. \(error)")
        }
    }
}
