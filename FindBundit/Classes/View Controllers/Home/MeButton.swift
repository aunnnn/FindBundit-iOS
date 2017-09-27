//
//  MeButton.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/31/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import UIKit
import SteviaLayout

class MeButton: UIButton {
    
    var isLocationAvailable: Bool = false {
        didSet {
            self.layer.borderColor = isLocationAvailable ? UIColor.flatGreenColor().CGColor : UIColor.flatRedColor().CGColor
        }
    }
    
    override var highlighted: Bool {
        didSet {
            self.alpha = highlighted ? 0.8 : 1.0
        }
    }
    
    init(profile: RealmUserProfile?) {
        super.init(frame: .zero)
        
        let bttn = self
        bttn.layer.cornerRadius = 22
        bttn.layer.masksToBounds = true
        if let pic = profile?.pictureURL {
            bttn.sd_setImageWithURL(pic, forState: .Normal)
        } else {
            bttn.setTitle("me", forState: .Normal)
            bttn.setTitleColor(UIColor.flatBlackColor(), forState: .Normal)
            bttn.setTitleColor(UIColor.flatBlackColorDark(), forState: .Highlighted)
            bttn.backgroundColor = UIColor.whiteColor()
        }
        
        bttn.layer.borderWidth = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
