//
//  UserIconCell.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/18/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import UIKit
import SteviaLayout

class UserIconCell: UICollectionViewCell {
    
    lazy var iconImageView = UIImageView()
    lazy var label = UIKitStyles.defaultLabel()
    
    override var highlighted: Bool {
        didSet {
            self.alpha = highlighted ? 0.8 : 1.0
        }
    }
    
    var isActive: Bool = false {
        didSet {
            self.contentView.layer.borderColor = isActive ? UIColor.flatGreenColor().CGColor : UIColor.flatWhiteColor().CGColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = UIColor.whiteColor()
        self.contentView.layer.cornerRadius = 22
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.borderWidth = 2
        
        label.font = Fonts.normalTiny()
        label.numberOfLines = 1
        iconImageView.contentMode = .ScaleAspectFill
        
        
        self.contentView.sv(label, iconImageView)
        
        label.fillContainer()
        iconImageView.fillContainer()
    }
    
    func setUsername(username: String) {
        self.label.hidden = false
        self.iconImageView.hidden = true
        
        self.label.text = username
    }
    
    func setIcon(url: NSURL) {
        self.label.hidden = true
        self.iconImageView.hidden = false
        
        iconImageView.sd_setImageWithURL(url)
    }
    
    func animateSelected() {
        UIView.animateWithDuration(0.2, animations: {
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2)
        }) { (completed) in
            UIView.animateWithDuration(1.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.3, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.transform = CGAffineTransformIdentity
            }) { completed in
                
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
