//
//  RBSTools.swift
//  Pods
//
//  Created by Max Baumbach on 03/05/2017.
//
//

import RealmSwift
import AVFoundation

final class BrowserTools {
    
    private static let localVersion = "v0.3.0"
    
    static func stringForProperty(_ property: Property, object: Object) -> String {
        if property.isArray || property.type == .linkingObjects {
            return arrayString(for: property, object: object)
        }
        return handleSupportedTypes(for: property, object: object)
    }
    
    static func previewText(for properties: [Property], object: Object) -> String {
        return properties.prefix(2).reduce("", { result, property -> String in
            return result + previewText(for: property, object: object)
        })
    }
    
    static func previewText(for property: Property, object: Object) -> String {
        guard property.type != .object, property.type != .data else { return "\(property.name):          Value not supported" }
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
                                    if callback.statusCode != 200 { return }
                                    let websiteData = String.init(data: data!, encoding: .utf8)
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
        case .any, .data, .linkingObjects:
            let data =  object[property.name]
            return "\(data.debugDescription)"
        case .date:
            if let date = object[property.name] as? Date {
                return "\(date)"
            }
        }
        return ""
    }
}

struct RealmStyle {
    public static let tintColor: UIColor =  UIColor(red:0.35, green:0.34, blue:0.62, alpha:1.0)
}
