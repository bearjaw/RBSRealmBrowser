//
//  RBSRealmObjectBrowserCell.swift
//  Pods
//
//  Created by Max Baumbach on 31/03/16.
//
//

import UIKit

final class RealmObjectBrowserCell: UITableViewCell {
    static var identifier: String { return "RealmObjectBrowserCell"  }
    
    private let margin: CGFloat = 20.0
    
    private lazy var labelTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.numberOfLines = 1
        contentView.addSubview(label)
        return label
    }()
    
    private lazy var labelDetailText: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 10
        contentView.addSubview(label)
        return label
    }()
    
    private lazy var circleView: UIView = {
        let view = UIView()
        view.backgroundColor = .random
        return view
    }()
    
    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(circleView)
        configureColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Update
    
    func updateWith(title: String, detailText: String) {
        labelTitle.text = title
        labelDetailText.text = detailText
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        labelTitle.text = ""
        labelDetailText.text = ""
    }
    
    // MARK: - Layout
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let screenWidth: CGFloat = size.width
        let usableSize = CGSize(width: screenWidth-2*margin, height: .greatestFiniteMagnitude)
        let sizeTitle = labelTitle.sizeThatFits(usableSize)
        let sizeDetail = labelDetailText.sizeThatFits(usableSize)
        let height = [sizeTitle, sizeDetail].reduce(.zero, +).height
        return CGSize(width: size.width, height: height + 2*margin)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
        if selected {
            accessoryType = .checkmark
        } else {
            accessoryType = .none
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labelOffset: CGFloat = 5.0
        let screenWidth: CGFloat = contentView.bounds.size.width
        let usableSize = CGSize(width: screenWidth-2*margin,
                                height: .greatestFiniteMagnitude)
        
        let sizeTitle = labelTitle.sizeThatFits(usableSize)
        
        let sizeCircle = CGSize(width: sizeTitle.height/2, height: sizeTitle.height/2)
        let originCircle = CGPoint(x: margin, y: margin + (sizeTitle.height-sizeCircle.height)/2)
        circleView.frame = CGRect(origin: originCircle, size: sizeCircle)
        circleView.layer.cornerRadius = sizeCircle.height/2
        let originTitle = CGPoint(x: margin + sizeCircle.width + margin/2, y: margin)
        labelTitle.frame = CGRect(origin: originTitle, size: sizeTitle)
        
        let sizeDetail = labelDetailText.sizeThatFits(usableSize)
        let originDetail = CGPoint(x: margin + sizeCircle.width + margin/2, y: labelTitle.bottomRight.y+labelOffset)
        labelDetailText.frame = CGRect(origin: originDetail, size: sizeDetail)
    }
    
    // Configuration
    
    private func configureColors() {
        if #available(iOS 13.0, *) {
            labelTitle.textColor = .label
            labelTitle.backgroundColor = .systemBackground
            labelDetailText.backgroundColor = .systemBackground
            labelDetailText.textColor = .label
            backgroundColor = .systemBackground
            contentView.backgroundColor = .systemBackground
        } else {
            labelTitle.textColor = .darkGray
            labelTitle.backgroundColor = .white
            labelDetailText.backgroundColor = .white
            labelDetailText.textColor = .darkGray
            backgroundColor = .white
            contentView.backgroundColor = .white
        }
    }
}
