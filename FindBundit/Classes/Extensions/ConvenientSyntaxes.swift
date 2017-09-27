//
//  ConvenientSyntaxes.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/10/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import Foundation
import UIKit

let ScreenSize = UIScreen.mainScreen().bounds.size
let ScreenBound = UIScreen.mainScreen().bounds

// MARK: Scheduling
func runOnMainQueue(block: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        block()
    }
}

func runOnBackground(delay: Double = 0.0, backgroundTask: () -> Void, completion: (() -> Void)? = nil) {
    dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
        
        backgroundTask()
        
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        
        guard let `completion` = completion else { return }
        dispatch_after(popTime, dispatch_get_main_queue()) {
            completion()
        }
    }
}

func delay(bySeconds seconds: Double, dispatchLevel: DispatchLevel = .Main, closure: () -> Void) {
    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    dispatch_after(dispatchTime, dispatchLevel.dispatchQueue, closure)
}

enum DispatchLevel {
    case Main, UserInteractive, UserInitiated, Utility, Background
    var dispatchQueue: OS_dispatch_queue {
        switch self {
        case .Main:             return dispatch_get_main_queue()
        case .UserInteractive:  return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
        case .UserInitiated:    return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        case .Utility:          return dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
        case .Background:       return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0) }
    }
}