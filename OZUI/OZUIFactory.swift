//
//  OZUIFactory.swift
//  ZOwn
//
//  Created by zx on 2017/7/4.
//  Copyright © 2017年 oak. All rights reserved.
//

import UIKit

class OZUIFactory: NSObject {
    
    // MARK: -
    
    static func createGradientImage(size: CGSize, gradientColors: [UIColor], start: CGPoint, end: CGPoint, cornerRadius: CGFloat?, borderColor: UIColor?, roundCorners: UIRectCorner?) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        let rect = CGRect.init(origin: CGPoint.zero, size: size).insetBy(dx: 1, dy: 1)
        var path: UIBezierPath?
        if let radius = cornerRadius {
            
            var rrr = min(rect.width / 2, rect.height / 2)
            rrr = min(rrr, radius)
            path = UIBezierPath.init(roundedRect: rect, byRoundingCorners: roundCorners ?? [.allCorners], cornerRadii: CGSize(width: rrr, height: rrr))
            
        }else {
            path = UIBezierPath.init(rect: rect)
        }
        
        // gradient
        context?.saveGState()
        path?.addClip()
        var colors = [CGColor]()
        for color in gradientColors {
            colors.append(color.cgColor)
        }
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)
        if gradient != nil {
            
            context?.drawLinearGradient(gradient!, start: start, end: end, options: [])
            
        }
        context?.restoreGState()
        
        // border
        if let strokeColor = borderColor {
            strokeColor.setStroke()
            context?.setLineWidth(1)
            path?.stroke()
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    static func createImage(size: CGSize, backgroundColor: UIColor, cornerRadius: CGFloat?, borderColor: UIColor?, roundCorners: UIRectCorner?) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let rect = CGRect.init(origin: CGPoint.zero, size: size).insetBy(dx: 1, dy: 1)
        var path: UIBezierPath?
        
        // background color
        backgroundColor.setFill()
        if let radius = cornerRadius {
            
            var rrr = min(rect.width / 2, rect.height / 2)
            rrr = min(rrr, radius)
            path = UIBezierPath.init(roundedRect: rect, byRoundingCorners: roundCorners ?? [.allCorners], cornerRadii: CGSize(width: rrr, height: rrr))
            path?.fill()
            
        }else {
            path = UIBezierPath.init(rect: rect)
            path?.fill()
        }
        
        // border
        if let strokeColor = borderColor {
            strokeColor.setStroke()
            path?.stroke()
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    /// 气泡图
    ///
    /// - Parameters:
    ///   - style: 样式，目前支持 1: 左上，2: 左下，3: 右下，4: 右上
    ///   - size: 图片大小
    ///   - triangleHeight: 指示标识高度
    ///   - triangleOffset: 指示标识位置
    ///   - color: 颜色
    ///   - radius: 圆角半径
    /// - Returns: 气泡图片
    static func bubbleImage(style: Int, size: CGSize, triangleHeight: CGFloat, triangleOffset: CGFloat? = nil, color: UIColor? = nil, radius: CGFloat? = nil) -> UIImage? {
        let colorForeground = color ?? UIColor.orange
        let r = radius ?? (size.height - triangleHeight) / 2
        let offset = triangleOffset ?? r
        let image = self.bubbleImage(style: style, size: size, triangleHeight: triangleHeight, triangleOffset: offset, color: colorForeground, radius: r)
        return image
        
    }
    
    private static func bubbleImage(style: Int, size: CGSize, triangleHeight: CGFloat, triangleOffset: CGFloat, color: UIColor, radius: CGFloat) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        // create triangle
        let length = triangleHeight / sin(CGFloat.pi / 4)
        let peakRound: CGFloat = 1
        let triangle = UIBezierPath.init()
        triangle.move(to: CGPoint(x: 0, y: triangleHeight))
        triangle.addLine(to: CGPoint(x: length / 2 - peakRound, y: peakRound))
        triangle.addQuadCurve(to: CGPoint(x: length / 2 + peakRound, y: peakRound), controlPoint: CGPoint(x: length / 2, y: 0))
        triangle.addLine(to: CGPoint(x: length, y: triangleHeight))
        triangle.close()
        triangle.apply(CGAffineTransform.init(translationX: triangleOffset, y: 0))
        
        // create rect
        let rect = UIBezierPath.init(roundedRect: CGRect(x: 0, y: triangleHeight, width: size.width, height: size.height - triangleHeight), cornerRadius: radius)
        
        // combine
        triangle.append(rect)
        
        // draw
        let context = UIGraphicsGetCurrentContext()
        
        switch style {
        case 1:
            context?.saveGState()
            color.setFill()
            triangle.fill()
            context?.restoreGState()
        case 2:
            context?.saveGState()
            context?.translateBy(x: 0, y: size.height)
            context?.scaleBy(x: 1, y: -1)
            color.setFill()
            triangle.fill()
            context?.restoreGState()
        case 3:
            context?.saveGState()
            context?.translateBy(x: size.width, y: size.height)
            context?.scaleBy(x: -1, y: -1)
            color.setFill()
            triangle.fill()
            context?.restoreGState()
        case 4:
            context?.saveGState()
            context?.translateBy(x: size.width, y: 0)
            context?.scaleBy(x: -1, y: 1)
            color.setFill()
            triangle.fill()
            context?.restoreGState()
        default:
            break
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    static func cornerImage(size: CGSize, color: UIColor?, radius: CGFloat?, corners: UIRectCorner?) -> UIImage? {
        let _color = color ?? UIColor.orange
        let _radius = radius ??  0
        let _corners = corners ?? .allCorners
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let path = UIBezierPath.init(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), byRoundingCorners: _corners, cornerRadii: CGSize(width: _radius, height: _radius))
        _color.setFill()
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - 各种Tag
    
    /// 生成标签，返回UIImage对象
    ///
    /// - Parameters:
    ///   - text: 标签文字内容
    ///   - fontSize: 字体大小
    ///   - backgroundColor: 标签背景颜色，默认 UIColor.blue
    ///   - textInset: 文字与标签边界的间距，默认 UIEdgeInsetsMake(3, 4, 3, 4)
    ///   - attributes: 标签文字的属性，（比如字体颜色，默认白色）
    ///   - borderColor: 边框颜色
    ///   - radius: 圆角大小，（全圆角，传CGFloat.greatestFiniteMagnitude）
    ///   - icon: 标签icon
    /// - Returns: 定制的标签
    
    class func tag(text: String, fontSize: CGFloat, backgroundColor: UIColor? = nil, textInset: UIEdgeInsets? = nil, attributes: Dictionary<String, Any>? = nil, borderColor: UIColor? = nil, radius: CGFloat? = nil, byRoundingCorners: UIRectCorner? = nil, icon: UIImage? = nil) -> UIImage? {
        
        // default params
        let defaultAttributes = [NSFontAttributeName : UIFont.systemFont(ofSize: fontSize), NSForegroundColorAttributeName : UIColor.white]
        let defaultBackgroundColor = UIColor.blue
        let defaultInset = UIEdgeInsetsMake(3, 4, 3, 4)
        
        var textAttributes = attributes ?? defaultAttributes
        textAttributes.updateValue(UIFont.systemFont(ofSize: fontSize), forKey: NSFontAttributeName)
        let bgColor = backgroundColor ?? defaultBackgroundColor
        let inset = textInset ?? defaultInset
        
        let image = self.normalTag(text: text, textAttributes: textAttributes, textInset: inset, backgroundColor: bgColor, radius: radius, byRoundingCorners: byRoundingCorners ?? [.allCorners], borderColor: borderColor, icon: icon)
        return image
        
    }
    
    private class func normalTag(text: String, textAttributes: Dictionary<String, Any>, textInset: UIEdgeInsets, backgroundColor: UIColor, radius: CGFloat?, byRoundingCorners: UIRectCorner, borderColor: UIColor?, icon: UIImage?) -> UIImage? {
        
        guard let font = textAttributes[NSFontAttributeName] as? UIFont else {
            return nil
        }
        
        // caculate the size
        let lineHeight = font.lineHeight
        let textSize = text.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: lineHeight), options: [.usesFontLeading, .usesLineFragmentOrigin, .usesDeviceMetrics], attributes: textAttributes, context: nil).size
        let size = CGSize(width: ceil(textSize.width + textInset.left + textInset.right), height: ceil(lineHeight + textInset.top + textInset.bottom))
        
        // creat the UIImage
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let rect = CGRect.init(origin: CGPoint.zero, size: size).insetBy(dx: 1, dy: 1)
        var path: UIBezierPath?
        
        // background color
        backgroundColor.setFill()
        if radius == nil {
            path = UIBezierPath.init(rect: rect)
            path?.fill()
        }else {
            var rrr = min(rect.width / 2, rect.height / 2)
            rrr = min(rrr, radius!)
            path = UIBezierPath.init(roundedRect: rect, byRoundingCorners: byRoundingCorners, cornerRadii: CGSize(width: rrr, height: rrr))
            path?.fill()
            
        }
        
        // border
        if let strokeColor = borderColor {
            strokeColor.setStroke()
            path?.stroke()
        }
        
        // icon & text
        if let iconYes = icon {
            // draw icon
            let whRatio = iconYes.size.width / iconYes.size.height
            let iconHeight = min(iconYes.size.height, size.height)
            iconYes.draw(in: CGRect(x: textInset.right, y: (size.height - iconHeight) / 2, width: iconHeight * whRatio, height: iconHeight))
            // draw text
            text.draw(at: CGPoint(x: textInset.left, y: textInset.top), withAttributes: textAttributes)
        }else {
            // draw text
            text.draw(at: CGPoint(x: textInset.left, y: textInset.top), withAttributes: textAttributes)
        }
        
        
        
        let tag = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return tag
    }

}
