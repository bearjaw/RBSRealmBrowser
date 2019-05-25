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
    
    func filterBaseModels(_ value: Bool) {
        if value {
            objectSchemas = objectSchemas.filter({
                !$0.className.hasPrefix("RLM") &&
                    !$0.className.hasPrefix("RealmSwift") })
        } else {
            fetchObjects(filter)
        }
    }
    
    func sort(ascending: Bool) {
        if ascending {
            objectSchemas.sort(by: { $0.className < $1.className })
        } else {
            objectSchemas.sort(by: { $0.className > $1.className })
        }
    }
    
    /// Fetch object schemas from realm.
    /// Optionally pass in an array of strings
    /// to filter out classes
    ///
    /// - Parameter filter: Class names as Strings. Names must match
    private func fetchObjects(_ filter: [String]?) {
        self.filter = filter
        objectSchemas = realm.schema.objectSchema
        guard let filter = filter, filter.isNonEmpty else { return }
        objectSchemas = objectSchemas.filter { filter.contains($0.className) }
    }
    
    private func firstSortableProperty(for properties: [Property]) -> String? {
        guard let property = properties.first(where: { $0.type == .string
            || $0.type == .int
            || $0.type == .bool
            || $0.type == .float
            || $0.type == .date
            || $0.type == .double }) else { return nil }
        return property.name
    }
    
    deinit {
//        NSLog("deinit \(self)")
    }
}

// MARK: - Observing
extension BrowserEngine {
    func observe(className: String, onInitial: @escaping (Results<DynamicObject>) -> Void, onUpdate: @escaping  (Results<DynamicObject>, [Int], [Int], [Int]) -> Void) {
        let results = realm.dynamicObjects(className)
        // try and find a sortable keypath & sort Results
        let objects: Results<DynamicObject>
        if let object = results.first, let keypath = firstSortableProperty(for: object.objectSchema.properties) {
            objects = results.sorted(byKeyPath: keypath)
        } else {
            // couldn't find a keypath, so we can't sort the collection
            objects = results
        }
        tokenObjects = objects.observe { updateCallback in
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
    
    func observe(object: Object, onUpdate: @escaping  () -> Void) {
        tokenObject = object.observe { updateCallback in
            switch updateCallback {
            case .change:
                onUpdate()
            case .deleted:
                break
            case .error(let error):
                fatalError("Error: Encountered error while observing collection. Was \(error)")
            }
        }
    }
}

extension BrowserEngine {
    func deleteObjects(objects: Results<DynamicObject>, completed: (() -> Void)? = nil) {
        do {
            try realm.write {
                realm.delete(objects)
            }
            guard let completed = completed else { return }
            completed()
        } catch {
            fatalError("Error: Could not access realm. \(error)")
        }
    }
    
    func deleteObjects(objects: [Object], completed: (() -> Void)? = nil) {
        do {
            try realm.write {
                realm.delete(objects)
            }
            guard let completed = completed else { return }
            completed()
        } catch {
            fatalError("Error: Could not access realm. \(error)")
        }
    }
    
    func addObjects(objects: Results<DynamicObject>, completed: (() -> Void)? = nil) {
        do {
            try realm.write {
                realm.add(objects)
            }
            guard let completed = completed else { return }
            completed()
        } catch {
            fatalError("Error: Could not access realm. \(error)")
        }
    }
    
    func addObjects(object: DynamicObject, completed: (() -> Void)? = nil) {
        do {
            try realm.write {
                realm.add(object)
            }
            guard let completed = completed else { return }
            completed()
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
    
    func saveValueForProperty(value: Any, propertyName: String, object: Object) {
        do {
            try realm.write {
                object[propertyName] = value
            }
        } catch {
            fatalError("Error: Could not commit write transaction. \(error)")
        }
    }
}
