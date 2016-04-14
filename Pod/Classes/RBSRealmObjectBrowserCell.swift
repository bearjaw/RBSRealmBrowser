//
//  RBSRealmObjectBrowserCell.swift
//  Pods
//
//  Created by Max Baumbach on 31/03/16.
//
//

import UIKit

class RBSRealmObjectBrowserCell: UITableViewCell {
        private var labelTitle = UILabel()
        private var labelDetailText = UILabel()
    
    
    func realmBrowserObjectAttributes(objectTitle:String, objectsCount:String) {
        labelTitle.text = objectTitle
        self.addSubview(labelTitle)
        labelDetailText.text = objectsCount
        labelDetailText.font = UIFont.systemFontOfSize(11)
        self.addSubview(labelDetailText)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        labelTitle = UILabel()
        labelDetailText = UILabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let borderOffset:CGFloat = 20.0
        let labelOffset: CGFloat = 5
        
        labelTitle.frame = (CGRect(x: borderOffset, y: 10.0, width: self.bounds.size.width-2*borderOffset, height: 2000))
        labelTitle.sizeToFit()
        labelDetailText.frame = (CGRect(x: borderOffset, y: labelTitle.frame.origin.y+labelTitle.bounds.size.height+labelOffset, width: self.bounds.size.width, height: 2000))
        labelDetailText.sizeToFit()
    }
}