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
    private let maxHeight: CGFloat = 2000.0
    
    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        labelTitle.font = UIFont.preferredFont(forTextStyle: .title2)
        contentView.addSubview(labelTitle)
        labelDetailText.numberOfLines = 0
        contentView.addSubview(labelDetailText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func realmBrowserObjectAttributes(_ objectTitle: String, detailText: String) {
        labelTitle.text = objectTitle
        labelDetailText.text = detailText
        labelDetailText.font = .systemFont(ofSize: 11)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        labelTitle.text = ""
        labelDetailText.text = ""
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let borderOffset: CGFloat = 20.0
        let screenWidth: CGFloat = size.width
        let offset: CGFloat = 45.0
        let usableSize = CGSize(width: screenWidth-2*borderOffset,
                                 height: maxHeight)
        let sizeTitle = labelTitle.sizeThatFits(usableSize)
        let labelDetailWidth = usableSize.width - labelTitle.bounds.size.width
        let sizeDetail = labelDetailText.sizeThatFits(CGSize(width: labelDetailWidth,
                                                             height: usableSize.height) )
        let height = [sizeTitle, sizeDetail].reduce(.zero, +).height
        return (CGSize(width: size.width, height: height + offset))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let borderOffset: CGFloat = 20.0
        let labelOffset: CGFloat = 5.0
        let screenWidth: CGFloat = bounds.size.width
        let usableSize = CGSize(width: screenWidth-2*borderOffset,
                                height: maxHeight)
        
        let sizeTitle = labelTitle.sizeThatFits(usableSize)
        let originTitle = (CGPoint(x: borderOffset, y: 10.0))
        labelTitle.frame = (CGRect(origin: originTitle, size: sizeTitle))
        
        let labelDetailWidth = usableSize.width - labelTitle.bounds.size.width
        let sizeDetail = labelDetailText.sizeThatFits(CGSize(width: labelDetailWidth,
                                                             height: usableSize.height))
        let originDetail = (CGPoint(x: borderOffset, y: labelTitle.bottomRight.y+labelOffset))
        labelDetailText.frame = (CGRect(origin: originDetail, size: sizeDetail))
    }
    
}
