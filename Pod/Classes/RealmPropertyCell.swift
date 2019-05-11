//
//  RBSRealmObjectCell.swift
//  Pods
//
//  Created by Max Baumbach on 14/04/16.
//
//

import UIKit
import RealmSwift

protocol RBSRealmPropertyCellDelegate: class {
    func textFieldDidFinishEdit(_ input: String, property: Property)
}

internal final class RealmPropertyCell: UITableViewCell {
    static var identifier: String { return "RealmPropertyCell" }
    private lazy var circleView: UIView = {
        let view = UIView()
        view.backgroundColor = .random
        return view
    }()
    private lazy var labelPropertyTitle = {
        return labelWithAttributes(fontSize: 16, weight:0.3, text: "")
    }()
    private var textFieldPropValue: UITextField = {
        let textField  = UITextField()
        let spacing = UIView(frame:CGRect(x: 0.0, y: 0.0, width: 10.0, height: 0.0))
        spacing.backgroundColor = .clear
        textField.leftViewMode = .always
        textField.leftView = spacing
        textField.rightViewMode = .always
        textField.rightView = spacing
        textField.returnKeyType = .done
        textField.backgroundColor = .white
        textField.textAlignment = .right
        textField.autocorrectionType = .no
        return textField
    }()
    private lazy var labelPropertyType: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = .lightGray
        return label
    }()
    private lazy var toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.addTarget(self, action: .toggleSwitch, for: .valueChanged)
        return toggle
    }()

    private var property: Property?
    weak var delegate: RBSRealmPropertyCellDelegate?

    private let margin: CGFloat = 20.0
    private let padding: CGFloat = 10.0
    private var disposables: [NSKeyValueObservation] = []
    @objc private dynamic var isEditingAllowed = false

    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        UITextField.appearance().tintColor = RealmStyle.tintColor
        contentView.addSubview(textFieldPropValue)
        contentView.addSubview(circleView)
        contentView.addSubview(labelPropertyTitle)
        contentView.addSubview(labelPropertyType)
        toggle.frame = .zero
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
        toggle.isHidden = true
        contentView.addSubview(toggle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textFieldPropValue.text = ""
        labelPropertyTitle.text = ""
        labelPropertyType.text = ""
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
        labelPropertyTitle.text = propertyTitle
        textFieldPropValue.text = propertyValue
        configureToggle(for: property, value: propertyValue)
        configureKeyboard(for: property.type)
        configureLabelType(for: property)
        configureTextField(for: editMode)
        setNeedsLayout()
    }

    func configureToggle(for property: Property, value: String) {
        if property.type == .bool {
            toggle.isOn = Bool(value)!
            toggle.isHidden = false
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let usableSize = (CGSize(width: size.width - 2*margin, height: .greatestFiniteMagnitude))
        let sizeTitle = labelPropertyTitle.sizeThatFits(usableSize)
        let sizeDetail = labelPropertyType.sizeThatFits(usableSize)
        let labelWidth = usableSize.width-labelPropertyTitle.bounds.size.width-4*margin
        let sizeTextField = textFieldPropValue.sizeThatFits((CGSize(width: labelWidth,
                                                                    height: .greatestFiniteMagnitude)))
        let combinedHeight = ([sizeTitle, sizeDetail].reduce(.zero, +) < sizeTextField).height
        return CGSize(width: size.width, height: combinedHeight + 4*margin + padding)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let usableSize = (CGSize(width: contentView.bounds.size.width - 2*margin,
                                 height: .greatestFiniteMagnitude))
        let sizes = viewSizes(for: [labelPropertyTitle, labelPropertyType],
                              fitting: usableSize)

        let sizeTitle = sizes[0]
        let sizeDetail = sizes[1]

        let sizeCircle = (CGSize(width: sizeTitle.height/2, height: sizeTitle.height/2))
        let originCircle = (CGPoint(x: margin, y: margin + (sizeTitle.height-sizeCircle.height)/2))
        circleView.frame = (CGRect(origin: originCircle, size: sizeCircle))
        circleView.layer.cornerRadius = sizeCircle.height/2

        let originTitle = CGPoint(x: circleView.bottomRight.y + padding/2, y: margin)
        labelPropertyTitle.frame = (CGRect(origin: originTitle, size: sizeTitle))

        let originDetail = (CGPoint(x: originTitle.x, y: labelPropertyTitle.bottomRight.y + padding))
        labelPropertyType.frame = (CGRect(origin: originDetail, size: sizeDetail))

        let usableTextFieldWidth = contentView.bounds.size.width
            - sizeCircle.width
            - labelPropertyTitle.bounds.size.width
            - 3*margin

        let usableTextFieldSize = (CGSize(width: usableTextFieldWidth,
                                          height: .greatestFiniteMagnitude))
        let sizeTextField = textFieldPropValue.sizeThatFits(usableTextFieldSize)
        let minWidth = min(sizeTextField.width, usableTextFieldSize.width)
        let originTextField = (CGPoint(x: contentView.bounds.size.width-minWidth-margin,
                                       y: margin))
        if let prop = property {
            if prop.type == .bool {
                toggle.frame = (CGRect(origin: originTextField,
                                       size: (CGSize(width: minWidth,
                                                     height: toggle.bounds.size.height))))
            } else {
                textFieldPropValue.frame = (CGRect(origin: originTextField,
                                                   size: (CGSize(width: minWidth,
                                                                 height: sizeTextField.height))))
            }
        }
    }

    private func viewSizes(for views: [UIView], fitting size: CGSize) -> [CGSize] {
        let sizes = views.map({ $0.sizeThatFits(size) })
        return sizes
    }

    @objc func toggleSwitch() {
        guard let delegate = delegate, let prop = property else { return }
        delegate.textFieldDidFinishEdit("\(toggle.isOn)", property: prop)
    }

    // MARK: - private method

    private func labelWithAttributes(fontSize: CGFloat, weight: CGFloat, text: String) -> UILabel {
        let label = UILabel()
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight(weight))
        } else {
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
        label.text = text
        return label
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

    private func configureLabelType(for property: Property) {
        if property.isArray {
            labelPropertyType.text = "Array"
        } else {
            labelPropertyType.text = property.type.humanReadable
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
        guard let property = property else { return }
        if  property.type != .bool {
            guard let delegate = delegate, let text = textField.text else {
                print("delegate not set")
                return
            }
            delegate.textFieldDidFinishEdit(text, property: property)
        }
        textField.resignFirstResponder()
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
