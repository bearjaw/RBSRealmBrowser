//
//  RBSRealmObjectCell.swift
//  Pods
//
//  Created by Max Baumbach on 14/04/16.
//
//

import UIKit
import RealmSwift

class RBSRealmPropertyCell: UITableViewCell, UITextFieldDelegate {
    private var labelPropertyTitle = UILabel()
    private var textFieldPropValue = UITextField()
    private var labelPropertyType = UILabel()
    private var property: Property! = nil
    weak var delegate: RBSRealmPropertyCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        textFieldPropValue.returnKeyType = .done
        textFieldPropValue.backgroundColor = .white
        textFieldPropValue.textAlignment = .right
        
        let spacing = UIView(frame:CGRect(x:0.0, y:0.0, width:10.0, height:0.0))
        textFieldPropValue.leftViewMode = .always
        textFieldPropValue.leftView = spacing
        textFieldPropValue.rightViewMode = .always
        textFieldPropValue.rightView = spacing
        UITextField.appearance().tintColor = UIColor(red:0.35, green:0.34, blue:0.62, alpha:1.0)
        contentView.addSubview(self.textFieldPropValue)
        
        labelPropertyTitle = labelWithAttributes(14, weight:0.3, text: "")
        contentView.addSubview(self.labelPropertyTitle)
        
        labelPropertyType.font = UIFont.systemFont(ofSize: 12.0)
        labelPropertyType.textColor = .lightGray
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
    
    func cellWithAttributes(_ propertyTitle: String, propertyValue: String, editMode: Bool, property: Property, isArray:Bool) {
        self.property = property
        textFieldPropValue.delegate = self
        labelPropertyTitle.text = propertyTitle
        labelPropertyType.text = stringForType(type: property.type)
        if editMode {
            textFieldPropValue.resignFirstResponder()
        }
        self.textFieldPropValue.isUserInteractionEnabled = editMode
        
        if isArray || property.type == .object{
            textFieldPropValue.isUserInteractionEnabled = false
        }
        
        if property.type == .float || property.type == .double {
            textFieldPropValue.keyboardType = .decimalPad
        } else if property.type == .int {
            textFieldPropValue.keyboardType = .numberPad
        }
        
        textFieldPropValue.text = propertyValue
        if editMode && !isArray && property.type != .object {
            textFieldPropValue.layer.borderColor = UIColor(red:0.35, green:0.34, blue:0.62, alpha:1.0).cgColor
            textFieldPropValue.layer.borderWidth = 1.0
        }else {
            textFieldPropValue.layer.borderWidth = 0.0
        }
        
        setNeedsLayout()
        isUserInteractionEnabled = true
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
    
    //MARK: private method
    
    private func labelWithAttributes(_ fontSize: CGFloat, weight: CGFloat, text: String) -> UILabel {
        let label = UILabel()
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        } else {
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
        label.text = text
        return label
    }
    
    private func stringForType(type:PropertyType) -> String {
        switch type {
        case .array:
            return "Array"
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
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if  (property != nil) && (property.type == .bool) {
            textField.resignFirstResponder()
            let isEqual:Bool = (textFieldPropValue.text! as String == "false")
            var newValue = "0"
            if isEqual {
                newValue = "1"
                textField.text = "true"
            } else {
                textField.text = "false"
            }
            
            guard let del = delegate else {
                print("delegate not set")
                return
            }
            
            del.textFieldDidFinishEdit(newValue, property: self.property)
            self.setNeedsLayout()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.isUserInteractionEnabled = false
                return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if  property.type != .bool {
            guard let del = delegate else {
                print("delegate not set")
                return
            }
            del.textFieldDidFinishEdit(textField.text!, property: self.property)
        }
        textField.resignFirstResponder()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text == "\n" {
            textField.resignFirstResponder()
            return false
        }
        self.setNeedsLayout()
        return true
    }
}

protocol RBSRealmPropertyCellDelegate: class {
    func textFieldDidFinishEdit(_ input: String, property: Property)
}
