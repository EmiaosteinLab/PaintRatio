//
//  SkinConfig.swift
//  PaintRatio
//
//  Created by Emiaostein on 13/09/2016.
//  Copyright © 2016 botai. All rights reserved.
//

import Foundation
import UIKit

extension ViewController: Skinable {
    
    override func awakeFromNib() {
        registerSkin()
    }
    
    func updateTo(skin: Skin, animated: Bool) {
        view.backgroundColor = UIColor(skin.mainColor)
    }
}

extension RuleView: Skinable {
    override func awakeFromNib() {
        registerSkin()
        updateTo(skin: Skin.current, animated: false)
    }
    
    func updateTo(skin: Skin, animated: Bool) {
        setNeedsDisplay()
    }
}
