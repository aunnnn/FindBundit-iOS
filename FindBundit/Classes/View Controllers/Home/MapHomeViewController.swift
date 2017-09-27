//
//  MapHomeViewController.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/11/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import ChameleonFramework
import SteviaLayout
import MapKit
import SDWebImage
import KLCPopup
import then

class MapHomeViewController: BaseViewController {
    
    let user: User
    var myLatestLocation: CLLocationCoordinate2D?
    var targetLocation: CLLocationCoordinate2D?
    private weak var currentPopup: KLCPopup?
    
    private var meButton: MeButton!
    private let menuButton = UIButton()
    private weak var addFriendTextField: UITextField?
    private weak var editPhoneTextField: UITextField?
    
    private let mapView = MKMapView().style { mv in
        mv.tintColor = UIColor.flatBlueColor()
        mv.showsUserLocation = true
        mv.showsBuildings = true
        mv.mapType = .Standard
        mv.userTrackingMode = .Follow
        
    }
    
    private var updateMyLocationTimer: NSTimer?
    private var checkFriendsActiveTimer: NSTimer?
    
    init(user: User) {
        self.user = user
        super.init()
    }
    
    deinit {
        updateMyLocationTimer?.invalidate()
        updateMyLocationTimer = nil
        
        checkFriendsActiveTimer?.invalidate()
        checkFriendsActiveTimer = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var count = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.flatWhiteColor()
        
        mapView.delegate = self
        
        let coor = CLLocation(latitude: 13.7341, longitude: 100.5301).coordinate
        self.centerMapOnLocation(mapView, coordinate: coor)
        
        let friendPanelView = FriendPanelView(friends: user.friends)
        friendPanelView.delegate = self
        
        let addFriendButton = UIButton().then { bttn in
            bttn.text("+")
            bttn.titleLabel?.font = Fonts.bold(32)
            bttn.setTitleColor(UIColor.flatBlueColor(), forState: .Normal)
            bttn.setTitleColor(UIColor.flatBlueColorDark(), forState: .Highlighted)
            bttn.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
        }
        
        let profile = self.user.profile
        self.meButton = MeButton(profile: profile)
        
        meButton.isLocationAvailable = false
        
        meButton
            .rx_tap
            .subscribeNext { [unowned self] in
                guard let profile = self.user.profile else { return }
                let contentView = ProfileView(profile: profile).then({ v in
                    v.layer.cornerRadius = 12
                    v.layer.masksToBounds = true
                    v.delegate = self
                })
                
                let minimumSizeAfterLayout = contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                contentView.frame = CGRect(origin: .zero, size: minimumSizeAfterLayout)
                
                let popup = KLCPopup(contentView: contentView)
                self.currentPopup = popup
                popup.frame = AppDelegate.shared.unsafeWindow.bounds
                popup.shouldDismissOnBackgroundTouch = false
                popup.showWithLayout(KLCPopupLayoutCenter)
                contentView.popup = popup
            }
            .addDisposableTo(disposeBag)
        
        
        addFriendButton
            .rx_tap
            .filter { [unowned self] in !self.defaultLoading.value }
            .subscribeNext { [unowned self] in
                
                self.count = self.count + 1
                self.alertAddFriend({ [weak self] action in
                    guard let `self` = self else { return }
                    
                    self.view.endEditing(true)
                    
                    if let usr = self.addFriendTextField?.text where usr.characters.count >= 4 {
                        
                        self.defaultLoading.value = true
                        
                        self.user
                            .addFriend(usr)
                            .then { [unowned self] in
                                self.defaultLoading.value = false
                                self.showTextHUD("Added.")
                            }
                            .onError { [unowned self] error in
                                self.defaultLoading.value = false
                                self.showTextHUD("Error", detail: error.description())
                        }
                    } else {
                        self.showTextHUD("Invalid Username", detail: "Username must have length >= 4.", delay: 2)
                    }
                }) { [weak self] acion in
                    self?.view.endEditing(true)
                }
            }
            .addDisposableTo(disposeBag)
        
        self.view.sv(
            mapView,
            friendPanelView,
            addFriendButton,
            meButton
        )
        
        mapView.fillVertically()
        
        self.view.layout(
            |mapView|,
            64
        )
        
        ScreenSize
        
        self.view.layout(
            |friendPanelView-60-| ~ 64,
            0
        )
        
        self.view.layout(
            addFriendButton.width(44)-8-| ~ 44,
            8
        )
        
        self.view.layout(
            36,
            meButton.width(44)-12-| ~ 44
        )
        
        GeolocationService.instance.location
            .asObservable()
            .subscribeNext { [weak self] coor in
                
                guard let `self` = self else { return }
                
                // on first time, set map to user location
                if self.myLatestLocation == nil {
                    self.centerMapOnLocation(self.mapView, coordinate: coor)
                }
                
                self.myLatestLocation = coor
                
                self.meButton.isLocationAvailable = true
                self.user.updateMyActive(true).start()
                
                self.user
                    .updateMyLocation(coor)
                    .then { coor in
                        print("did update my location = \(coor.latitude), \(coor.longitude)")
                    }
                    .onError { error in
                        print("error update my location = \(error.description())")
                        //                        self?.showTextHUD("We cannot update your location", detail: error.description())
                }
            }
            .addDisposableTo(disposeBag)
        
        GeolocationService.instance.failure
            .subscribeNext { [weak self] error in
                self?.meButton.isLocationAvailable = false
                self?.user.updateMyActive(false).start()
            }
            .addDisposableTo(disposeBag)
        
        updateMyLocationTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: #selector(MapHomeViewController.shouldUpdateMyLocation), userInfo: nil, repeats: true)
        
        checkFriendsActiveTimer = NSTimer.scheduledTimerWithTimeInterval(16.0, target: self, selector: #selector(MapHomeViewController.shouldCheckFriendsActive), userInfo: nil, repeats: true)
        
        self.user.updateFriendsActive()
    }
    
    func shouldCheckFriendsActive() {
        self.user.updateFriendsActive()
    }
    
    func shouldUpdateMyLocation() {
        GeolocationService.instance.update()
    }
    
    let regionRadius: CLLocationDistance = 18
    
    func centerMapOnLocation(mapView: MKMapView, coordinate: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
}

// MARK:- Main Feature UIs
extension MapHomeViewController {
    
    func alertAddFriend(proceedAction: UIAlertAction -> Void, cancelAction: UIAlertAction -> Void) {
        // display an alert
        let alert = UIAlertController(title: "Add Friend", message: "Enter friend's username", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { [unowned self] tf in
            tf.placeholder = "Friend's username"
            self.addFriendTextField = tf
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: cancelAction))
        alert.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: proceedAction))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func alertEditPhoneNumber(proceedAction: UIAlertAction -> Void, cancelAction: UIAlertAction -> Void) {
        
        self.currentPopup?.dismiss(true)
        
        let alert = UIAlertController(title: "Edit Phone Number", message: "Enter your phone number", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { [unowned self] tf in
            tf.placeholder = "09x-xxx-xxxx or 09xxxxxxxx"
            self.editPhoneTextField = tf
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: cancelAction))
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: proceedAction))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func prepareFriendProfile(username: String) -> Promise<Void> {
        return self.user.getAndUpdateFriendProfile(username)
    }
    
    func alertTapFriend(friend: RealmUserProfile) {
        
        self.targetLocation = nil
        
        let alert = UIAlertController(title: friend.username, message: "", preferredStyle: .Alert)
        
        if let phone = friend.phone where !phone.isEmpty {
            alert.addAction(alertActionPhone(friend.username, phone: phone))
        }
        
        alert.addAction(alertActionLocate(friend.username, latestCoor: friend.latestCoordinate, date: friend.latestUpdateAt))
        
        alert.addAction(alertActionRoute(friend.username))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func alertTapAnnotation(friend: RealmUserProfile) {
        
        self.targetLocation = nil
        
        let alert = UIAlertController(title: friend.username, message: "", preferredStyle: .Alert)
        if let phone = friend.phone where !phone.isEmpty {
            alert.addAction(alertActionPhone(friend.username, phone: phone))
        }
        alert.addAction(alertActionRoute(friend.username))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: Features
extension MapHomeViewController {
    
    func alertActionPhone(friendUsername: String, phone: String) -> UIAlertAction {
        return UIAlertAction(title: "Call", style: .Default, handler: { [weak self] (action) in
            self?.makePhoneCall(friendUsername, number: phone)
            })
    }
    
    func alertActionRoute(friendUsername: String) -> UIAlertAction {
        return UIAlertAction(title: "Route", style: .Default, handler: { [weak self] (action) in
            guard let `self` = self else { return }
            
            guard let myLatestLocation = self.myLatestLocation else {
                self.showTextHUD("Cannot Show Route", detail: "Please turn on location services.")
                return
            }
            
            self.clearOverlays()
            
            self.defaultLoading.value = true
            self.user
                .getFriendLocation(friendUsername).then { [unowned self] coor -> Void in
                    self.defaultLoading.value = false
                    
                    if coor.isValid {
                        self.centerMapOnLocation(self.mapView, coordinate: coor.coordinate2D)
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coor.coordinate2D
                        annotation.title = friendUsername
                        if let date = coor.updatedAtDate {
                            annotation.subtitle = date.readable
                        }
                        self.mapView.addAnnotation(annotation)
                        self.targetLocation = coor.coordinate2D
                        
                    } else {
                        self.showTextHUD("Oops", detail: "Your friend is offline.")
                    }
                    return
                }
                .then { [unowned self] in
                    guard let targetLocation = self.targetLocation else { return }
                    self.showRouteOnMap(myLatestLocation, to: targetLocation)
                }
                .onError({ [unowned self] error in
                    self.defaultLoading.value = false
                    self.showTextHUD("Error", detail: error.description())
                    })
            
            }
        )
    }
    
    func alertActionLocate(friendUsername: String, latestCoor: CLLocationCoordinate2D, date: NSDate?) -> UIAlertAction {
        return UIAlertAction(title: "Locate", style: .Default, handler: { [unowned self] (action) in
            
            self.clearOverlays()
            
            self.defaultLoading.value = true
            self.user.getFriendLocation(friendUsername).then { [unowned self] coor in
                self.defaultLoading.value = false
                
                if coor.isValid && coor.isActive {
                    
                    self.centerMapOnLocation(self.mapView, coordinate: coor.coordinate2D)
                    
                    let annotation = MKPointAnnotation()
                    
                    annotation.coordinate = coor.coordinate2D
                    annotation.title = friendUsername
                    if let date = coor.updatedAtDate {
                        annotation.subtitle = date.readable
                    }
                    
                    
                    self.mapView.addAnnotation(annotation)
                    
                } else {
                    
                    // offline coordinate
                    let coor = latestCoor
                    
                    if coor.isValid {
                        self.showTextHUD("Your friend is offline", detail: "This is his/her latest location.", delay: 3.0)
                        
                        self.centerMapOnLocation(self.mapView, coordinate: coor)
                        
                        let annotation = MKPointAnnotation()
                        
                        annotation.coordinate = coor
                        annotation.title = friendUsername
                        if let date = date {
                            annotation.subtitle = date.readable
                        }
                        
                        self.mapView.addAnnotation(annotation)
                    } else {
                        self.showTextHUD("Oops", detail: "Your friend is offline.")
                    }
                }
                }.onError({ [unowned self] error in
                    self.defaultLoading.value = false
                    self.showTextHUD("Error", detail: error.description())
                    })
            })
    }
}

extension MapHomeViewController {

    func clearOverlays() {
        // remove previous routes
        self.mapView.removeOverlays(self.mapView.overlays)
        
        // remove previous annotations
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) {
            //if annotation is not an MKPointAnnotation (eg. MKUserLocation),
            //return nil so map draws default view for it (eg. blue dot)...
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView?.image = UIImage(named:"defaultUser")!.imageWithSize(CGSize(width: 32, height: 32))
            anView?.canShowCallout = true
            anView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            
        }
        else {
            //we are re-using a view, update its annotation reference...
            anView?.annotation = annotation
        }
        
        return anView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        guard let anno = view.annotation else { return }
        guard let username = anno.title else { return }
        guard let friendUsername = username else { return }
        guard let friend = User.currentUser?.friends.filter("username = '\(friendUsername)'").first else { return }
        self.alertTapAnnotation(friend)
    }
    
    func makePhoneCall(toName: String, number: String) {
        let cleanNumber = number
            .stringByReplacingOccurrencesOfString("-", withString: "")
            .stringByReplacingOccurrencesOfString(" ", withString: "")
        
        if let url = NSURL(string: "tel://\(cleanNumber)") {
            
            let alert = UIAlertController(title: "Call to \(toName)", message: number, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Call", style: .Default, handler: { action in
                UIApplication.sharedApplication().openURL(url)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}

// MARK:- FriendPanelViewDelegate
extension MapHomeViewController: FriendPanelViewDelegate {
    
    func friendPanelViewDidSelectFriendWithUsername(username: String) {
        if let friend = user.friends.filter("username = '\(username)'").first {
            self.prepareFriendProfile(username).then { [weak self] in
                self?.alertTapFriend(friend)
                }.onError { [weak self] error in
                    self?.showTextHUD("Can't Get Latest Profile", detail: error.description(), delay: 2)
                    self?.alertTapFriend(friend)
            }
        } else {
            self.showTextHUD("Who's That !?", detail: "Friend \(username) not found.")
        }
    }
}

// MARK:- Routes
extension MapHomeViewController: MKMapViewDelegate {
    
    func showRouteOnMap(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: from, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .Walking
        
        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler { [unowned self] response, error in
            
            if let error = error {
                self.showTextHUD("Error Getting Route", detail: error.description)
            } else {
                guard let unwrappedResponse = response else {
                    self.showTextHUD("Error(1)", detail: "We don't know how to get there :(")
                    return
                }
                
                if (unwrappedResponse.routes.count > 0) {
                    self.mapView.addOverlay(unwrappedResponse.routes[0].polyline)
                    self.mapView.setVisibleMapRect(unwrappedResponse.routes[0].polyline.boundingMapRect, animated: true)
                } else {
                    self.showTextHUD("Error(2)", detail: "We don't know how to get there :(")
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.flatSkyBlueColor()
        polylineRenderer.lineWidth = 6
        return polylineRenderer
    }
    
    
}

// MARK:- ProfileViewDelegate
extension MapHomeViewController: ProfileViewDelegate {
    func profileViewLocateMeButtonPushed() {
        if meButton.isLocationAvailable {
            guard let coor = self.myLatestLocation else { return }
            self.centerMapOnLocation(self.mapView, coordinate: coor)
        } else {
            self.showTextHUD("Whoops...", detail: "Your location is not available.\nPlease turn on location services.", delay: 3)
        }
    }
    
    func profileViewEditPhoneNumberPushed() {
        self.alertEditPhoneNumber({ [unowned self] (action) in
            self.view.endEditing(true)
            
            if let phone = self.editPhoneTextField?.text where !phone.isEmpty {
                self.user.updateMyPhoneNumber(phone).then({ [weak self] phone in
                    self?.showTextHUD("Success!",detail: "Your phone number is updated. ")
                    }).onError({ [weak self] (error) in
                        let alert = HSAlert.alertInformation("Cannot Edit Phone Number", message: error.description())
                        self?.showViewController(alert, sender: nil)
                        })
            } else {
                self.showTextHUD("Success!",detail: "Your phone number is removed. ")
            }
        }) { [unowned self] (action) in
            self.view.endEditing(true)
        }
    }
    
    func profileViewExitButtonPushed() {
        let alert = HSAlert.alertDestructiveWithCancelButton("Are You Sure to Exit?", message: "Your account and all of your data (including friends) will be deleted. You need to register again to use the app.", destructiveButtonTitle: "Exit", destructiveAction: { [weak self] action in
            
            self?.user.exit()
                .then { [weak self] msg in
                    self?.clearTimers()
                    AppDelegate.shared.navigator.onExit()
                }.onError { [weak self] error in
                    self?.clearTimers()
                    AppDelegate.shared.navigator.onExit(error.description())
            }
            })
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // Fucking timers retain cycle! This is important for this vc to deallocated properly
    func clearTimers() {
        self.updateMyLocationTimer?.invalidate()
        self.updateMyLocationTimer = nil
        
        self.checkFriendsActiveTimer?.invalidate()
        self.checkFriendsActiveTimer = nil
    }
}
