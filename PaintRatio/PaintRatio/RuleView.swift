//
//  RuleView.swift
//  PaintRatio
//
//  Created by Emiaostein on 13/09/2016.
//  Copyright © 2016 botai. All rights reserved.
//

import UIKit
@IBDesignable
class RuleView: UIView {
    private var rule = Rule.lightRule
    
    override func prepareForInterfaceBuilder() {
        setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    func changeRule() {
        rule = rule.lineWidth == 1 ? Rule.boldRule : Rule.lightRule
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        rule.draw(rect, color: UIColor(Skin.current.mainColor))
    }
}

