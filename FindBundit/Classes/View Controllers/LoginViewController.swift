//
//  LoginViewController.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/7/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import SteviaLayout
import ChameleonFramework
import RxSwift
import MBProgressHUD
import IHKeyboardAvoiding
import FacebookCore
import FacebookLogin


class LoginViewController: BaseViewController {
    
    private let wrapper = UIView()        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI { (usernameTextField, startButton) in                                    
            
            // Username
            let usernameValid = usernameTextField.rx_text.map {
                $0.isValidUsername()
            }.shareReplay(1)
            
            usernameValid.bindTo(startButton.rx_enabled).addDisposableTo(disposeBag)
            usernameValid.subscribeNext { valid in
                startButton.alpha = valid ? 1 : 0.6
            }.addDisposableTo(disposeBag)
            
            // Start Button
            startButton
                .rx_tap
                .subscribe { [weak self] _ in
                    
                    guard let `self` = self else { return }
                    self.view.endEditing(true)
                                        
                    let usr = usernameTextField.text ?? ""                    
                    
                    let tmpProfile = UserProfile(username: usr, picture: nil, phone: nil)
                    
                    AppDelegate.shared.navigator.goToNewAccountPage(tmpProfile)
                }
                .addDisposableTo(disposeBag)
        }
    }        
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        self.view.endEditing(true)
    }
}

extension LoginViewController {
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = UIColor(
            gradientStyle: .TopToBottom,
            withFrame: CGRect(origin: .zero, size: ScreenSize),
            andColors: [
                UIColor.flatWhiteColorDark(),
                UIColor.whiteColor()
            ])
    }
    
    private func setupUI(@noescape thenDoRx
        rxBlock: (usernameTextField: UITextField, startButton: UIButton) -> Void) {
        
        
        let appIcon = UIImageView(image: UIImage(named: "icontrans")!).then { img in
            img.contentMode = .ScaleAspectFit
        }
        
        let appNameLabel = UILabel()
            .style { lb in
                lb.font = Fonts.light(32)
                lb.textColor = UIColor.flatBlackColor()
                lb.text = "Find Bundit"
        }
        
        let startButton = UIButton()
            .styles(
                Style.defaultButton,
                Style.defaultRounded
            )
            .style { bttn in
                bttn.text("START")
                
                bttn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                bttn.setTitleColor(UIColor.flatWhiteColorDark(), forState: .Highlighted)
                bttn.titleLabel?.font = Fonts.boldPrimary()
                bttn.backgroundColor = UIColor.flatBlueColor()
        }
        
        let usernameLabel = UILabel().then { lb in
            lb.text = "NEW ACCOUNT"
            lb.font = Fonts.bold()
            lb.textColor = UIColor.flatBlackColor()
            lb.textAlignment = .Center
        }
        
        let usernameTextField = B68UIFloatLabelTextField(frame: .zero)
            .styles(
                Style.defaultTextField,
                Style.uncompressable,
                Style.loginTextfield
            )
            .style { tf in
                tf.placeholder = "4 or more characters"
                tf.floatingLabel.text = "Username"
                tf.floatingLabel.font = Fonts.normalTiny()
                tf.activeTextColorfloatingLabel = UIColor.flatBlueColor()
        }
        
        let fbButton = LoginButton(readPermissions: [ .PublicProfile ])
        
        
        let scrollView = UIScrollView().style { [unowned self] sc in
            sc.decelerationRate = UIScrollViewDecelerationRateFast
            sc.alwaysBounceVertical = true
            sc.showsVerticalScrollIndicator = false
            sc.clipsToBounds = false
            sc.rx_contentOffset
                .map { 0.2 + abs(1 - $0.y/120) }
                .bindTo(self.view.rx_alpha)
                .addDisposableTo(self.disposeBag)
        }
        
        let orLabel = UILabel().style { lb in
            lb.text = "OR"
            lb.font = Fonts.bold()
            lb.textColor = UIColor.flatBlackColor()
        }
        
        self.view.sv(
            
            appIcon,
            appNameLabel,
            
            scrollView.sv(
                wrapper.sv(
                    usernameLabel,
                    usernameTextField,
                    startButton
                )
            ),
            
            orLabel,
            fbButton
        )
        
        self.view.layout(
            44,
            appIcon.size(64)-0-appNameLabel-20-| ~ 54
        )
        
        self.view.layout(
            orLabel.centerHorizontally(),
            32,
            fbButton.size(180).centerHorizontally() ~ 32,
            44
        )
        
        
        equalSizes(scrollView, wrapper)
        scrollView.centerInContainer()
        wrapper.centerInContainer()
        
        wrapper.layout(
            20,
            |-usernameLabel-| ~ 44,
            22,
            |-usernameTextField.width(200)-| ~ 44,
            32,
            |-startButton.width(200)-| ~ 44,
            12)
        
        
        IHKeyboardAvoiding.setAvoidingView(wrapper)
        
        rxBlock(usernameTextField: usernameTextField, startButton: startButton)
        
    }
}

//private extension UILabel {
//    var rx_coordinates: AnyObserver<CLLocationCoordinate2D> {
//        return AnyObserver { [weak self] event in
//            guard let _self = self else { return }
//            switch event {
//            case let .Next(location):
//                _self.text = "Lat: \(location.latitude)\nLon: \(location.longitude)"
//            default:
//                _self.text = "Nothing..."
//            }
//        }
//    }
//}
