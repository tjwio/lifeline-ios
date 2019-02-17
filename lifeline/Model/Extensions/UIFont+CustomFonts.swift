//
//  UIFont+CustomFonts.swift
//  friction
//
//  Created by Tim Wong on 3/8/18.
//  Copyright © 2018 tjwio. All rights reserved.
//

import UIKit

extension UIFont {
    //MARK: basic fonts
    
    public class func avenirRegular(size: CGFloat) -> UIFont? {
        return UIFont(name: "AvenirNext-Regular", size: size)
    }
    
    public class func avenirMedium(size: CGFloat) -> UIFont? {
        return UIFont(name: "AvenirNext-Medium", size: size)
    }
    
    public class func avenirDemi(size: CGFloat) -> UIFont? {
        return UIFont(name: "AvenirNext-DemiBold", size: size)
    }
    
    public class func avenirBold(size: CGFloat) -> UIFont? {
        return UIFont(name: "AvenirNext-Bold", size: size)
    }
    
    public class func avenirItalic(size: CGFloat) -> UIFont? {
        return UIFont(name: "AvenirNext-Italic", size: size)
    }
    
    public class func avenirLight(size: CGFloat) -> UIFont? {
        return UIFont(name: "AvenirNext-UltraLight", size: size)
    }
    
    public class func avenirUltraLightItalic(size: CGFloat) -> UIFont? {
        return UIFont(name: "AvenirNext-UltraLightItalic", size: size)
    }
    
    public class func cocogooseRegular(size: CGFloat) -> UIFont? {
        return UIFont(name: "Cocogoose", size: size)
    }
    
    //MARK: headers
    
    public class func mainHeader() -> UIFont? {
        return avenirMedium(size: 24.0)
    }
    
    public class func mediumHeader() -> UIFont? {
        return avenirMedium(size: 20.0)
    }
    
    public class func smallheader() -> UIFont? {
        return avenirMedium(size: 16.0)
    }
    
    //MARK: regular
    
    public class func regularText() -> UIFont? {
        return avenirRegular(size: 16.0)
    }
    
    //MARK: detail
    
    public class func detailText() -> UIFont? {
        return avenirRegular(size: 14.0)
    }
}
