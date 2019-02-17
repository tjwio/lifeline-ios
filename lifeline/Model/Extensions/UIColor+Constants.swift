//
//  UIColor+Constants.swift
//  lifeline
//
//  Created by Tim Wong on 2/16/19.
//  Copyright © 2019 tjwio. All rights reserved.
//

import UIKit

extension UIColor {
    public convenience init(hexColor: UInt, alpha: CGFloat = 1.0) {
        self.init(red: ((CGFloat)((hexColor & 0xFF0000) >> 16))/255.0,
                  green: ((CGFloat)((hexColor & 0x00FF00) >>  8))/255.0,
                  blue: ((CGFloat)((hexColor & 0x0000FF) >>  0))/255.0,
                  alpha: alpha);
    }
    
    struct Red {
        static var normal: UIColor {
            return UIColor(hexColor: 0x8C464C)
        }
    }
    
    struct Orange {
        static var normal: UIColor {
            return UIColor(hexColor: 0x4F3832)
        }
    }
    
    struct Yellow {
        static var normal: UIColor {
            return UIColor(hexColor: 0x825B46)
        }
    }
}
