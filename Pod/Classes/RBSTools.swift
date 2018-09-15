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
    
    private static let localVersion = "v0.2.5"
    
    class func stringForProperty(_ property: Property, object: Object) -> String {
        var propertyValue = ""
        if property.isArray || property.type == .linkingObjects {
            let array = object.dynamicList(property.name)
            propertyValue = String.localizedStringWithFormat("%li objects  ->", array.count)
        
        }else {
            switch property.type {
            case .bool:
                if object[property.name] as! Bool == false {
                    propertyValue = "false"
                } else {
                    propertyValue = "true"
                }
                break
            case .int, .float, .double:
                propertyValue = String(describing: object[property.name] as! NSNumber)
                break
            case .string:
                propertyValue = object[property.name] as! String
                break
            case .object:
                if let objAsProperty:Object = object[property.name] as? Object {
                    let schema = objAsProperty.objectSchema
                    _ = schema.properties.map{ $0.type == .string }
//                    for prop in  {
//                        if prop.type == .string {
//                            propertyValue = obj[prop.name] as! String
//                        }
//                }
                    break
                }
                if propertyValue.count == 0 {
                    guard let pv = property.objectClassName else{
                        return ""
                    }
                    propertyValue = pv
                }
                break
            case .any:
                let data =  object[property.name]
                propertyValue = String((data as AnyObject).description)
                break
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
        URLSession.shared.dataTask(with: request, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) in
            guard let callback = response else {
                return
            }
            if (callback as! HTTPURLResponse).statusCode != 200 {
                return
            }
            let websiteData = String.init(data: data!, encoding: .utf8)
            guard let gitVersion = websiteData?.contains(localVersion) else {
                return
            }
            if (!gitVersion) {
                print("A new version of RBSRealmBrowser is now available: https://github.com/bearjaw/RBSRealmBrowser/blob/master/CHANGELOG.md")
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
        return isInPlayground;
    }
}

public struct RealmStyle {
    public static let tintColor: UIColor =  UIColor(red:0.35, green:0.34, blue:0.62, alpha:1.0)
}
