//
//  RBSRealmObjectBrowserCell.swift
//  Pods
//
//  Created by Max Baumbach on 31/03/16.
//
//

import UIKit

final class RBSRealmObjectBrowserCell: UITableViewCell {
    private var labelTitle = UILabel()
    private var labelDetailText = UILabel()
    private let maxHeight = 2000.0
    
    
    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        labelTitle.font = UIFont.preferredFont(forTextStyle: .title2)
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
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let borderOffset: Double = 20.0
        let screenWidth: Double = Double(bounds.size.width)
        let offset: CGFloat = 45.0
        let sizeTitle = labelTitle.sizeThatFits(CGSize(width: screenWidth-2*borderOffset, height: maxHeight))
        let sizeDetail = labelDetailText.sizeThatFits(CGSize(width: screenWidth-2*borderOffset-Double(labelTitle.bounds.size.width), height: maxHeight))
        return (CGSize(width: size.width, height: sizeTitle.height + sizeDetail.height + offset))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let borderOffset: Double = 20.0
        let labelOffset: Double = 5.0
        let screenWidth: Double = Double(bounds.size.width)
        
        let sizeTitle = labelTitle.sizeThatFits(CGSize(width: screenWidth-2*borderOffset, height: 2000.0))
        let originTitle = (CGPoint(x: Double(borderOffset), y: 10.0))
        labelTitle.frame = (CGRect(origin: originTitle, size: sizeTitle))
        labelTitle.frame = (CGRect(x: borderOffset, y: 10.0, width: Double(sizeTitle.width), height: Double(sizeTitle.height)))
        
        let sizeDetail = labelDetailText.sizeThatFits(CGSize(width: screenWidth-2*borderOffset-Double(labelTitle.bounds.size.width), height: 2000.0))
        labelDetailText.frame = (CGRect(x: borderOffset, y: Double(labelTitle.right().y)+labelOffset, width: Double(sizeDetail.width), height: Double(sizeDetail.height)))
    }
}
