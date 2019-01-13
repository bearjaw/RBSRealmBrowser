//
//  RBSRealmObjectCell.swift
//  Pods
//
//  Created by Max Baumbach on 14/04/16.
//
//

import UIKit
import RealmSwift

protocol RBSRealmPropertyCellDelegate: AnyObject {
    func textFieldDidFinishEdit(_ input: String, property: Property)
}

internal final class RBSRealmPropertyCell: UITableViewCell {
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
    private lazy var labelPropertyType: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = .lightGray
        return label
    }()
    
    private var property: Property?
    weak var delegate: RBSRealmPropertyCellDelegate?
    
    private let margin: CGFloat = 20.0
    private let padding: CGFloat = 10.0
    
    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        UITextField.appearance().tintColor = RealmStyle.tintColor
        contentView.addSubview(textFieldPropValue)
        
        contentView.addSubview(circleView)
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
        let minWidth = min(sizeTextField.width,usableTextFieldSize.width)
        let originTextField = (CGPoint(x: contentView.bounds.size.width-minWidth-margin,
                                       y: margin))
        textFieldPropValue.frame = (CGRect(origin: originTextField,
                                           size: (CGSize(width: minWidth,
                                                         height: sizeTextField.height))
        ))
    }
    
    private func viewSizes(for views: [UIView], fitting size: CGSize) -> [CGSize] {
        let sizes = views.map({ $0.sizeThatFits(size) })
        return sizes
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
}

// MARK: - UITextFieldDelegate

extension RBSRealmPropertyCell: UITextFieldDelegate {
    private func configureTextField(for editMode:Bool) {
        if editMode {
            textFieldPropValue.resignFirstResponder()
        }
        textFieldPropValue.isUserInteractionEnabled = editMode
        textFieldPropValue.delegate = self
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
