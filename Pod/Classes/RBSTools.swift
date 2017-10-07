//
//  RBSTools.swift
//  Pods
//
//  Created by Max Baumbach on 03/05/2017.
//
//

import RealmSwift
import AVFoundation

class RBSTools {
    
    static let localVersion = "v0.1.9"
    
    class func stringForProperty(_ property: Property, object: Object) -> String {
        var propertyValue = ""
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
        case .array:
            let array = object.dynamicList(property.name)
            propertyValue = String.localizedStringWithFormat("%li objects  ->", array.count)
            break
        case .object:
            guard let objAsProperty = object[property.name] else {
                return ""
            }
            let obj = objAsProperty as! Object
            let schema = obj.objectSchema
            for prop in schema.properties {
                if prop.type == .string {
                    propertyValue = obj[prop.name] as! String
                }
                break
            }
            if propertyValue.count == 0 {
                propertyValue = obj.className
            }
            break
        case .any:
            let data =  object[property.name]
            propertyValue = String((data as AnyObject).description)
            break
        default:
            return ""
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
                print("no response")
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
    static func isPlayground() -> Bool {
        guard let isInPlayground = (Bundle.main.bundleIdentifier?.hasPrefix("com.apple.dt.playground")) else {
            return false
        }
        return isInPlayground;
    }
}
