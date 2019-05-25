//
//  RBSRealmBrowser+Extensions.swift
//  RBSRealmBrowser
//
//  Created by Max Baumbach on 13/01/2019.
//

import UIKit
import RealmSwift

internal extension Collection {
    var isNonEmpty: Bool {
        return !isEmpty
    }
}

internal extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return (CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height))
    }

    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        return (CGSize(width: min(lhs.width - rhs.width, 0.0), height: min(lhs.height - rhs.height, 0)))
    }

    static func > (lhs: CGSize, rhs: CGSize) -> CGSize {
        return lhs.width > rhs.width ? lhs: rhs
    }

    static func < (lhs: CGSize, rhs: CGSize) -> CGSize {
        return lhs.height > rhs.height ? lhs: rhs
    }
}

extension Bool: HumanReadable {
    var humanReadable: String {
        return self ? "true" : "false"
    }
    var rawValue: Int {
        return self ? 1 : 0
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
            if property.type == .object {
                return partial + " \(property.name): maximum depth reached)\n"
            }
            return partial + " \(property.name): \(self[property.name] ?? "value not parsed")\n"
        })
        return propertyValue
    }
}

internal protocol HumanReadable {
    var humanReadable: String { get }
}

internal extension UIView {
    var bottomRight: CGPoint {
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

internal extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}

// Source https://www.objc.io/blog/2018/04/24/bindings-with-kvo-and-keypaths/
internal extension NSObjectProtocol where Self: NSObject {
    func observe<Value>(_ keyPath: KeyPath<Self, Value>,
                        onChange: @escaping (Value) -> Void) -> NSKeyValueObservation {
        return observe(keyPath, options: [.initial, .new]) { _, change in
            guard let newValue = change.newValue else { return }
            onChange(newValue)
        }
    }
    func bind<Value, Target>(_ sourceKeyPath: KeyPath<Self, Value>,
                             to target: Target,
                             at targetKeyPath: ReferenceWritableKeyPath<Target, Value>)
        -> NSKeyValueObservation {
        return observe(sourceKeyPath) { target[keyPath: targetKeyPath] = $0 }
    }
}

extension UIViewController {
    func showAlert(alertController: UIAlertController, source viewController: UIViewController, barButtonItem: UIBarButtonItem? = nil) {
        if let popover = alertController.popoverPresentationController, let sender = barButtonItem {
            popover.barButtonItem = sender
            popover.permittedArrowDirections = [.down, .up]
            popover.canOverlapSourceViewRect = false
        } else {
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alertController.addAction(cancel)
        }
        present(alertController, animated: true)
    }
    
   static func configureNavigationBar(_ navigationController: UINavigationController?) {
        guard let navigationController = navigationController else { return }
        navigationController.navigationBar.barTintColor = RealmStyle.tintColor
        navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.isTranslucent = false
        if #available(iOS 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
            navigationController.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        }
    }
}
