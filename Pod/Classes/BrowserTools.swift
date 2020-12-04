//
//  RBSTools.swift
//  Pods
//
//  Created by Max Baumbach on 03/05/2017.
//
//

import AVFoundation
import RealmSwift

final class BrowserTools {
    
    private static let localVersion = "v0.5.0"
    
    static func stringForProperty(_ property: Property, object: Object) -> String {
        if property.isArray || property.type == .linkingObjects {
            return arrayString(for: property, object: object)
        }
        return handleSupportedTypes(for: property, object: object)
    }
    
    static func previewText(for properties: [Property], object: Object) -> String {
        properties.prefix(2).reduce(into: "") { result, property in
            result += previewText(for: property, object: object)
        }
    }
    
    static func previewText(for property: Property, object: Object) -> String {
        guard property.type != .object, property.type != .data else { return "\(property.name):\t\t Value not supported" }
        return """
        \(property.name):        \(handleSupportedTypes(for: property, object: object))
        
        """
    }
    
    static func checkForUpdates() {
        guard !isPlayground() else { return }
        let url = "https://img.shields.io/cocoapods/v/RBSRealmBrowser.svg"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request,
                                   completionHandler: { data, response, _ in
                                    guard let callback = response as? HTTPURLResponse else {
                                        return
                                    }
                                    guard let data = data, callback.statusCode == 200 else { return }
                                    let websiteData = String(data: data, encoding: .utf8)
                                    guard let gitVersion = websiteData?.contains(localVersion) else {
                                        return
                                    }
                                    if !gitVersion {
                                        print("""
                        🚀 A new version of RBSRealmBrowser is now available:
                        https://github.com/bearjaw/RBSRealmBrowser/blob/master/CHANGELOG.md
                    """)
                                    }
                                   }).resume()
    }
    
    private static func isPlayground() -> Bool {
        guard let isInPlayground = (Bundle.main.bundleIdentifier?.hasPrefix("com.apple.dt.playground")) else {
            return false
        }
        return isInPlayground
    }
    
    private static func arrayString(for property: Property, object: Object) -> String {
        if property.isArray || property.type == .linkingObjects {
            let array = object.dynamicList(property.name)
            return "\(array.count) objects ->"
        }
        return ""
    }
    
    // Disabled 
    // swiftlint:disable cyclomatic_complexity
    private static func handleSupportedTypes(for property: Property, object: Object) -> String {
        switch property.type {
        case .bool:
            if let value = object[property.name] as? Bool {
                return value.humanReadable
            }
        case .int, .float, .double:
            if let number = object[property.name] as? NSNumber {
                return number.humanReadable
            }
        case .string:
            if let string = object[property.name] as? String {
                return string
            }
        case .object:
            if let objectData = object[property.name] as? Object {
                return objectData.humanReadable
            }
            return "nil"
        case .any, .data, .linkingObjects:
            let data = object[property.name]
            return "\(data.debugDescription)"
        case .date:
            if let date = object[property.name] as? Date {
                return "\(date)"
            }
        case .objectId:
            if let id = object[property.name] as? ObjectId {
                return id.stringValue
            }
        case .decimal128:
            if let decimal = object[property.name] as? Decimal128 {
                return "\(decimal)"
            }
        default:
            return "\(object[property.name] as Any)"

        }
        return "Unsupported type"
    }
}

struct RealmStyle {
    static let tintColor = UIColor(red:0.35, green:0.34, blue:0.62, alpha:1.0)
}
