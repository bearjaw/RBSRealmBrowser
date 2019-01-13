//
//  RBSRealmBrowser+Extensions.swift
//  RBSRealmBrowser
//
//  Created by Max Baumbach on 13/01/2019.
//

import UIKit
import RealmSwift

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

extension Object: HumanReadable {
    var humanReadable: String {
        let schema = self.objectSchema
        let propertyValue = schema.properties.reduce("\(objectSchema.className) ", { partial, property in
            return partial + " \(property.name) "
        })
        return propertyValue
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

internal extension UISearchBar {
    var textField: UITextField? {
        for subview in subviews.first?.subviews ?? [] {
            if let textField = subview as? UITextField {
                return textField
            }
        }
        return nil
    }
}
