//
//  RBSTools.swift
//  Pods
//
//  Created by Max Baumbach on 03/05/2017.
//
//

import RealmSwift
import AVFoundation

public struct RBSRequestConfig {
    public let header: [String:Any]?
    public let body: [String:Any]?
}

final class RBSTools {
    
    private static let localVersion = "v0.2.6"
    
    class func stringForProperty(_ property: Property, object: Object) -> String {
        var propertyValue = ""
        if property.isArray || property.type == .linkingObjects {
            let array = object.dynamicList(property.name)
            propertyValue = "\(array.count) objects ->"
            
        } else {
            switch property.type {
            case .bool:
                if let value = object[property.name] as? Bool {
                    propertyValue = value.humanReadable
                }
            case .int, .float, .double:
                if let number = object[property.name] as? NSNumber {
                    propertyValue = number.humanReadable
                }
            case .string:
                propertyValue = object[property.name] as! String
            case .object:
                if let objAsProperty:Object = object[property.name] as? Object {
                    let schema = objAsProperty.objectSchema
                    _ = schema.properties.map { $0.type == .string }
                    //                    for prop in  {
                    //                        if prop.type == .string {
                    //                            propertyValue = obj[prop.name] as! String
                    //                        }
                    //                }
                    break
                }
                if propertyValue.isEmpty {
                    guard let value = property.objectClassName else { return "" }
                    propertyValue = value
                }
            case .any:
                let data =  object[property.name]
                propertyValue = String((data as AnyObject).description)
            default:
                return ""
            }
        }
        return propertyValue
    }
    
    static func checkForUpdates() {
        if isPlayground() {
            return
        }
        let url = "https://img.shields.io/cocoapods/v/RBSRealmBrowser.svg"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request,
                                   completionHandler: { (data, response, _) in
                                    guard let callback = response as? HTTPURLResponse else {
                                        return
                                    }
                                    if callback.statusCode != 200 {
                                        return
                                    }
                                    let websiteData = String.init(data: data!, encoding: .utf8)
                                    guard let gitVersion = websiteData?.contains(localVersion) else {
                                        return
                                    }
                                    if (!gitVersion) {
                                        print("""
                        A new version of RBSRealmBrowser is now available:
                        https://github.com/bearjaw/RBSRealmBrowser/blob/master/CHANGELOG.md
                    """)
                                    }
        }).resume()
    }
    
    public static func postObject(object:Object, atURL URL:URL) {
        print("Worked")
    }
    
    private static func isPlayground() -> Bool {
        guard let isInPlayground = (Bundle.main.bundleIdentifier?.hasPrefix("com.apple.dt.playground")) else {
            return false
        }
        return isInPlayground
    }
}

public struct RealmStyle {
    public static let tintColor: UIColor =  UIColor(red:0.35, green:0.34, blue:0.62, alpha:1.0)
}

internal extension Collection {
    internal var isNonEmpty: Bool {
        return !isEmpty
    }
}

extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return (CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height))
    }
}

extension Bool: HumanReadable {
    var humanReadable: String {
        return self ? "true" : "false"
    }
}

extension NSNumber: HumanReadable {
    var humanReadable: String {
        return stringValue
    }
}

internal protocol HumanReadable {
    var humanReadable: String { get }
}

internal extension UIView {
    
    internal var bottomRight: CGPoint {
        return (CGPoint(x: frame.origin.x + bounds.size.width, y: frame.origin.y + bounds.size.height))
    }
}

extension PropertyType: HumanReadable {
    var humanReadable: String {
        switch self {
        case .bool:
            return "Boolean"
        case .float:
            return "Float"
        case .double:
            return "Double"
        case .string:
            return "String"
        case .int:
            return "Int"
        case .data:
            return "Data"
        case .date:
            return "Date"
        case .linkingObjects:
            return "Linking objects"
        case .object:
            return "Object"
        case .any:
            return "Any"
        }
    }
}
