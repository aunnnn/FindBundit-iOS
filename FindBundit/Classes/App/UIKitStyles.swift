//
//  UIKitStyles.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/7/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import UIKit

typealias Style = UIKitStyles

extension UIAppearance {
    func styles(styleClosures: (Self -> Void)...) -> Self {
        for s in styleClosures {
            self.style(s)
        }
        return self
    }
}

struct UIKitStyles {
    
    static let defaultDarkTextColor = UIColor.flatBlackColor()
    
    static func defaultLabel(lb: UILabel) {
        lb.textColor = defaultDarkTextColor
    }
    
    static func defaultLabel() -> UILabel {
        let lb = UILabel()
        lb.textColor = defaultDarkTextColor
        return lb
    }
    
    static func defaultTextField(tf: UITextField) {
        tf.font = Fonts.normal()
        tf.textColor = defaultDarkTextColor
    }
    
    static func defaultTextField() -> UITextField {
        let tf = UITextField()
        defaultTextField(tf)
        return tf
    }
    
    static func defaultButton(bttn: UIButton) {
        bttn.titleLabel?.font = Fonts.normal()
        bttn.setTitleColor(defaultDarkTextColor, forState: .Normal)
    }
    
    static func defaultButton() -> UIButton {
        let bttn = UIButton()
        defaultButton(bttn)
        return bttn
    }
    
    static func defaultRounded(v: UIView) {
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 6
    }
    
    static func defaultActivityIndicatorView() -> UIActivityIndicatorView {
        return UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    }
}

extension UIKitStyles {
 
    static func uncompressable(v: UIView) {
        v.setContentCompressionResistancePriority(1000, forAxis: .Vertical)
        v.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
    }
    
    static func loginTextfield(tf: UITextField) {
        tf.autocapitalizationType = .None
        tf.autocorrectionType = .No
    }
}