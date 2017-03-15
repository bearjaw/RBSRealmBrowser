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
    private var propertyTitle = UILabel()
    private var propertyValueTextField = UITextField()
    private var property: Property! = nil
    var delegate: RBSRealmPropertyCellDelegate! = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        propertyValueTextField.delegate = self
        propertyValueTextField.returnKeyType = .done
        propertyValueTextField.backgroundColor = .white
        propertyValueTextField.textAlignment = .right
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        propertyValueTextField.text = ""
        propertyTitle.text = ""
    }
    
    func cellWithAttributes(_ propertyTitle: String, propertyValue: String, editMode: Bool, property: Property, isArray:Bool) {
        self.propertyTitle = self.labelWithAttributes(14, weight:0.3, text: propertyTitle)
        contentView.addSubview(self.propertyTitle)
        
        if isArray {
            propertyValueTextField.isUserInteractionEnabled = false
        }
        self.propertyValueTextField.isUserInteractionEnabled = editMode
        
        if property.type == .float || property.type == .double {
            propertyValueTextField.keyboardType = UIKeyboardType.decimalPad
        } else if property.type == .int {
            propertyValueTextField.keyboardType = UIKeyboardType.numberPad
        }
        
        propertyValueTextField.text = propertyValue
        
        contentView.addSubview(self.propertyValueTextField)
        self.property = property
        setNeedsLayout()
        isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let borderOffset: CGFloat = 20.0
        
        var labelSize = propertyTitle.sizeThatFits(CGSize(width: contentView.bounds.size.width - 2*borderOffset, height: 2000.0))
        propertyTitle.frame = (CGRect(x: borderOffset, y: (contentView.bounds.size.height-labelSize.height)/2.0, width: labelSize.width, height: labelSize.height))
        
        let labelWidth = contentView.bounds.size.width-propertyTitle.bounds.size.width-2*borderOffset
        labelSize = propertyValueTextField.sizeThatFits(CGSize(width: labelWidth, height: 2000.0))
        propertyValueTextField.frame = (CGRect(x:contentView.bounds.size.width-labelWidth-borderOffset, y: (contentView.bounds.size.height-labelSize.height)/2, width:labelWidth, height: labelSize.height))
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
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if  property != nil {
            if property.type == .bool {
                
                let isEqual = (propertyValueTextField.text! as String == "false")
                var newValue = "0"
                if isEqual {
                    newValue = "1"
                    propertyValueTextField.text = "true"
                } else {
                    propertyValueTextField.text = "false"
                }
                
                self.delegate.textFieldDidFinishEdit(newValue, property: self.property)
                propertyValueTextField.resignFirstResponder()
                self.setNeedsLayout()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        propertyValueTextField.isUserInteractionEnabled = false
        self.delegate.textFieldDidFinishEdit(textField.text!, property: self.property)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        propertyValueTextField.isUserInteractionEnabled = false
        if  property.type != .bool {
            self.delegate.textFieldDidFinishEdit(textField.text!, property: self.property)
        }
    }
}

protocol RBSRealmPropertyCellDelegate {
    func textFieldDidFinishEdit(_ input: String, property: Property)
}
