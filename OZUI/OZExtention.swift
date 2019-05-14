//
//  OZExtention.swift
//  ZOwn
//
//  Created by zx on 2017/7/4.
//  Copyright © 2017年 oak. All rights reserved.
//

import UIKit
    
extension UIImage {
        
    class func imageWithColor(_ color: UIColor, size: CGSize, radius: CGFloat) -> UIImage {
        
        //        UIGraphicsBeginImageContext(size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        let path = UIBezierPath.init(roundedRect: rect, cornerRadius: radius)
        color.setFill()
        path.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return image
        
    }
    
}


extension UIFont {
    
    // the font name should be your app's font
    class func appFont(ofSize: CGFloat, adjust: Bool) -> UIFont {
        
        var font: UIFont?
        
        if adjust {
            
            font = UIFont.init(name: "DINPro-Regular", size: ofSize * SCREEN_SCALE)
            
        }else {
            
            font = UIFont.init(name: "DINPro-Regular", size: ofSize)
            
        }
        
        if font == nil {
            
            font = UIFont.systemFont(ofSize: ofSize, adjust: adjust)
            
        }
        
        return font!
    }
    
    class func systemFont(ofSize: CGFloat, adjust: Bool) -> UIFont {
        
        if adjust {
            return UIFont.systemFont(ofSize: ofSize * SCREEN_SCALE)
        }
        return UIFont.systemFont(ofSize: ofSize)
    }
    
    class func boldSystemFont(ofSize: CGFloat, adjust: Bool) -> UIFont {
        
        if adjust {
            return UIFont.boldSystemFont(ofSize: ofSize * SCREEN_SCALE)
        }
        return UIFont.boldSystemFont(ofSize: ofSize)
    }
    
}

extension UIColor {
    class func colorWithRGB(_ rgb: Int) -> UIColor {
        return UIColor.init(red: CGFloat(((rgb >> 16) & 0xFF) / 255), green: CGFloat(((rgb >> 8) & 0xFF) / 255), blue: CGFloat((rgb & 0xFF) / 255), alpha: 1)
    }
}
