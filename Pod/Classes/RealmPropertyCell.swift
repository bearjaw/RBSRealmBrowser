//
//  RBSRealmObjectCell.swift
//  Pods
//
//  Created by Max Baumbach on 14/04/16.
//
//

import RealmSwift
import UIKit

protocol RBSRealmPropertyCellDelegate: AnyObject {
    func textFieldDidFinishEdit(_ input: String, property: Property)
}

final class RealmPropertyCell: UITableViewCell {
    
    static let identifier = NSStringFromClass(RealmObjectBrowserCell.self)
    
    private lazy var typeView: ObjectTypeView = {
        let view = ObjectTypeView()
        contentView.addSubview(view)
        return view
    }()
    
    private lazy var textFieldPropValue: UITextField = {
        let textField = UITextField()
        let spacing = UIView(frame:CGRect(x: 0.0, y: 0.0, width: 10.0, height: 0.0))
        spacing.backgroundColor = .clear
        textField.leftViewMode = .always
        textField.leftView = spacing
        textField.rightView = spacing
        textField.rightViewMode = .always
        textField.returnKeyType = .done
        textField.textAlignment = .right
        textField.autocorrectionType = .no
        contentView.addSubview(textField)
        return textField
    }()
    
    private lazy var toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.addTarget(self, action: .toggleSwitch, for: .valueChanged)
        contentView.addSubview(toggle)
        return toggle
    }()
    
    private var property: Property?
    weak var delegate: RBSRealmPropertyCellDelegate?
    
    private let margin16 = UIView.margin16
    private let margin8 = UIView.margin8
    
    private var disposables: [NSKeyValueObservation] = []
    @objc private dynamic var isEditingAllowed = false
    
    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        toggle.isHidden = true
        addObservers()
        configureColors()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textFieldPropValue.text = ""
        typeView.update(name: "")
        textFieldPropValue.frame = .zero
        toggle.frame = .zero
        toggle.isHidden = true
    }
    
    func cellWithAttributes(propertyTitle: String,
                            propertyValue: String,
                            editMode: Bool,
                            property: Property) {
        self.property = property
        isEditingAllowed = shouldAllowEditing(for: property.type) && editMode
        let type = property.humanReadable
        typeView.update(name: propertyTitle, type: type)
        textFieldPropValue.text = propertyValue
        configureToggle(for: property, value: propertyValue)
        configureKeyboard(for: property.type)
        configureTextField(for: editMode)
    }
    
    func configureToggle(for property: Property, value: String) {
        if property.type == .bool {
            toggle.isOn = Bool(value)!
            toggle.isHidden = false
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let usableSize = CGSize(width: size.width - 2 * margin16, height: .greatestFiniteMagnitude)
        let sizeTypeView = typeView.sizeThatFits(usableSize)
        return CGSize(width: size.width, height: sizeTypeView.height + 2 * margin16)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let usableSize = CGSize(width: contentView.bounds.width - 2 * margin16,
                                height: .greatestFiniteMagnitude)
        let sizeTypeView = typeView.sizeThatFits(usableSize)
        let originType = CGPoint(x: margin16, y: margin16)
        typeView.frame = CGRect(origin: originType, size: sizeTypeView)
        
        let usableTextFieldWidth = contentView.bounds.width
            - typeView.bounds.width
            - 3 * margin16
        
        let usableTextFieldSize = CGSize(width: usableTextFieldWidth,
                                         height: .greatestFiniteMagnitude)
        let sizeTextField = textFieldPropValue.sizeThatFits(usableTextFieldSize)
        let minWidth = min(sizeTextField.width, usableTextFieldSize.width)
        
        let originTextField = CGPoint(x: contentView.bounds.width - minWidth - margin16,
                                      y: margin16)
        if let prop = property {
            if prop.type == .bool {
                toggle.frame = CGRect(origin: originTextField,
                                      size: (CGSize(width: minWidth,
                                                    height: toggle.bounds.size.height)))
            } else {
                textFieldPropValue.frame = CGRect(origin: originTextField,
                                                  size: CGSize(width: minWidth,
                                                               height: sizeTextField.height + 16))
                let yPos = typeView.convert(typeView.titleCenter, to: self).y
                textFieldPropValue.center = CGPoint(x: textFieldPropValue.center.x, y: yPos)
            }
        }
    }
    
    @objc
    func toggleSwitch() {
        guard let delegate = delegate, let prop = property else { return }
        delegate.textFieldDidFinishEdit("\(toggle.isOn)", property: prop)
    }
    
    // MARK: - Configureation
    
    private func addObservers() {
        disposables.append(
            toggle.observe(\.isHidden, onChange: { [weak self] value in
                guard let self = self else { return }
                self.textFieldPropValue.isHidden = !value
            }))
        disposables.append(
            observe(\.isEditingAllowed, onChange: { [weak self] value in
                self?.textFieldPropValue.isUserInteractionEnabled = value
                self?.setTextFieldBorders(for: value)
                self?.toggle.isEnabled = value
            })
        )
    }
    
    private func configureColors() {
        if #available(iOS 13.0, *) {
            textFieldPropValue.backgroundColor = .systemBackground
            textFieldPropValue.tintColor = RealmStyle.tintColor
        } else {
            // Fallback on earlier versions
            textFieldPropValue.backgroundColor = .white
        }
    }
    
    private func configureKeyboard(for propertyType: PropertyType) {
        if propertyType == .float || propertyType == .double {
            textFieldPropValue.keyboardType = .decimalPad
        } else if propertyType == .int {
            textFieldPropValue.keyboardType = .numberPad
        } else if propertyType == .string {
            textFieldPropValue.keyboardType = .alphabet
        }
    }
    
    deinit {
        disposables.forEach({ $0.invalidate() })
        disposables = []
    }
}

// MARK: - UITextFieldDelegate

extension RealmPropertyCell: UITextFieldDelegate {
    private func configureTextField(for editMode:Bool) {
        if editMode {
            textFieldPropValue.resignFirstResponder()
        }
        textFieldPropValue.isUserInteractionEnabled = editMode
        textFieldPropValue.delegate = self
    }
    
    private func setTextFieldBorders(for value: Bool) {
        if  isEditingAllowed {
            textFieldPropValue.layer.borderColor = RealmStyle.tintColor.cgColor
            textFieldPropValue.layer.borderWidth = 1.0
        } else {
            textFieldPropValue.layer.borderWidth = 0.0
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let property = property else { print("No properzy set"); return false }
        return shouldAllowEditing(for: property.type)
    }
    
    private func shouldAllowEditing(for propertyType: PropertyType) -> Bool {
        return !(propertyType == .linkingObjects ||
                    propertyType == .data ||
                    propertyType == .linkingObjects ||
                    propertyType == .object)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let property = property, let delegate = delegate else { return }
        if property.type == .bool {
            let isEqual: Bool = (textField.text! as String == "false")
            textField.text = isEqual.humanReadable
            
            delegate.textFieldDidFinishEdit("\(isEqual.rawValue)", property: property)
            setNeedsLayout()
            textField.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.isUserInteractionEnabled = false
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        guard let property = property else { return }
        if  property.type != .bool {
            guard let delegate = delegate, let text = textField.text else { return }
            delegate.textFieldDidFinishEdit(text, property: property)
        }
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField.text == "\n" {
            textField.resignFirstResponder()
            return false
        }
        setNeedsLayout()
        return true
    }
}

fileprivate extension Selector {
    static let toggleSwitch = #selector(RealmPropertyCell.toggleSwitch)
}
