//
//  SSTabControl.swift
//  MSSProject
//
//  Created by zx on 2018/10/17.
//  Copyright © 2018年 Rocky. All rights reserved.
//

import UIKit

protocol SSTabControlDelegate {
    func tabDidSelected(index: Int, object: Any?)
}

enum SSTabControlAlignment {
    case center
    case left
    case right
}

class SSTabControl: UIView {
    
    private var titleArray: [String]?
    
    private var scrollView: UIScrollView?
    
    private var indicator: UIImageView?
    
    var delegate: SSTabControlDelegate?

    var interSpacing: CGFloat = 10
    
    var fontForNormal: UIFont = UIFont.systemFont(ofSize: 16)
    
    var fontForSelected: UIFont = UIFont.boldSystemFont(ofSize: 16)
    
    var textColorForNormal: UIColor = UIColor.darkText
    
    var textColorForSelected: UIColor = UIColor.orange
    
    var alignment: SSTabControlAlignment = .center
    
    var selectedIndex: Int? {
        didSet {
            guard oldValue != selectedIndex else {
                return
            }
            
            if oldValue != nil {
                self.updateTab(index: oldValue!, selected: false)
            }
            
            if selectedIndex != nil {
                self.updateTab(index: selectedIndex!, selected: true)
                self.transferIndicatorTo(index: selectedIndex!, animated: true)
            }
            
            self.adjustTheSelectedTabPosition()
            
        }
    }
    
    // MARK: - lifecycle
    override func layoutSubviews() {
        self.setup()
        if let index = self.selectedIndex {
            self.updateTab(index: index, selected: true)
            self.transferIndicatorTo(index: index, animated: false)
        }
        super.layoutSubviews()
    }
    
    // MARK: - public
    func setData(_ data: Any?) {
        guard let array = data as? [String] else {
            return
        }
        self.titleArray = array
    }
    
    // MARK: - private
    private func setup() {
        
        guard let titles = self.titleArray, titles.count > 0 else {
            return
        }
        
        // remove early view
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        let frame = self.frame
        let scroll = UIScrollView.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        let contentView = UIView.init()
//        contentView.backgroundColor = UIColor.yellow
        contentView.tag = 765
        var origin_x: CGFloat = 0
        var contentFrame = CGRect.zero
        for (index, title) in titles.enumerated() {
            let label = UILabel.init()
            label.tag = index + 3898
            label.textColor = self.textColorForNormal
            label.font = self.fontForNormal
            label.text = title
            label.sizeToFit()
            contentView.addSubview(label)
            
            label.center = CGPoint(x: origin_x + label.bounds.width / 2, y: label.bounds.height / 2)
            contentFrame = contentFrame.union(label.frame)
            origin_x += label.bounds.width + self.interSpacing
            
            // add tap
            label.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapHandler(_:)))
            tap.numberOfTapsRequired = 1
            tap.numberOfTouchesRequired = 1
            label.addGestureRecognizer(tap)
            
        }
        
        let contentInset: CGFloat = 8
        if contentFrame.width < scroll.bounds.width {
            var point_x = (scroll.bounds.width - contentFrame.width) / 2
            if self.alignment == .left {
                point_x = contentInset
            }
            contentView.frame = CGRect(x: point_x, y: (scroll.bounds.height - contentFrame.height) / 2, width: contentFrame.width, height: contentFrame.height)
            scroll.contentSize = CGSize(width: scroll.bounds.width, height: max(contentFrame.height, scroll.bounds.height))
        }else {
            contentView.frame = CGRect(x: contentInset, y: (scroll.bounds.height - contentFrame.height) / 2, width: contentFrame.width, height: contentFrame.height)
            scroll.contentSize = CGSize(width: contentFrame.width + 2 * contentInset, height: max(contentFrame.height, scroll.bounds.height))
        }
        
        scroll.addSubview(contentView)
        
        // indicator
        let indicator = UIImageView.init(frame: CGRect(x: 0, y: scroll.bounds.height - 3, width: 20, height: 3))
        indicator.backgroundColor = self.textColorForSelected
        scroll.addSubview(indicator)
        
        self.addSubview(scroll)
        
        self.indicator = indicator
        self.scrollView = scroll
        
    }
    
    private func updateTab(index: Int, selected: Bool) {
        
        guard let contentView = self.scrollView?.viewWithTag(765) else {
            return
        }
        
        guard let tab = contentView.viewWithTag(index + 3898) else {
            return
        }
        
        guard let label = tab as? UILabel else {
            return
        }
        
        let center = label.center
        if selected {
            label.font = self.fontForSelected
            label.textColor = self.textColorForSelected
            label.sizeToFit()
        }else {
            label.font = self.fontForNormal
            label.textColor = self.textColorForNormal
            label.sizeToFit()
        }
        label.center = center
        
    }
    
    private func transferIndicatorTo(index: Int, animated: Bool) {
        
        guard let indicator = self.indicator else {
            return
        }
        
        guard let contentView = self.scrollView?.viewWithTag(765) else {
            return
        }
        
        guard let tab = contentView.viewWithTag(index + 3898) else {
            return
        }
        
        let center = tab.center
        var point = indicator.center
        point.x = contentView.convert(center, to: self.scrollView).x
        indicator.center = point
        
    }
    
    private func adjustTheSelectedTabPosition() {
        
        guard let index = self.selectedIndex else {
            return
        }
        
        guard let scrollView = self.scrollView else {
            return
        }
        
        guard let contentView = scrollView.viewWithTag(765) else {
            return
        }
        
        guard let tab = contentView.viewWithTag(index + 3898) else {
            return
        }
        
        let offsetXWhenStop = scrollView.contentSize.width - scrollView.bounds.width
        let center = contentView.convert(tab.center, to: scrollView)
        let tryOffsetX = center.x - scrollView.bounds.width / 2
        let targetRect = CGRect(x: min(offsetXWhenStop, max(0, tryOffsetX)), y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
        scrollView.scrollRectToVisible(targetRect, animated: true)
        
    }
    
    // MARK: - event
    @objc private func tapHandler(_ tap: UIGestureRecognizer) {
        guard let view = tap.view else {
            return
        }
        
        let index = view.tag - 3898
        if index >= 0, index < self.titleArray!.count {
            self.delegate?.tabDidSelected(index: index, object: nil)
        }
        
    }

}

class SSTabScrollView: UIView {
    
    
    
}
