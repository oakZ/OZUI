//
//  OZPullDownControl.swift
//  OZUI
//
//  Created by zx on 2019/5/13.
//  Copyright © 2019年 oakz. All rights reserved.
//

import UIKit

class OZPullDownControl: UIView, OZPullRefreshControl {
    
    private var label = UILabel()
    
    private var isLoading = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(label)
        
        self.label.font = UIFont.boldSystemFont(ofSize: 10)
        self.label.textAlignment = .center
        self.label.textColor = UIColor.colorWithRGB(0xbbbbbb)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(progress: Double) {
        
        if self.isLoading {
            return
        }
        
        if progress < 1 {
            self.label.text = "下拉刷新"
        }else {
            self.label.text = "松开刷新"
        }
    }
    
    func startLoading() {
        self.isLoading = true
        self.label.text = "加载中..."
    }
    
    func reset() {
        self.isLoading = false
        self.label.text = "下拉刷新"
    }

}
