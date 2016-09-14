//
//  Rule.swift
//  PaintRatio
//
//  Created by Emiaostein on 13/09/2016.
//  Copyright © 2016 botai. All rights reserved.
//

import Foundation

struct Rule {

    let lineWidth: Int
    let spliter: (x: Int, y: Int)
    
    static var defaultRule: Rule {
        return Rule(lineWidth: 2, spliter: (2, 2))
    }
}

// MARK: - Draw Rule
import UIKit

extension Rule {
    func draw(_ rect: CGRect, color: UIColor) {
        let dx = rect.width / CGFloat(spliter.x)
        let dy = rect.height / CGFloat(spliter.y)
        
        for i in 1..<spliter.x {
            let start = CGPoint(x: dx * CGFloat(i), y: 0)
            let end = CGPoint(x: dx * CGFloat(i), y: rect.height)
            drawLine(start: start, end: end, color: color)
        }
        
        for j in 1..<spliter.y {
            let start = CGPoint(x: 0, y: dy * CGFloat(j))
            let end = CGPoint(x: rect.width, y: dy * CGFloat(j))
            drawLine(start: start, end: end, color: color)
        }
    }
    
    private func drawLine(start: CGPoint, end: CGPoint, color: UIColor) {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: start.x, y: start.y))
        bezierPath.addLine(to: CGPoint(x: end.x, y: end.y))
        color.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()
    }
}
