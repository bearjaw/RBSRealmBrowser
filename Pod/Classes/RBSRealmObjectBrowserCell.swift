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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(labelTitle)
        contentView.addSubview(labelDetailText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func realmBrowserObjectAttributes(_ objectTitle: String, objectsCount: String) {
        labelTitle.text = objectTitle
        
        labelDetailText.text = objectsCount
        labelDetailText.font = .systemFont(ofSize: 11)
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        labelTitle.text = ""
        labelDetailText.text = ""
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let borderOffset: CGFloat = 20.0
        let labelOffset: CGFloat = 5.0
        
        var labelSize = labelTitle.sizeThatFits(CGSize(width: self.bounds.size.width-2*borderOffset, height: 2000.0))
        labelTitle.frame = (CGRect(x: borderOffset, y: 10.0, width: labelSize.width, height: labelSize.height))
        
        labelSize = labelDetailText.sizeThatFits(CGSize(width: self.bounds.size.width-2*borderOffset-labelTitle.bounds.size.width, height: 2000.0))
        labelDetailText.frame = (CGRect(x: borderOffset, y: labelTitle.frame.origin.y+labelTitle.bounds.size.height+labelOffset, width: labelSize.width, height: labelSize.height))

    }
}
