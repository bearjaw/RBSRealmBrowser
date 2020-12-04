//
//  RealmObjectBrowserCell.swift
//  Pods
//
//  Created by Max Baumbach on 31/03/16.
//
//

import UIKit

final class RealmObjectBrowserCell: UITableViewCell {
    
    static let identifier = NSStringFromClass(RealmObjectBrowserCell.self)
    
    let margin = UIView.margin16
    
    private lazy var typeView: ObjectTypeView = {
        let view = ObjectTypeView()
        contentView.addSubview(view)
        return view
    }()
    
    private lazy var labelDetailText: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 10
        contentView.addSubview(label)
        return label
    }()
    
    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureColors()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Update
    
    func updateWith(title: String, detailText: String) {
        typeView.update(name: title, type: detailText)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        typeView.update(name: "")
    }
    
    // MARK: - Layout
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let screenWidth = size.width
        let usableSize = CGSize(width: screenWidth - 2 * margin, height: .greatestFiniteMagnitude)
        let sizeType = typeView.sizeThatFits(usableSize)
        return CGSize(width: size.width, height: sizeType.height + 2 * margin)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
        accessoryType = selected ? .checkmark : .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let screenWidth = contentView.bounds.width
        let usableSize = CGSize(width: screenWidth - 2 * margin,
                                height: .greatestFiniteMagnitude)
        
        let sizeTitle = typeView.sizeThatFits(usableSize)
        
        let originTitle = CGPoint(x: margin, y: margin)
        typeView.frame = CGRect(origin: originTitle, size: sizeTitle)
        
        //        let originDetail = CGPoint(x: originTitle.x, y: labelTitle.bottomRight.y + 10)
        //        let sizeObjectType = labelObjectType.sizeThatFits(usableSize)
        //        labelObjectType.frame = CGRect(origin: originDetail, size: sizeObjectType)
        
        //        let sizeDetail = labelDetailText.sizeThatFits(usableSize)
        //        let originDetail = CGPoint(x: margin + sizeCircle.width + margin/2, y: labelTitle.bottomRight.y+labelOffset)
        //        labelDetailText.frame = CGRect(origin: originDetail, size: sizeDetail)
    }
    
    // Configuration
    
    private func configureColors() {
        if #available(iOS 13.0, *) {
            labelDetailText.backgroundColor = .systemBackground
            labelDetailText.textColor = .secondaryLabel
            backgroundColor = .systemBackground
            contentView.backgroundColor = .systemBackground
        } else {
            labelDetailText.backgroundColor = .white
            labelDetailText.textColor = .darkGray
            backgroundColor = .white
            contentView.backgroundColor = .white
        }
    }
}

final class ObjectTypeView: UIView {
    
    let margin16 = UIView.margin16
    let margin8 = UIView.margin8
    
    private lazy var circleView: UIView = {
        let view = UIView()
        view.backgroundColor = .random
        addSubview(view)
        return view
    }()
    
    private lazy var labelName: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.numberOfLines = 1
        addSubview(label)
        return label
    }()
    
    private lazy var labelType: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        addSubview(label)
        return label
    }()
    
    var titleCenter: CGPoint { labelName.center }
    
    // MARK: - Setup
    
    func update(name: String, type: String? = nil) {
        configureColors()
        labelName.text = name
        labelType.text = type
        labelType.isHidden = type?.isEmpty == true ? true : false
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let screenWidth: CGFloat = size.width
        let usableSize = CGSize(width: screenWidth, height: .greatestFiniteMagnitude)
        let sizeName = labelName.sizeThatFits(usableSize)
        let sizeDetail = labelType.sizeThatFits(usableSize)
        let height = [sizeName, sizeDetail].reduce(.zero, +).height
        let maxWidth = [sizeName.width, sizeDetail.width].max() ?? (size.width / 2)
        let width = maxWidth + margin8 + sizeName.height
        return CGSize(width: width, height: height + margin8)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let screenWidth = bounds.width
        let usableSize = CGSize(width: screenWidth - 2 * margin16,
                                height: .greatestFiniteMagnitude)
        
        let sizeName = labelName.sizeThatFits(usableSize)
        let originName = CGPoint(x: sizeName.height + margin8, y: 0)
        labelName.frame = CGRect(origin: originName, size: sizeName)
        
        layoutCircleView(relattiveTo: labelName.bounds.height)
        
        let originType = CGPoint(x: originName.x, y: labelName.bottomRight.y + margin8)
        let sizeType = labelType.sizeThatFits(usableSize)
        
        labelType.frame = CGRect(origin: originType, size: sizeType)
    }
    
    private func layoutCircleView(relattiveTo dimension: CGFloat) {
        let dim = dimension / 2
        let sizeCircle = CGSize(width: dim, height: dim)
        circleView.frame = CGRect(origin: .zero, size: sizeCircle)
        circleView.center = CGPoint(x: circleView.center.x, y: labelName.center.y)
        circleView.layer.cornerRadius = sizeCircle.height / 2
    }
    
    private func configureColors() {
        if #available(iOS 13.0, *) {
            labelName.textColor = .label
            labelName.backgroundColor = .systemBackground
            labelType.backgroundColor = .systemBackground
            labelType.textColor = .secondaryLabel
            backgroundColor = .systemBackground
        } else {
            labelName.textColor = .darkGray
            labelName.backgroundColor = .white
            labelType.backgroundColor = .white
            labelType.textColor = .darkGray
            backgroundColor = .white
        }
    }
    
}
