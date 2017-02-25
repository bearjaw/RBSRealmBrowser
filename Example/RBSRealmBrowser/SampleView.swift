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
        self.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let borderOffset: CGFloat = 10.0

        label.frame = (CGRect(x: 0, y: 0, width: self.bounds.size.width-2*borderOffset, height: 2000))
            label.sizeToFit()
        label.frame = (CGRect(x: (self.bounds.size.width-label.bounds.size.width)/2, y:(self.bounds.size.height-label.bounds.size.height)/2, width: label.bounds.size.width, height:label.bounds.size.height ))
    }
}
