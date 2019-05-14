//
//  OZPullRefreshHandler.swift
//  MSSProject
//
//  Created by zx on 2018/4/18.
//  Copyright © 2018年 oak. All rights reserved.
//

import UIKit

protocol OZPullRefreshControl {
    func update(progress: Double)
    func startLoading()
    func reset()
}

typealias OZPullRefreshAction = (_ sender: UIScrollView) -> Void

let DROP_HEIGHT = CGFloat(80)

class OZPullRefreshHandler: NSObject {
    
    private var observerContextForMe = "observerContextForMe"
    
    private var scrollView: UIScrollView? {
        willSet {
            if newValue != scrollView {
                scrollView?.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), context: &observerContextForMe)
                newValue?.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [], context: &observerContextForMe)
            }
        }
    }
    
    private var originalContentInset: UIEdgeInsets?
    
    private var pullDownRefreshControl: (UIView & OZPullRefreshControl)? {
        willSet {
            if pullDownRefreshControl != nil {
                pullDownRefreshControl?.removeFromSuperview()
            }
        }
    }
    
    private var pullDownAction: OZPullRefreshAction?
    
    private var pullUpAction: OZPullRefreshAction?
    
    private var isLoading: Bool = false
    
    var enablePullUp: Bool = false
    
    var enablePullDown: Bool = false
    
    // MARK: - lifecycle
    deinit {
        print("===[\(self.description)  dealloc]===")
        self.scrollView?.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), context: &observerContextForMe)
        self.pullDownRefreshControl?.removeFromSuperview()
    }
    
    // MARK: - public
    func applyTo(_ scrollView: UIScrollView, pullDownAction: OZPullRefreshAction?, pullUpAction: OZPullRefreshAction?) {
        
        self.scrollView = scrollView
        self.originalContentInset = scrollView.contentInset
        
        if pullDownAction != nil {
            self.pullDownAction = pullDownAction!
            self.addPullDownAccessory()
            self.enablePullDown = true
        }
        
        if pullUpAction != nil {
            self.pullUpAction = pullUpAction!
            self.addPullUpAccessory()
            self.enablePullUp = true
        }
        
    }
    
    func pullDownFinished(animated: Bool) {
        //
        if animated == false {
            
            self.pullDownRefreshControl?.reset()
            self.resetPullDownStatus(false)
        }else {
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.8) {
                //
                self.pullDownRefreshControl?.reset()
                self.resetPullDownStatus(false)
            }
        }
        
    }
    
    func pullUpFinished(animated: Bool) {
        //
        self.resetPullUpStatus(false)
        
    }
    
    // MARK: - private
    private func resetPullDownStatus(_ loading: Bool) {
        
        self.isLoading = loading
        
        guard let scroll = self.scrollView else {
            return
        }
        
        guard let inset = self.originalContentInset else {
            return
        }
        
        if loading {
            UIView.animate(withDuration: 0.2) {
                scroll.contentInset = UIEdgeInsetsMake(inset.top + DROP_HEIGHT, inset.left, inset.bottom, inset.right)
            }
        }else {
            UIView.animate(withDuration: 0.2) {
                scroll.contentInset = inset
            }
        }
    }
    
    private func resetPullUpStatus(_ loading: Bool) {
        
        self.isLoading = loading
        
    }
    
    private func addPullDownAccessory() {
        
        guard let scrollView = self.scrollView else {
            return
        }
        
        let pullDownRefreshControl = OZPullDownControl.init(frame: CGRect(x: 0, y: -65, width: SCREEN_WIDTH, height: 65))
        
        scrollView.addSubview(pullDownRefreshControl)
        
        self.pullDownRefreshControl = pullDownRefreshControl
        
    }
    
    private func addPullUpAccessory() {
        
    }

    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //
        guard context == &self.observerContextForMe else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if #keyPath(UIScrollView.contentOffset) == keyPath {
            
            guard let scrollView = self.scrollView else {
                return
            }
            
            guard self.isLoading == false else {
                return
            }
            
            let offset = scrollView.contentOffset.y
            
            self.pullDownRefreshControl?.update(progress: Double(offset / -DROP_HEIGHT))
            
            if enablePullDown && scrollView.isDragging == false && self.pullDownAction != nil && offset < -DROP_HEIGHT {
                
                self.resetPullDownStatus(true)
                
                self.pullDownRefreshControl?.startLoading()
                self.pullDownAction!(scrollView)
                
                return
                
            }
            
            let upHappeningY = max(scrollView.contentSize.height - scrollView.bounds.height - 5, 0)
            if enablePullUp && scrollView.isDragging == false && self.pullUpAction != nil && offset > upHappeningY {
                
                self.resetPullUpStatus(true)
                
                self.pullUpAction!(scrollView)
                
                return
            }
            
        }
    }
}
