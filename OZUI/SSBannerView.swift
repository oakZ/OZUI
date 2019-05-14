//
//  SSBannerView.swift
//  MSSProject
//
//  Created by zx on 2018/4/19.
//  Copyright © 2018年 Rocky. All rights reserved.
//

import UIKit

typealias SSBannerAction = (_ sender: Any?, _ index: Int, _ object: Any?) -> Void

class SSBannerView: UIView {
    
    private var data: Any?

    private var scrollPresenter: SSPagingScroll? {
        didSet {
            // bind event
            scrollPresenter?.didTurnToPage = { [weak self] (sender, index) in
                
                var obj: Any?
                if let array = self?.data as? [Any], index < array.count {
                    obj = array[index]
                }
                
                self?.onPageIndexChanged(sender: sender, current: index, object: obj)
            }
        }
    }
    
    private var backgroundView: UIImageView?
    
    private var darkMaskView: UIImageView?
    
    private var titleView: UIView?
    
    private var titleLabel: UILabel?
    
    private var adTag: UIImageView?
    
    var turnToPageHandler: SSBannerAction?
    
    // MARK: - lifecycle
    deinit {
        self.scrollPresenter?.removeTimer()
    }
    
    // MARK: - create instance
    
    
    // MARK: - tools
    
    // MARK: - private
    
    func addTitleView(frame: CGRect) {
        
        let view = UIView.init(frame: frame)
        self.addSubview(view)
        
        // title label
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 23)
        label.textColor = UIColor.white
        view.addSubview(label)
        
        // advertisement tag
        let tag = OZUIFactory.tag(text: "广告", fontSize: 8, backgroundColor: UIColor.clear, textInset: UIEdgeInsets(top: 1, left: 2, bottom: 2, right: 2), borderColor: UIColor.white, radius: 2)
        let imageView = UIImageView.init(image: tag)
        let tagSize = imageView.bounds.size
        imageView.frame = CGRect(x: frame.width - tagSize.width - 10, y: frame.height - tagSize.height - 10, width: tagSize.width, height: tagSize.height)
        imageView.isHidden = true
        view.addSubview(imageView)
        
        self.titleView = view
        self.titleLabel = label
        self.adTag = imageView
        
    }
    
    private func configTitleView(object: Any?) {
        guard let view = self.titleView else {
            return
        }
        
        guard let label = self.titleLabel else {
            return
        }
        
//        guard let tag = self.adTag else {
//            return
//        }
        
        guard let title = object as? String else {
            return
        }
        
        label.text = title
        label.sizeToFit()
        let height = label.bounds.height
        label.frame = CGRect(x: 16, y: view.bounds.height - height - 10, width: view.bounds.width - 16 - 42, height: height)
//        tag.isHidden = !model.is_ad
    }
    
    // MARK: - event
    private func onPageIndexChanged(sender: Any?, current index: Int, object: Any?) {
        
        //
        self.configTitleView(object: object)
        
        if let action = self.turnToPageHandler {
            action(sender, index, object)
        }
        
    }
    
    // MARK: - public
    
    func addTapHandler(action: @escaping SSBannerAction) {
        //
        self.scrollPresenter?.onTap = { [unowned self] (sender, index) in
            let obj = (self.data as? [Any])?[index]
            action(self.scrollPresenter, index, obj)
            
        }
        
    }
    
    func setBackgroundAlpha(_ alpha: CGFloat) {
        self.backgroundView?.alpha = alpha
    }
    
}

typealias SSPagingScrollAction = (_ sender: Any?, _ index: Int) -> Void
typealias SSPagingScrollItemCreate = ((_ index: Int, _ object: Any?) -> UIView)

class SSPagingScroll: NSObject, UIScrollViewDelegate {
    
    private var containerView: UIView = UIView()
    
    private var scrollView: UIScrollView = {

        let scrollView = UIScrollView()

        // close page & set inset zero
        scrollView.isPagingEnabled = false
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false

        return scrollView

    }()
    
    private var velocity = CGPoint.zero
    
    private(set) var currentPage: Int = 0 {
        didSet {
            
            guard oldValue != self.currentPage else {
                return
            }
            
            self.pageControl?.currentPage = self.currentPage
            
            self.didTurnToPageCallback()
            
        }
    }
    
    private var autoPlayTimer: Timer?
    
    var autoPlay: Bool = false {
        didSet {
            
            self.autoPlayTimer?.invalidate()
            self.autoPlayTimer = nil
            
            if self.autoPlay {
                self.autoPlayTimer = Timer.init(timeInterval: 4.0, target: self, selector: #selector(autoScrollNext), userInfo: nil, repeats: true)
//                self.autoPlayTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(autoScrollNext), userInfo: nil, repeats: true)
                RunLoop.current.add(self.autoPlayTimer!, forMode: .commonModes)
            }else {
                self.autoPlayTimer?.invalidate()
                self.autoPlayTimer = nil
            }
        }
    }
    
    var itemSize = CGSize.zero {
        didSet {
            if oldValue.equalTo(itemSize) == false {
                self.setup()
            }
        }
    }
    
    var itemPadding: CGFloat = 0.0 {
        didSet {
            if itemPadding != oldValue {
                self.setup()
            }
        }
    }
    
    var isCycled: Bool = true {
        didSet {
            if isCycled != oldValue {
                self.setup()
            }
        }
    }
    
    var onTap: SSPagingScrollAction?
    
    var didTurnToPage: SSPagingScrollAction? {
        didSet {
            
            self.didTurnToPageCallback()
            
        }
    }
    
    weak var pageControl: UIPageControl?
    
    private(set) var countOfItems: Int = 0
    
    private var createItem: SSPagingScrollItemCreate?
    
    private var step: CGFloat {
        
        if self.itemSize.width > 0 {
            return floor(self.itemSize.width + self.itemPadding)
        }
        
        return 0
    }
    
    var frame: CGRect {
        set {
            
            let oldValue = self.containerView.frame
            self.containerView.frame = newValue
            
            if newValue.size.equalTo(oldValue.size) == false {
                self.setup()
            }
        }
        
        get {
            return self.containerView.frame
        }
    }
    
    // MARK: - lifecycle
    
    deinit {
        self.scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
    }
    
    override init() {
        super.init()
        
        self.scrollView.delegate = self
        self.scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [], context: nil)
        
    }
    
    // MARK: - public
    
    func configure(count: Int, items: @escaping SSPagingScrollItemCreate) {
        self.countOfItems = count
        self.createItem = items
        self.setup()
    }
    
    func addTo(parent: UIView) {
        parent.addSubview(containerView)
    }
    
    func remove() {
        self.removeTimer()
        containerView.removeFromSuperview()
    }
    
    func scrollToPage(_ page: Int, animated: Bool) {
        if self.isCycled {
            self.scrollView.setContentOffset(CGPoint(x: self.step * CGFloat(page + 1), y: 0), animated: animated)
        }else {
            self.scrollView.setContentOffset(CGPoint(x: self.step * CGFloat(page), y: 0), animated: animated)
        }
    }
    
    func removeTimer() {
        self.autoPlayTimer?.invalidate()
        self.autoPlayTimer = nil
    }
    
    // MARK: - private
    
    private func setup() {
        
        guard self.containerView.bounds.width > 0, self.containerView.bounds.height > 0, self.itemSize.width > 0, self.itemSize.height > 0 else {
            return
        }
        
        guard let createItem = self.createItem else {
            return
        }
        
        self.scrollView.frame = CGRect(x: 0, y: 0, width: self.containerView.bounds.width, height: self.containerView.bounds.height)
        
        if let view = self.scrollView.viewWithTag(932) {
            view.removeFromSuperview()
        }
        
        let contentView = self.createContentViewWithItems(createItem)
        contentView.tag = 932
        self.scrollView.addSubview(contentView)
        self.scrollView.contentSize = contentView.bounds.size
        
        self.containerView.addSubview(self.scrollView)
        
    }
    
    private func createContentViewWithItems(_ createItem: SSPagingScrollItemCreate) -> UIView {
        
        let contentView = UIView.init(frame: self.scrollView.bounds)
        
//        contentView.backgroundColor = UIColor.orange
        
        var position = CGPoint(x: (contentView.bounds.width - self.itemSize.width) / 2, y: 0)
        
        if self.isCycled {
            //
            let firstPage = createItem(self.countOfItems - 1, nil)
            firstPage.frame = CGRect(origin: position, size: self.itemSize)
            contentView.addSubview(firstPage)
            position.x += (self.itemSize.width + self.itemPadding)
            
            for index in 0...(self.countOfItems - 1) {
                
                let page = createItem(index, nil)
                page.frame = CGRect(origin: position, size: self.itemSize)
                
                contentView.addSubview(page)
                position.x += (self.itemSize.width + self.itemPadding)
                
                // add tap
                page.tag = SSPagingScroll.TAG_REFER + index
                self.addTapForView(page)
                
            }
            
            let lastPage = createItem(0, nil)
            lastPage.frame = CGRect(origin: position, size: self.itemSize)
            contentView.addSubview(lastPage)
            position.x += (self.itemSize.width + self.itemPadding)
            
        }else {
            for index in 0...(self.countOfItems - 1) {
                
                let page = createItem(index, nil)
                page.frame = CGRect(origin: position, size: self.itemSize)
                contentView.addSubview(page)
                position.x += (self.itemSize.width + self.itemPadding)
                
                // add tap
                page.tag = SSPagingScroll.TAG_REFER + index
                self.addTapForView(page)
                
            }
        }
        
        position.x += (contentView.bounds.width - self.itemSize.width) / 2 - self.itemPadding
        let contentSize = CGSize.init(width: position.x, height: contentView.bounds.height)
        contentView.frame = CGRect.init(origin: CGPoint.zero, size: contentSize)
        
        return contentView
    }
    
    private func adjustContentOffset(scrollView: UIScrollView) {
        
        let step = self.step
        
        let x = round((scrollView.contentOffset.x + self.velocity.x * 130)  / step) * step
        
        guard x >= 0 && x <= scrollView.contentSize.width - scrollView.bounds.width else {
            return
        }
        
        scrollView.setContentOffset(CGPoint(x: x, y: scrollView.contentOffset.y), animated: true)
        
        // reset velocity
        self.velocity = CGPoint.zero
    }
    
    private func resetContentOffsetForNewRound() {
        //
        guard self.isCycled else {
            return
        }
        
        let step = self.step
        let firstPageCopyPosition = step * CGFloat(self.countOfItems + 1)
        let lastPageCopyPosition: CGFloat = 0
        
        let offset = self.scrollView.contentOffset
        print(offset)
        if offset.x == firstPageCopyPosition {
            self.scrollView.setContentOffset(CGPoint.init(x: step, y: offset.y), animated: false)
        }else if (offset.x == lastPageCopyPosition) {
            self.scrollView.setContentOffset(CGPoint.init(x: step * CGFloat(self.countOfItems), y: offset.y), animated: false)
        }
        
    }
    
    private func addTapForView(_ view: UIView) {
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapHandler(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tap)
    }
    
    private func setPageNumber() {
        
        var page = self.step > 0 ? Int(round(self.scrollView.contentOffset.x / self.step)) : 0
        
        //            print("=== page old num \(page) ===")
        
        if self.isCycled {
            page = (page + self.countOfItems - 1) % self.countOfItems
        }
        
        //            print("=== page num \(page) ===")
        
        self.currentPage = page
        
    }
    
    private func didTurnToPageCallback() {
        
        let index = self.currentPage
        
        // page turning callback
        guard let turnToPage = self.didTurnToPage else {
            return
        }
        
        turnToPage(self, index)
        
    }
    
    // MARK: - Event
    static let TAG_REFER = 3746
    
    func tapHandler(_ tap: UIGestureRecognizer) {
        //
        guard let view = tap.view else {
            return
        }
        
        guard let onTap = self.onTap else {
            return
        }
        
        let index = view.tag - SSPagingScroll.TAG_REFER
        guard index == self.currentPage else {
            return
        }
        
        onTap(view, index)
        
    }
    
    @objc private func autoScrollNext() {
        
        if self.scrollView.isTracking || self.scrollView.isDragging {
            return
        }
        
        // not display on screen
        if self.scrollView.window == nil {
            return
        }
        
        let index = self.currentPage + 1
        self.scrollToPage(index, animated: true)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.velocity = velocity
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.adjustContentOffset(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        guard decelerate == false else {
            return
        }
        
        self.adjustContentOffset(scrollView: scrollView)
        
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.adjustContentOffset(scrollView: scrollView)
    }
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //
        if keyPath == #keyPath(UIScrollView.contentOffset) {
            self.resetContentOffsetForNewRound()
            if self.scrollView.isTracking == false {
                self.setPageNumber()
            }
        }
    }
    
}
