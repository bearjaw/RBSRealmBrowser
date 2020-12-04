//
//  SampleView.swift
//  RBSRealmBrowser
//
//  Created by Max Baumbach on 14/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class SampleView: UIView {
    private var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.text = "Tap open to preview some preset objects"
        label.numberOfLines = 0
        self.addSubview(label)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let borderOffset: CGFloat = 10.0
        let width = bounds.width
        let height = bounds.height
        let size = CGSize(width: width - 2 * borderOffset, height: 2_000.0)
        
        let labelSize = label.sizeThatFits(size)
        label.frame = CGRect(x: (width - labelSize.width) / 2,
                             y:(height - label.bounds.height) / 2,
                             width: labelSize.width, height:labelSize.height)
    }
}
