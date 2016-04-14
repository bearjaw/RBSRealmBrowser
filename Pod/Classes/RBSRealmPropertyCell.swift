//
//  RBSRealmObjectCell.swift
//  Pods
//
//  Created by Max Baumbach on 14/04/16.
//
//

import UIKit

class RBSRealmPropertyCell: UITableViewCell {
        private var propertyTitle = UILabel()
        private var propertyValue = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        propertyValue = UILabel()
        propertyTitle = UILabel()
    }
    
    func cellWithAttributes(propertyTitle:String,propertyValue:String) {
        
        self.propertyTitle = self.labelWithAttributes(14,weight:1 ,text: propertyTitle)
        self.addSubview(self.propertyTitle)
        self.propertyValue = self.labelWithAttributes(14,weight:0, text: propertyValue)
        self.addSubview(self.propertyValue)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let borderOffset:CGFloat = 10.0
        
        propertyTitle.frame = (CGRect(x: borderOffset   , y: borderOffset, width: self.bounds.size.width-2*borderOffset, height: 2000))
        propertyTitle.sizeToFit()
        propertyTitle.frame = (CGRect(x: borderOffset, y: (self.bounds.size.height-propertyTitle.bounds.size.height)/2, width: self.propertyTitle.bounds.size.width, height: propertyTitle.bounds.size.height))
        
        propertyValue.frame = (CGRect(x: 0.0, y: 0.0, width: self.bounds.size.width-2*borderOffset, height: 2000))
        propertyValue.sizeToFit()
        propertyValue.frame = (CGRect(x: self.bounds.size.width-propertyValue.bounds.size.width-borderOffset, y: (self.bounds.size.height-propertyValue.bounds.size.height)/2, width: self.propertyValue.bounds.size.width, height: propertyValue.bounds.size.height))
    }
    
    //MARK: private method
    
    private func labelWithAttributes(fontSize:CGFloat, weight:CGFloat ,text:String) -> UILabel {
        var label = UILabel()
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFontOfSize(fontSize, weight: weight)
        } else {
            label.font = UIFont.systemFontOfSize(fontSize)
        }
        label.text = text
        return label
    }
}
