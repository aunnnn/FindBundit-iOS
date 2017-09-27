//
//  ProfileViewController.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/31/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import UIKit
import SteviaLayout
import KLCPopup

protocol ProfileViewDelegate: class {
    func profileViewLocateMeButtonPushed()
    func profileViewEditPhoneNumberPushed()
    func profileViewExitButtonPushed()
}

class ProfileView: UIView {
    
    var popup: KLCPopup?
    weak var delegate: ProfileViewDelegate?

    
    init(profile: RealmUserProfile) {
        super.init(frame: CGRect.zero)
    
        self.backgroundColor = UIColor.flatWhiteColor()
        
        let closeButton = UIButton()
        closeButton.setTitle("+", forState: .Normal)
        closeButton.layer.setAffineTransform(CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(M_PI_4)))
        closeButton.titleLabel?.font = Fonts.bold(22)
        closeButton.setTitleColor(UIColor.flatGrayColor(), forState: .Normal)
        closeButton.setTitleColor(UIColor.flatGrayColorDark(), forState: .Highlighted)
        closeButton.size(36)
        closeButton.addTarget(self, action: #selector(self.closeButtonPushed), forControlEvents: .TouchUpInside)
        
        let imageView = UIImageView().then { imv in
            if let pic = profile.pictureURL {
                imv.sd_setImageWithURL(pic)
            }
        }
        
        let usernameLabel = UILabel().then { lb in
            lb.text = "Username: \(profile.username)"
            lb.textColor = UIColor.flatBlackColor()
            lb.font = Fonts.normal()
        }
        
        let phoneLabel = UILabel().then { lb in
            if let phone = profile.phone where !phone.isEmpty {
                lb.text = "Phone: \(phone)"
            } else {
                lb.text = "Phone: -"
            }
            lb.textColor = UIColor.flatBlackColor()
            lb.font = Fonts.normal()
        }
        
        let locateMeButton = UIButton().then { (bttn) in
            bttn.setTitle("Locate me", forState: .Normal)
            bttn.setTitleColor(UIColor.flatBlackColor(), forState: .Normal)
            bttn.setTitleColor(UIColor.flatGrayColorDark(), forState: .Highlighted)
            bttn.titleLabel?.font = Fonts.bold()
            bttn.backgroundColor = UIColor.flatWhiteColor()
            bttn.addTarget(self, action: #selector(self.locateMe), forControlEvents: .TouchUpInside)
        }
        
        let exitButton = UIButton().then { (bttn) in
            bttn.setTitle("Exit app", forState: .Normal)
            bttn.setTitleColor(UIColor.flatRedColor(), forState: .Normal)
            bttn.setTitleColor(UIColor.flatRedColorDark(), forState: .Highlighted)
            bttn.titleLabel?.font = Fonts.bold()
            bttn.backgroundColor = UIColor.flatWhiteColorDark()
            bttn.addTarget(self, action: #selector(self.exit), forControlEvents: .TouchUpInside)
        }
        
        let editPhoneButton = UIButton().then { (bttn) in
            bttn.setTitle("Edit", forState: .Normal)
            bttn.setTitleColor(UIColor.flatBlueColor(), forState: .Normal)
            bttn.setTitleColor(UIColor.flatBlackColorDark(), forState: .Highlighted)
            bttn.titleLabel?.font = Fonts.bold(12)
            bttn.addTarget(self, action: #selector(self.editPhoneNumber), forControlEvents: .TouchUpInside)
        }
        
        self.sv([imageView, usernameLabel, phoneLabel, closeButton, locateMeButton, editPhoneButton, exitButton])
        
        if let _ = profile.pictureURL {
            imageView.layer.cornerRadius = 32
            imageView.layer.masksToBounds = true
            imageView.size(64)
        } else {
            imageView.size(0)
            imageView.hidden = true
        }
        
        self.setContentCompressionResistancePriority(1000, forAxis: .Vertical)
        self.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
        
        self.layout(
            8,
            imageView.centerHorizontally(),
            12,
            |-12-usernameLabel-44-| ~ 36,
            0,
            |-12-phoneLabel-72-| ~ 36,
            4,
            |locateMeButton| ~ 44,
            |exitButton| ~ 44,
            0
        )
        
        self.layout(
            phoneLabel-4-editPhoneButton-|
        )
        
        self.layout(
            4,
            closeButton-4-|
        )
    }
    
    func closeButtonPushed() {
        popup?.dismiss(true)
        
        // this line seems important, without it deinit won't be called
        popup = nil
    }
    
    func locateMe() {
        popup?.dismiss(true)
        delegate?.profileViewLocateMeButtonPushed()
    }
    
    func exit() {
        popup?.dismiss(true)
        delegate?.profileViewExitButtonPushed()
    }
    
    func editPhoneNumber() {
        delegate?.profileViewEditPhoneNumberPushed()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}