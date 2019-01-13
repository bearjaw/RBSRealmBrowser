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
    private let margin: CGFloat = 20.0
    
    private lazy var circleView: UIView = {
        let view = UIView()
        view.backgroundColor = .random
        return view
    }()
    
    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        labelTitle.font = UIFont.preferredFont(forTextStyle: .title2)
        contentView.addSubview(labelTitle)
        labelDetailText.numberOfLines = 10
        contentView.addSubview(circleView)
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
        let screenWidth: CGFloat = size.width
        let usableSize = CGSize(width: screenWidth-2*margin,
                                 height: maxHeight)
        let sizeTitle = labelTitle.sizeThatFits(usableSize)
        let labelDetailWidth = usableSize.width - labelTitle.bounds.size.width
        let sizeDetail = labelDetailText.sizeThatFits(CGSize(width: labelDetailWidth,
                                                             height: usableSize.height) )
        let height = [sizeTitle, sizeDetail].reduce(.zero, +).height
        return (CGSize(width: size.width, height: height + 5*margin))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labelOffset: CGFloat = 5.0
        let screenWidth: CGFloat = bounds.size.width
        let usableSize = CGSize(width: screenWidth-2*margin,
                                height: maxHeight)
        
        let sizeTitle = labelTitle.sizeThatFits(usableSize)
        
        let sizeCircle = (CGSize(width: sizeTitle.height/2, height: sizeTitle.height/2))
        let originCircle = (CGPoint(x: margin, y: margin + (sizeTitle.height-sizeCircle.height)/2))
        circleView.frame = (CGRect(origin: originCircle, size: sizeCircle))
        circleView.layer.cornerRadius = sizeCircle.height/2
        let originTitle = (CGPoint(x: margin + sizeCircle.width + margin/2 , y: margin))
        labelTitle.frame = (CGRect(origin: originTitle, size: sizeTitle))
        
        let labelDetailWidth = usableSize.width - labelTitle.bounds.size.width
        let sizeDetail = labelDetailText.sizeThatFits(CGSize(width: labelDetailWidth,
                                                             height: usableSize.height))
        let originDetail = (CGPoint(x: margin + sizeCircle.width + margin/2,
                                    y: labelTitle.bottomRight.y+labelOffset))
        labelDetailText.frame = (CGRect(origin: originDetail, size: sizeDetail))
    }
    
}
