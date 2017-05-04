//
//  RBSTools.swift
//  Pods
//
//  Created by Max Baumbach on 03/05/2017.
//
//

import RealmSwift

class RBSTools: NSObject {
    
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
            if propertyValue.characters.count == 0 {
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
    
}
