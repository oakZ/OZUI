//
//  SSGridView.swift
//  MSSProject
//
//  Created by zx on 2018/8/23.
//  Copyright © 2018年 Rocky. All rights reserved.
//

import UIKit


typealias SSGridViewAction = (_ gridView: SSGridView, _ index: Int) -> Void

class SSGridView: UIView {
    
    var itemSize: CGSize = CGSize(width: 100, height: 100)
    
    var horizontalSpacing: CGFloat = 0
    
    var verticalSpacing: CGFloat = 0
    
    var onTap: SSGridViewAction?
    
    
    // MARK: - public
    func setup(numbers: Int, config: (_ frame: CGRect, _ index: Int) -> UIView) {
        
        guard numbers > 0 else {
            return
        }
        
        let width = self.bounds.width
        var origin = CGPoint.zero
        for index in 0..<numbers {
            
            var frame = CGRect(origin: origin, size: self.itemSize)
            if frame.maxX > width {
                
                origin = CGPoint(x: 0, y: origin.y + self.itemSize.height + self.verticalSpacing)
                frame = CGRect(origin: origin, size: self.itemSize)
                
            }
            
            let view = config(frame, index)
            view.tag = index + 12098
            self.addSubview(view)
            
            origin.x += self.itemSize.width + self.horizontalSpacing
            
            // tap
            view.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.itemClick(tap:)))
            view.addGestureRecognizer(tap)
            
        }
        
        self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: self.frame.width, height: origin.y + self.itemSize.height))
        
    }
    
    // MARK: - private
    
    
    // MARK: - event
    @objc private func itemClick(tap: UIGestureRecognizer) {
        
        guard let onTap = self.onTap else {
            return
        }
        
        guard let view = tap.view else {
            return
        }
        
        onTap(self, view.tag - 12098)
        
    }
}
