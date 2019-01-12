//
//  RBSBrowserTableViewCell.swift
//  RBSRealmBrowser
//
//  Created by Max Baumbach on 12/01/2019.
//

import UIKit

internal class RBSBrowserTableViewCell<Element>: UITableViewCell where Element: Displayable {
    
    private var labelTitle = UILabel()
    private var labelDetailText = UILabel()
    private let maxHeight: CGFloat = 2000.0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        labelTitle.font = UIFont.preferredFont(forTextStyle: .title2)
        contentView.addSubview(labelTitle)
        contentView.addSubview(labelDetailText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update<Element: Displayable>(element: Element) {
        labelTitle.text = element.title
        labelDetailText.text = element.subtitle
        labelDetailText.font = .systemFont(ofSize: 11)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        labelTitle.text = ""
        labelDetailText.text = ""
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let borderOffset: CGFloat = 20.0
        let screenWidth: CGFloat = bounds.size.width
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
        
        let originTitle = (CGPoint(x: borderOffset, y: 10.0))
        layoutTitlelLabel(fitting: usableSize, origin: originTitle)
        
        let originDetail = (CGPoint(x: borderOffset, y: labelTitle.bottomRight.y+labelOffset))
        layoutDetailLabel(fitting: usableSize, origin: originDetail)
        
    }
    
    private func layoutDetailLabel(fitting size: CGSize, origin: CGPoint) {
        let labelDetailWidth = size.width - labelTitle.bounds.size.width
        let sizeDetail = labelDetailText.sizeThatFits(CGSize(width: labelDetailWidth,
                                                             height: size.height))
        
        labelDetailText.frame = (CGRect(origin: origin, size: sizeDetail))
    }
    
    private func layoutTitlelLabel(fitting size: CGSize, origin: CGPoint) {
        let sizeTitle = labelTitle.sizeThatFits(size)
        labelTitle.frame = (CGRect(origin: origin, size: sizeTitle))
    }
}
