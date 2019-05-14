//
//  OZAlertView.swift
//  ZOwn
//
//  Created by zx on 2017/7/6.
//  Copyright © 2017年 oak. All rights reserved.
//

import UIKit

// MARK: - RSAlertView

struct OZAlertViewTheme {
    
    //
    static let ALERT_WIDTH: CGFloat = SCREEN_WIDTH - 81
    static let BADGE_ADJUST_HEIGHT: CGFloat = 41
    static let CORNER_RADIUS: CGFloat = 4
    
    // text
    static let TEXT_EDGE_INSET: UIEdgeInsets = UIEdgeInsetsMake(27, 16, 27, 16)
    
    // line
    
    static let LINE_BACKGROUND_COLOR_DEFAULT: UIColor = UIColor.colorWithRGB(0xe5e5e5)
    
    // button
    static let BUTTON_HEIGHT: CGFloat = 52
    static let BUTTON_LEFT_BACKGROUND_COLOR_DEFAULT: UIColor = UIColor.colorWithRGB(0xffffff)
    static let BUTTON_RIGHT_BACKGROUND_COLOR_DEFAULT: UIColor = UIColor.colorWithRGB(0xff4140)
    static let BUTTON_LEFT_TITLE_COLOR_DEFAULT: UIColor = UIColor.colorWithRGB(0x333333)
    static let BUTTON_RIGHT_TITLE_COLOR_DEFAULT: UIColor = UIColor.colorWithRGB(0xffffff)
    
}

typealias OZAlertAction = (_ sender: UIView) -> Void

class OZAlertView: UIView {
    
    private var badgeView: UIView?
    
    private var crossMark: UIImageView?
    
    private var dialogView: UIView = UIView()
    
    private var actions: [String : OZAlertAction] = Dictionary()
    
    private var contentViews: [UIView] = Array()
    
    private var buttons: [UIButton] = Array()
    
    private var actionTagNext: Int = 9087
    
    // MARK: - lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - public
    func show(badge: Bool = false, cross: Bool = false) {
        //
        self.setBadgeShown(badge)
        self.setCrossMarkShown(cross)
        self.setup()
        OZAlertController.alert(container: self)
    }
    
    func close() {
        
        OZAlertController.close()
        
    }
    
    func addMessage(_ message: String) {
        //
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = message
        
        // calculate the frame
        let width = OZAlertViewTheme.ALERT_WIDTH - OZAlertViewTheme.TEXT_EDGE_INSET.left - OZAlertViewTheme.TEXT_EDGE_INSET.right
        let size = label.sizeThatFits(CGSize.init(width: width, height: CGFloat.greatestFiniteMagnitude))
        label.frame = CGRect.init(x: OZAlertViewTheme.TEXT_EDGE_INSET.left, y: 0, width: width, height: size.height + OZAlertViewTheme.TEXT_EDGE_INSET.top + OZAlertViewTheme.TEXT_EDGE_INSET.bottom)
        
        self.addCustomView(label)
    }
    
    func addAttributedMessage(_ message: NSAttributedString) {
        //
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = UIColor.white
        label.textAlignment = .center
        label.attributedText = message
        
        // calculate the frame
        let width = OZAlertViewTheme.ALERT_WIDTH - OZAlertViewTheme.TEXT_EDGE_INSET.left - OZAlertViewTheme.TEXT_EDGE_INSET.right
        let size = label.sizeThatFits(CGSize.init(width: width, height: CGFloat.greatestFiniteMagnitude))
        label.frame = CGRect.init(x: OZAlertViewTheme.TEXT_EDGE_INSET.left, y: 0, width: width, height: size.height + OZAlertViewTheme.TEXT_EDGE_INSET.top + OZAlertViewTheme.TEXT_EDGE_INSET.bottom)
        
        self.addCustomView(label)
    }
    
    
    /// 添加自定义view
    ///
    /// - Parameters:
    ///   - view: 自定义view
    ///   - action: 事件响应callback
    func addCustomView(_ view: UIView, action: OZAlertAction? = nil) {
        
        self.contentViews.append(view)
        
        if action != nil {
            let tag = self.uniqueTag()
            view.tag = tag
            self.actions.updateValue(action!, forKey: String(tag))
            self.addTapHandlerFor(view: view)
        }
        
    }
    
    
    /// 添加弹窗按钮，暂时最多有两个按钮，按照添加顺序，从左至右排列。默认配置，左白右红。
    ///
    /// - Parameters:
    ///   - title: 按钮title
    ///   - titleColor: 按钮的titleColor
    ///   - backgroundColor: 按钮的背景色
    ///   - action: 按钮的响应事件
    func addButton(_ title: String, titleColor: UIColor? = nil, backgroundColor: UIColor? = nil, action: OZAlertAction? = nil) {
        //
        let index = self.buttons.count
        
        var button = self.createButtonWithTitle(title, titleColor: titleColor, backgroundColor: backgroundColor)
        
        if index == 1 {
            // 第二个button，默认红底白字
            button = self.createButtonWithTitle(title, titleColor: titleColor ?? OZAlertViewTheme.BUTTON_RIGHT_TITLE_COLOR_DEFAULT, backgroundColor: backgroundColor ?? OZAlertViewTheme.BUTTON_RIGHT_BACKGROUND_COLOR_DEFAULT)
        }
        
        if action != nil {
            let tag = self.uniqueTag()
            button.tag = tag
            self.actions.updateValue(action!, forKey: String(tag))
        }
        
        self.buttons.append(button)
        
    }
    
    // MARK: - private
    private func setup() {
        
        var rect = CGRect.zero
        for view in self.contentViews {
            rect = rect.union(view.frame)
        }
        
        var dialogSize = CGSize.init(width: OZAlertViewTheme.ALERT_WIDTH, height: rect.height + OZAlertViewTheme.BUTTON_HEIGHT)
        
        // badge
        if self.badgeView != nil {
            self.addSubview(self.badgeView!)
            self.badgeView!.center = CGPoint.init(x: dialogSize.width / 2, y: 0)
            
            dialogSize.height += OZAlertViewTheme.BADGE_ADJUST_HEIGHT
            //
            for subview in self.contentViews {
                var frame = subview.frame
                frame = frame.offsetBy(dx: 0, dy: OZAlertViewTheme.BADGE_ADJUST_HEIGHT)
                subview.frame = frame
            }
        }
        
        self.dialogView.frame = CGRect.init(x: 0, y: 0, width: dialogSize.width, height: dialogSize.height)
        
        // content views
        for subview in self.contentViews {
            self.dialogView.addSubview(subview)
        }
        
        // cross mark
        if let cross = self.crossMark {
            //
            self.dialogView.addSubview(cross)
            cross.center = CGPoint.init(x: OZAlertViewTheme.ALERT_WIDTH - 20, y: 20)
        }
        
        // line
        let line = UIImageView.init(frame: CGRect.init(x: 0, y: dialogSize.height - OZAlertViewTheme.BUTTON_HEIGHT - PX_TO_PT(1), width: dialogSize.width, height: PX_TO_PT(1)))
        line.backgroundColor = OZAlertViewTheme.LINE_BACKGROUND_COLOR_DEFAULT
        self.dialogView.addSubview(line)
        
        // button
        self.placeButtons()
        
        self.dialogView.backgroundColor = UIColor.white
        self.dialogView.layer.cornerRadius = OZAlertViewTheme.CORNER_RADIUS
        self.dialogView.clipsToBounds = true
        self.addSubview(self.dialogView)
        
        if self.badgeView != nil {
            self.bringSubview(toFront: self.badgeView!)
        }
        
        //
        self.frame.size = dialogSize
        //        self.addTapHandlerFor(view: self)
        
    }
    
    private func createButtonWithTitle(_ title: String, titleColor: UIColor? = nil, backgroundColor: UIColor? = nil) -> UIButton {
        
        let button = UIButton.init(type: .custom)
        
        button.setTitleColor(titleColor ?? OZAlertViewTheme.BUTTON_LEFT_TITLE_COLOR_DEFAULT, for: .normal)
        button.backgroundColor = backgroundColor ?? OZAlertViewTheme.BUTTON_LEFT_BACKGROUND_COLOR_DEFAULT
        button.titleLabel?.backgroundColor = backgroundColor ?? OZAlertViewTheme.BUTTON_LEFT_BACKGROUND_COLOR_DEFAULT
        
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        self.addTapHandlerFor(view: button)
        
        return button
    }
    
    private func addTapHandlerFor(view: UIView) {
        
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapHandler(_:)))
        view.addGestureRecognizer(tap)
        
    }
    
    private func placeButtons() {
        
        let count = self.buttons.count
        let parent = self.dialogView
        
        if count == 1, let button = self.buttons.first {
            
            button.frame = CGRect.init(x: 0, y: parent.frame.size.height - OZAlertViewTheme.BUTTON_HEIGHT, width: parent.frame.size.width, height: OZAlertViewTheme.BUTTON_HEIGHT)
            parent.addSubview(button)
            
            return
        }
        
        if count == 2 {
            
            let width = parent.frame.size.width / 2
            
            for (index, button) in self.buttons.enumerated() {
                
                button.frame = CGRect.init(x: CGFloat(index) * width, y: parent.frame.size.height - OZAlertViewTheme.BUTTON_HEIGHT, width: width, height: OZAlertViewTheme.BUTTON_HEIGHT)
                parent.addSubview(button)
                
            }
            
            return
        }
        
    }
    
    private func setCrossMarkShown(_ shown: Bool) {
        //
        guard shown else {
            self.crossMark = nil
            return
        }
        
        let image = UIImage.init(named: "alert_close_icon.png")
        self.crossMark = UIImageView.init(image: image)
        self.addTapHandlerFor(view: self.crossMark!)
        
    }
    
    private func setBadgeShown(_ shown: Bool) {
        //
        guard shown else {
            self.badgeView = nil
            return
        }
        let image = UIImage.init(named: "alert_badge.png")
        self.badgeView = UIImageView.init(image: image)
        
    }
    
    private func uniqueTag() -> Int {
        
        self.actionTagNext += 1
        
        return self.actionTagNext
    }
    
    // MARK: - tap Handler
    
    @objc private func tapHandler(_ tap: UITapGestureRecognizer) {
        
        self.close()
        
        guard let tapView = tap.view else {
            return
        }
        
        let key = String(tapView.tag)
        if let action = self.actions[key] {
            action(tapView)
        }
        
    }
}

// MARK: - RSAlertController

class OZAlertController: UIView {
    
    private var containerView: UIView?
    
    // MARK: - shared
    static let sharedInstance: OZAlertController = {
        
        let view = OZAlertController.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        return view
        
    }()
    
    // MARK: - public
    class func alert(container: UIView) {
        sharedInstance.containerView = container
        OZAlertController.show()
    }
    
    class func close() {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            sharedInstance.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
            sharedInstance.containerView?.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)
            sharedInstance.containerView?.layer.opacity = 0
            
        }) { (completion) in
            sharedInstance.removeFromSuperview()
            sharedInstance.containerView = nil
        }
        
    }
    
    // MARK: - private
    private class func show() {
        
        guard let containerView = sharedInstance.containerView else {
            return
        }
        
        // container
        sharedInstance.addSubview(containerView)
        containerView.center = CGPoint.init(x: SCREEN_WIDTH / 2, y: SCREEN_HEIGHT / 2)
        
        UIApplication.shared.windows.first?.addSubview(sharedInstance)
        
        sharedInstance.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        containerView.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)
        containerView.layer.opacity = 0.5
        
        // animation
        UIView.animate(withDuration: 0.2) {
            //
            sharedInstance.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
            containerView.layer.opacity = 1.0
            containerView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
            
        }
        
    }
    
}
