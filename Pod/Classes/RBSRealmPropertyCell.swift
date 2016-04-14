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
    private var propertyValue = UITextField()
    private var property:Property! = nil
    var delegate:RBSRealmPropertyCellDelegate! = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        propertyValue.text = ""
        propertyValue.removeFromSuperview()
        propertyTitle.text = ""
        propertyTitle.removeFromSuperview()
    }
    
    func cellWithAttributes(propertyTitle:String,propertyValue:String, editMode:Bool, property:Property) {
        
        self.propertyTitle = self.labelWithAttributes(14,weight:0.3 ,text: propertyTitle)
        self.contentView.addSubview(self.propertyTitle)
        
        self.propertyValue = UITextField()
        self.propertyValue.userInteractionEnabled = editMode
        self.userInteractionEnabled = editMode
        if property.type == PropertyType.Bool {
//            self.propertyValue.userInteractionEnabled = false
        }
        if property.type == PropertyType.Float || property.type == PropertyType.Double {
            self.propertyValue.keyboardType = UIKeyboardType.DecimalPad
        }else if property.type == PropertyType.Int{
            self.propertyValue.keyboardType = UIKeyboardType.NumberPad
        }
        self.propertyValue.delegate = self
        self.propertyValue.returnKeyType = UIReturnKeyType.Done
        self.propertyValue.backgroundColor = UIColor.whiteColor()
        self.propertyValue.textAlignment = NSTextAlignment.Right
        
        self.propertyValue.text = propertyValue
        
        self.contentView.addSubview(self.propertyValue)
        self.property = property
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let borderOffset:CGFloat = 20.0
        
        propertyTitle.frame = (CGRect(x: borderOffset   , y: borderOffset, width: self.bounds.size.width-2*borderOffset, height: 2000))
        propertyTitle.sizeToFit()
        propertyTitle.frame = (CGRect(x: borderOffset, y: (self.bounds.size.height-propertyTitle.bounds.size.height)/2, width: self.propertyTitle.bounds.size.width, height: propertyTitle.bounds.size.height))
        
        
        let textFieldWidth = self.bounds.size.width-4*borderOffset-propertyTitle.bounds.size.width
        let posX = propertyTitle.frame.origin.x + propertyTitle.bounds.size.width
        propertyValue.frame = (CGRect(x:posX+50, y: (self.bounds.size.height-40)/2, width:textFieldWidth , height: 40))
        
    }
    
    //MARK: private method
    
    private func labelWithAttributes(fontSize:CGFloat, weight:CGFloat ,text:String) -> UILabel {
        let label = UILabel()
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFontOfSize(fontSize, weight: weight)
        } else {
            label.font = UIFont.systemFontOfSize(fontSize)
        }
        label.text = text
        return label
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if  property != nil {
            if property.type == PropertyType.Bool {
                
                let isEqual = (propertyValue.text! as String == "false")
                var newValue = "0"
                if isEqual{
                    newValue = "1"
                    propertyValue.text = "true"
                }else{
                    propertyValue.text = "false"
                }
                
                self.delegate.textFieldDidFinishEdit(newValue, property: self.property)
                propertyValue.resignFirstResponder()
            }
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        propertyValue.userInteractionEnabled = false
        self.delegate.textFieldDidFinishEdit(textField.text!, property: self.property)
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
        propertyValue.userInteractionEnabled = false
        if  property.type != PropertyType.Bool {
            self.delegate.textFieldDidFinishEdit(textField.text!, property: self.property)    
        }
        
    }
}

protocol RBSRealmPropertyCellDelegate {
    func textFieldDidFinishEdit(input:String, property:Property)
}