//
//  RBSRealmObjectCell.swift
//  Pods
//
//  Created by Max Baumbach on 14/04/16.
//
//

import UIKit
import RealmSwift

final class RBSRealmPropertyCell: UITableViewCell, UITextFieldDelegate {
    private var labelPropertyTitle = UILabel()
    private var textFieldPropValue:UITextField = {
        let textField  = UITextField()
        let spacing = UIView(frame:CGRect(x:0.0, y:0.0, width:10.0, height:0.0))
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
    private var labelPropertyType:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textColor = .lightGray
        return label
    }()
    private var property: Property?
    weak var delegate: RBSRealmPropertyCellDelegate?
    
    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        UITextField.appearance().tintColor = RealmStyle.tintColor
        contentView.addSubview(textFieldPropValue)
        
        labelPropertyTitle = labelWithAttributes(14, weight:0.3, text: "")
        contentView.addSubview(labelPropertyTitle)
        contentView.addSubview(labelPropertyType)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textFieldPropValue.text = ""
        labelPropertyTitle.text = ""
        labelPropertyType.text = ""
    }
    
    func cellWithAttributes(propertyTitle: String,
                            propertyValue: String,
                            editMode: Bool,
                            property: Property) {
        self.property = property
        labelPropertyTitle.text = propertyTitle
        textFieldPropValue.text = propertyValue
        configureKeyboard(for: property.type)
        configureLabelType(for: property)
        configureTextField(for: editMode)
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let borderOffset: CGFloat = 20.0
        
        var labelSize = labelPropertyTitle.sizeThatFits(CGSize(width: contentView.bounds.size.width - 2*borderOffset, height: 2000.0))
        let labelPropertyTypeSize = labelPropertyType.sizeThatFits(CGSize(width: contentView.bounds.size.width - 2*borderOffset, height: 2000.0))
        labelPropertyTitle.frame = (CGRect(x: borderOffset, y: (contentView.bounds.size.height - labelSize.height - labelPropertyTypeSize.height - 10.0)/2.0, width: labelSize.width, height: labelSize.height))
        labelPropertyType.frame = (CGRect(x: borderOffset, y: labelPropertyTitle.frame.origin.y + labelSize.height + borderOffset/2.0, width: labelPropertyTypeSize.width, height: labelPropertyTypeSize.height))
        
        let labelWidth = contentView.bounds.size.width-labelPropertyTitle.bounds.size.width-4*borderOffset
        labelSize = textFieldPropValue.sizeThatFits(CGSize(width: labelWidth, height: 2000.0))
        textFieldPropValue.frame = (CGRect(x:contentView.bounds.size.width-min(labelSize.width,labelWidth)-borderOffset, y: (contentView.bounds.size.height-labelSize.height - borderOffset)/2, width:min(labelSize.width,labelWidth), height: labelSize.height + borderOffset))
    }
    
    // MARK: - private method
    
    private func labelWithAttributes(_ fontSize: CGFloat, weight: CGFloat, text: String) -> UILabel {
        let label = UILabel()
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight(weight))
        } else {
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
        label.text = text
        return label
    }
    
    private func configureKeyboard(for propertyType:PropertyType) {
        if propertyType == .float || propertyType == .double {
            textFieldPropValue.keyboardType = .decimalPad
        } else if propertyType == .int {
            textFieldPropValue.keyboardType = .numberPad
        } else if propertyType == .string {
            textFieldPropValue.keyboardType = .alphabet
        }
        let allowEditing = shouldAllowEditing(for: propertyType)
        if  allowEditing {
            textFieldPropValue.layer.borderColor = RealmStyle.tintColor.cgColor
            textFieldPropValue.layer.borderWidth = 1.0
        } else {
            textFieldPropValue.layer.borderWidth = 0.0
        }
    }
    
    private func configureLabelType(for property:Property) {
        if property.isArray {
            labelPropertyType.text = "Array"
        } else {
            labelPropertyType.text = property.type.humanReadable
        }
    }
    
    private func configureTextField(for editMode:Bool) {
        if editMode {
            textFieldPropValue.resignFirstResponder()
        }
        textFieldPropValue.isUserInteractionEnabled = editMode
        textFieldPropValue.delegate = self
    }
    
    // MARK: - UITextFieldDelegate
    
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
        }
        textField.resignFirstResponder()
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

protocol RBSRealmPropertyCellDelegate: AnyObject {
    func textFieldDidFinishEdit(_ input: String, property: Property)
}

internal extension Bool {
    var rawValue: Int {
        return self ? 1 : 0
    }
}
