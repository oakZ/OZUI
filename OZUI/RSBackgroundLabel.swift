//
//  RSBackgroundLabel.swift
//  MSSProject
//
//  Created by zx on 2019/4/10.
//  Copyright © 2019年 Rocky. All rights reserved.
//

import UIKit

typealias RSBackgroundImageMaker = (_ size: CGSize) -> UIImage

class RSBackgroundLabel: UILabel {
    
    private var imageView = UIImageView()
    
    private var backgroundImageMaker: RSBackgroundImageMaker?
    
    
    func setBackgroundImage(_ block: @escaping RSBackgroundImageMaker) {
        self.backgroundImageMaker = block
    }
    
    override func layoutSubviews() {
        
        self.imageView.frame = self.frame
        
        if let custom = self.backgroundImageMaker {
            let image = custom(self.imageView.frame.size)
//            self.backgroundColor = UIColor.init(patternImage: image)
            self.imageView.image = image
        }
        
        if self.superview != nil, self.imageView.superview == nil {
            self.superview?.insertSubview(self.imageView, belowSubview: self)
        }
        
    }
    
    override func removeFromSuperview() {
        self.imageView.removeFromSuperview()
        super.removeFromSuperview()
    }
    
}
