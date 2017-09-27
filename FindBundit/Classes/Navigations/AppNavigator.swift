//
//  AppNavigator.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/13/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import MBProgressHUD
import then
import FacebookCore
import FacebookLogin

struct AppNavigator {
    
    init() {}
    
    func onAppLaunch() {
        if let user = User.users.first {
            let home = MapHomeViewController(user: user)
            AppDelegate.shared.window?.rootViewController = home
            
            user.renewToken().then { user in
                (AppDelegate.shared.unsafeWindow.rootViewController as? BaseViewController)?.showTextHUD("Connected.")
                }.onError { error in
                    (AppDelegate.shared.unsafeWindow.rootViewController as? BaseViewController)?.showTextHUD("Error.")
                    UIView.transitionWithView(AppDelegate.shared.unsafeWindow, duration: 0.2, options: .TransitionCrossDissolve, animations: {
                        
                        AppDelegate.shared.window?.rootViewController = LoginViewController().wrapWithNav()
                        
                        }, completion: { finished in
                            AppDelegate.shared.deleteDefaultRealmFile()
                            MBProgressHUD.exShowText(AppDelegate.shared.unsafeWindow, titleText: "Something went wrong.", detailText: "We cannot renew your session.")
                    })
            }
        } else {
            AppDelegate.shared.window?.rootViewController = LoginViewController().wrapWithNav()
        }
    }
    
    func onExit(errorMessage: String?=nil) {
        
        
        // if login with facebook
        if AccessToken.current != nil {
            LoginManager().logOut()
        }
        
        AppDelegate.shared.deleteDefaultRealmFile()
        
        let login = LoginViewController()
        login.view.layoutIfNeeded()
        
        let nav = login.wrapWithNav()
        
        AppDelegate.shared.unsafeWindow.rootViewController = nil

        UIView.transitionWithView(AppDelegate.shared.unsafeWindow, duration: 0.6, options: .TransitionCrossDissolve, animations: {
            
            AppDelegate.shared.window?.rootViewController = nav
            
        }) { [unowned login] finished in
            
            if let msg = errorMessage {
                login.showTextHUD("We Had Trouble Exiting the App", detail: msg, delay: 3)
            }
        }
    }
    
    // MARK: View transitions
    
    func goToNewAccountPage(profile: UserProfile) {
        guard let root = AppDelegate.shared.unsafeWindow.rootViewController as? UINavigationController else { return }
        
        let newAccount = NewAccountDataViewController(profile: profile)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setCompletionBlock { [unowned root, newAccount] in
            root.showViewController(newAccount, sender: nil)
        }
        newAccount.view.layoutIfNeeded()
        CATransaction.commit()
    }
    
    func goToNewAccountPageWithDataFromFacebook(profile: FacebookProfile) {

        guard let root = AppDelegate.shared.unsafeWindow.rootViewController as? UINavigationController else { return }
        
        let username = profile.name.removeSpecialCharacters().stringByReplacingOccurrencesOfString(" ", withString: "")
        let profileUrl = profile.picture
        let loginProfile = UserProfile(username: username, picture: profileUrl, phone: nil)
        
        let newAccount = NewAccountDataViewController(profile: loginProfile)
        newAccount.view.layoutIfNeeded()
        root.showViewController(newAccount, sender: nil)
    }
    
    func goToHomePage(user: User) -> Promise<Void> {
        return Promise { (resolve, reject) in
            delay(bySeconds: 1.0) {
                
                let home = MapHomeViewController(user: user)
                home.view.layoutIfNeeded()
                
                (AppDelegate.shared.window?.rootViewController as? UINavigationController)?.viewControllers = []
                
                UIView.transitionWithView(
                    AppDelegate.shared.unsafeWindow,
                    duration: 0.2,
                    options: UIViewAnimationOptions.TransitionCrossDissolve,
                    animations: {
                        
                        AppDelegate.shared.window?.rootViewController = home
                }) {
                    completed in
                    resolve()
                }
            }
        }
    }
}
    
extension AppNavigator {
    
    // MARK: Data movement
    func didLoginWithFacebook() {
        
        self.getFacebookProfile()
            .then { profile in
                
                MBProgressHUD.exHide(AppDelegate.shared.unsafeWindow, animated: true)
                
                return Promise { (resolve, reject) in
                    resolve(profile)
                    return
                }
            }
            .then(goToNewAccountPageWithDataFromFacebook)
    }
    
    
    func getFacebookProfile() -> Promise<FacebookProfile> {
        return Promise { (resolve, reject) in
            guard let fbtoken = AccessToken.current else {
                reject(AppError.Custom(message: "FB: No access token."))
                return
            }
            
            let request = GraphRequest(graphPath: "me", parameters: ["fields":"name,picture.height(320)"], accessToken: fbtoken, httpMethod: .GET)
            
            request.start { (httpResponse, result) in
                switch result {
                case .Success(let response):
                    print("FBSuccess: \(response.dictionaryValue)")
                    guard let data = response.dictionaryValue else {
                        reject(AppError.Custom(message: "FB: No data dictionary."))
                        return
                    }
                    
                    guard let id = data["id"] as? String else {
                        reject(AppError.Custom(message: "FB: No id."))
                        return
                    }
                    
                    guard let name = data["name"] as? String else {
                        reject(AppError.Custom(message: "FB: No name."))
                        return
                    }
                    
                    guard let picture = data["picture"]?.objectForKey("data")?.objectForKey("url") as? String else {
                        print("FB: Cannot get url")
                        let profile = FacebookProfile(id: id, name: name, picture: nil)
                        resolve(profile)
                        return
                    }
                    
                    guard let pic_url = NSURL(string: picture) else {
                        let profile = FacebookProfile(id: id, name: name, picture: nil)
                        resolve(profile)
                        return
                    }
                    
                    print("FBSuccessAll: url = \(pic_url.absoluteString)")
                    
                    let profile = FacebookProfile(id: id, name: name, picture: pic_url)
                    resolve(profile)
                    return
                    
                case .Failed(let error):
                    print("FBError: \(error)")
                    reject(error)
                    return
                }
            }
            
        }
    }
}