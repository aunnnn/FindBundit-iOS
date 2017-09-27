//
//  NewAccountDataViewController.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/12/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import SteviaLayout
import IHKeyboardAvoiding
import SDWebImage
import MBProgressHUD
import RxSwift
import then
import FacebookCore
import FacebookLogin

class NewAccountDataViewController: BaseViewController {
    
    let initialProfile: UserProfile
    var currentProfile: UserProfile
    
    var didRegistered = false
    let loadingIndicator = Style.defaultActivityIndicatorView()
    
    init(profile: UserProfile) {
        self.initialProfile = profile
        self.currentProfile = initialProfile
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
}

extension NewAccountDataViewController {
    
    func setupUI() {
        
        self.view.backgroundColor = UIColor.init(
            gradientStyle: .TopToBottom,
            withFrame: CGRect(origin: .zero, size: ScreenSize),
            andColors: [
                UIColor.whiteColor(),
                UIColor.flatWhiteColor(),
                UIColor.flatWhiteColorDark()
            ])
        
        let wrapper = UIView()
        
        let pictureView = UIImageView().style { img in
            img.layer.cornerRadius = 40
            img.layer.masksToBounds = true
            img.contentMode = .ScaleAspectFill
            img.backgroundColor = UIColor.init(gradientStyle: .Radial, withFrame: CGRect(origin: .zero, size: CGSize(width: 80, height: 80)), andColors: [
                    UIColor.flatGrayColor(),
                    UIColor.flatGrayColorDark()
                ])
        }
        
        let pictureUrl = self.initialProfile.picture
        pictureView.sd_setImageWithURL(pictureUrl) { (image, _, _, _) in
            
            UIView.animateWithDuration(
                0.8,
                delay: 0,
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: {
                    pictureView.image = image
                }, completion: { completed in
            })
        }
        
        let usernameLabel = UILabel().style(defaultGuidingTitleLabel).style {
            $0.text = "Username"
            $0.textColor = UIColor.flatSkyBlueColor()
            $0.font = Fonts.bold(12)
        }
        
        let usernameTextField = UIKitStyles.defaultTextField().style { [weak self] in
            $0.placeholder = "Username"
            $0.text = self?.initialProfile.username
        }
        
        let phoneLabel = UILabel().style(defaultGuidingTitleLabel).style {
            $0.text = "Phone"
            $0.textColor = UIColor.flatSkyBlueColor()
            $0.font = Fonts.bold(12)
        }
        
        let phoneTextField = UIKitStyles.defaultTextField().style { [weak self] in
            $0.placeholder = "e.g. 089123xxxx"
            $0.keyboardType = .PhonePad
            $0.text = self?.initialProfile.phone
            $0.delegate = self
        }
        
        let registerButton = UIKitStyles.defaultButton().style {
            $0.text("REGISTER :)")
            $0.setTitleColor(UIColor.flatBlueColor(), forState: .Normal)
            $0.setTitleColor(UIColor.flatBlueColorDark(), forState: .Highlighted)
            $0.titleLabel?.font = Fonts.bold(20)
            $0.titleLabel?.textAlignment = .Center
        }
        
        let backButton = UIKitStyles.defaultButton().style { [unowned self] in
            $0.text("Back")
            $0.setTitleColor(UIColor.flatGrayColor(), forState: .Normal)
            $0.setTitleColor(UIColor.flatGrayColorDark(), forState: .Highlighted)
            $0.titleLabel?.font = Fonts.bold()
            $0.titleLabel?.textAlignment = .Center
            $0.addTarget(self, action: #selector(self.back), forControlEvents: .TouchUpInside)
        }
        
        let loading = Variable<Bool>(false)
        loading.asObservable().bindTo(loadingIndicator.rx_animating).addDisposableTo(disposeBag)
        loading.asObservable().not().bindTo(loadingIndicator.rx_hidden).addDisposableTo(disposeBag)
        loading.asObservable().map { [unowned self] in $0 || (self.didRegistered) }.asObservable().bindTo(registerButton.rx_hidden).addDisposableTo(disposeBag)
        
        loading
            .asObservable()
            .not()
            .subscribeNext { [unowned usernameTextField, phoneTextField] notLoading in
                usernameTextField.enabled = notLoading
                phoneTextField.enabled = notLoading                
            }
            .addDisposableTo(disposeBag)
        
        let usernameValid = usernameTextField.rx_text.map {
            $0.isValidUsername()
        }.shareReplay(1)
        
        usernameValid.bindTo(registerButton.rx_enabled).addDisposableTo(disposeBag)
        usernameValid.subscribeNext { valid in
            registerButton.alpha = valid ? 1 : 0.6
        }.addDisposableTo(disposeBag)
        
        
        registerButton
            .rx_tap
            .subscribeNext { [unowned self] in
                
                let usr = usernameTextField.text ?? ""
                let picture = self.initialProfile.picture
                let phone = phoneTextField.text?.removeSpecialCharacters().stringByReplacingOccurrencesOfString(" ", withString: "")
                
                self.currentProfile = UserProfile(username: usr, picture: picture, phone: phone)
                
                if (phoneTextField.text ?? "").isEmpty {
                    let alert = HSAlert.alertPrimaryActionWithCancelButton("Register Without Phone Number?", message: "Phone number will let your friend call to you directly.", primaryActionTitle: "Register", primaryAction: { [unowned self, weak loading] in
                        
                        loading?.value = true
                        
                        self
                            .registerAccount()
                            .onError { [weak self] error in
                                guard let `self` = self else { return }
                                let alert = HSAlert.alertInformation("Cannot Register New Account", message: error.description())
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                            .finally { [weak loading] in
                            loading?.value = false
                        }
                    })
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    loading.value = true
                    self.registerAccount().finally { [weak loading] in
                        loading?.value = false
                    }
                }
            }
            .addDisposableTo(disposeBag)
        
        self.view.sv(
            backButton,
            
            wrapper.sv(
                pictureView,
                
                usernameLabel,
                usernameTextField,
                phoneLabel,
                phoneTextField
            ),
            
            registerButton,
            loadingIndicator
        )
        
        wrapper.layout(
            8,
            |-20-pictureView.size(80).centerHorizontally(),
            20,
            |-usernameLabel ~ 16,
            6,
            |-usernameTextField-| ~ 32,
            16,
            |-phoneLabel ~ 16,
            6,
            |-phoneTextField-| ~ 32,
            8
        )
        
        self.view.layout(
            80,
            |-20-wrapper.centerVertically()-20-|
        )
        
        self.view.layout(
            registerButton-24-|,
            44
        )
        
        self.view.layout(
            44,
            |-8-backButton.width(64) ~ 44
        )
        
        if initialProfile.picture == nil {
            pictureView.size(20)
            pictureView.hidden = true
        }
        
        alignCenter(loadingIndicator, with: registerButton)
        
        IHKeyboardAvoiding.setAvoidingView(wrapper)
        
    }
    
    func back() {
        if AccessToken.current != nil {
            LoginManager().logOut()
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func registerAccount() -> Promise<()> {
        
        let pwd = String.random(16).md5()
        
        let pm = User
                .register(self.currentProfile, password: pwd).then { [unowned self] user in
                    self.didRegistered = true
                    MBProgressHUD.exShowText(AppDelegate.shared.unsafeWindow, titleText: "Your account is ready!")
                    AppDelegate.shared.navigator.goToHomePage(user).start()
                }
        return pm
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        self.view.endEditing(true)
    }
    
    func defaultGuidingTitleLabel(lb: UILabel) {
        UIKitStyles.defaultLabel(lb)
        lb.font = Fonts.normalTiny()
        lb.textColor = UIColor.flatNavyBlueColor()
    }
}

extension NewAccountDataViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 10
    }
}