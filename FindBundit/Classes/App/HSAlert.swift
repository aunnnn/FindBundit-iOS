//
//  HSAlert.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/19/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import UIKit

typealias HSAlertActionSheetItem = (String, UIAlertActionStyle, () -> Void)

class HSAlert {
    static func alertDestructiveWithCancelButton(title: String, message: String, destructiveButtonTitle: String, destructiveAction: (() -> Void)? = nil, cancelAction: (() -> Void)? = nil) -> UIAlertController {
        let alertvc = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertvc.addAction(UIAlertAction(title: destructiveButtonTitle, style: .Destructive) { action in
            destructiveAction?()
            })
        alertvc.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { action in
            cancelAction?()
            alertvc.dismissViewControllerAnimated(true, completion: nil)
            })
        return alertvc
    }
    
    static func alertInformation(title: String, message: String, acknowledgeButtonTitle: String="Close", acknowledgeButtonAction: (() -> Void)?=nil) -> UIAlertController {
        let alertvc = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertvc.addAction(UIAlertAction(title: acknowledgeButtonTitle, style: .Cancel, handler: { action in
            acknowledgeButtonAction?()
        }))
        return alertvc
        
    }
    
    static func alertInformationWithCloseButton(title: String, message: String) -> UIAlertController {
        return HSAlert.alertInformation(title, message: message, acknowledgeButtonTitle: "Close")
    }
    
    static func alertPrimaryActionWithCancelButton(title: String, message: String, primaryActionTitle: String, primaryAction: () -> Void, cancelAction: (() -> Void)?=nil) -> UIAlertController {
        let alertvc = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertvc.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { action in
            cancelAction?()
            alertvc.dismissViewControllerAnimated(true, completion: nil)
            })
        alertvc.addAction(UIAlertAction(title: primaryActionTitle, style: .Default) { action in
            primaryAction()
            })
        return alertvc
    }
    
    static func alertSheet(title: String?=nil, message: String?=nil, actions: [HSAlertActionSheetItem]) -> UIAlertController {
        let alertvc = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        for (title, style, block) in actions {
            let action = UIAlertAction(title: title, style: style, handler: { action in
                block()
            })
            alertvc.addAction(action)
        }
        return alertvc
    }
}

extension UIAlertController {
    func presentOn(presentingViewController: UIViewController) {
        presentingViewController.presentViewController(self, animated: true, completion: nil)
    }
}