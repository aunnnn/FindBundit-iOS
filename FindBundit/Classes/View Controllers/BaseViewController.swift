//
//  BaseViewController.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/7/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import UIKit
import RxSwift
import MBProgressHUD

class BaseViewController: UIViewController {
    
    private(set) lazy var disposeBag = DisposeBag()
    
    /// Default Loading. Loading HUD will appear depending on its value.
    let defaultLoading = Variable(false)
    var defaultLoadingTitle = "Loading"
    
    deinit {
        print("deinit: \(self.dynamicType)")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        defaultLoading.asObservable().distinctUntilChanged().subscribeNext { [weak self] loading in
            guard let `self` = self else { return }
            if loading {
                self.showProgressHUD(self.defaultLoadingTitle)
            } else {
                self.hideHUD(true)
            }
        }.addDisposableTo(disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showProgressHUD(title: String) {
        MBProgressHUD.exShowProgress(self.view, titleText: title)
    }
    
    func showTextHUD(title: String, detail: String?=nil, delay: NSTimeInterval=1.5) {
        MBProgressHUD.exShowText(self.view, titleText: title, detailText: detail, delay: delay)
    }
    
    func hideHUD(animated: Bool=true) {
        MBProgressHUD.exHide(self.view, animated: animated)
    }    
}

extension BaseViewController {
    
    func wrapWithNav() -> UINavigationController {        
        let nav = UINavigationController(rootViewController: self)
        nav.navigationBarHidden = true
        nav.navigationItem.hidesBackButton = true
        return nav
    }
    
    func showViewController(vc: UIViewController, completion: () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.showViewController(vc, sender: nil)
        CATransaction.commit()
    }
}