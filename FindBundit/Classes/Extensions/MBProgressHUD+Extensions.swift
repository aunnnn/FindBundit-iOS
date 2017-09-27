//
//  MBProgressHUD+Extensions.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/9/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import MBProgressHUD

extension MBProgressHUD {
    
    func configDefault() -> MBProgressHUD {
        self.label.font = Fonts.bold()
        self.detailsLabel.font = Fonts.normal()
        return self
    }
    
    static func exShowProgress(onView: UIView, titleText: String="Loading") {
        exHide(onView)
        
        runOnMainQueue {
            let hud = MBProgressHUD.showHUDAddedTo(onView, animated: true).configDefault()
            hud.label.text = titleText
            hud.mode = .Indeterminate
        }
    }
    
    static func exShowText(onView: UIView, titleText: String, detailText: String?=nil, delay: NSTimeInterval=1.5) {
        exHide(onView)
        
        runOnMainQueue {
            let hud = MBProgressHUD.showHUDAddedTo(onView, animated: true).configDefault()
            hud.label.text = titleText
            hud.detailsLabel.text = detailText
            hud.mode = .Text
            hud.userInteractionEnabled = false
            hud.hideAnimated(true, afterDelay: delay)
        }
    }
    
    static func exHide(onView: UIView, animated: Bool=true) {
        runOnMainQueue {
            MBProgressHUD.hideHUDForView(onView, animated: animated)
        }
    }
    
}
