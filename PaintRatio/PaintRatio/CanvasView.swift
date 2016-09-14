//
//  CanvasView.swift
//  PaintRatio
//
//  Created by Emiaostein on 14/09/2016.
//  Copyright © 2016 botai. All rights reserved.
//

import UIKit

class CanvasView: UIView {
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    var imageView: UIImageView {
        return viewWithTag(1000) as! UIImageView
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
