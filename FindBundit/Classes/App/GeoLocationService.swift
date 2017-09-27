//
//  GeoLocationService.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/9/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

class GeolocationService {
    
    static let instance = GeolocationService()
    private (set) var autorized: Driver<Bool>
    private (set) var location: Driver<CLLocationCoordinate2D>
    private (set) var failure: Observable<NSError>
    
    private let locationManager = CLLocationManager()
    private let disposeBag = DisposeBag()
    
    private init() {
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        autorized = locationManager.rx_didChangeAuthorizationStatus
            .startWith(CLLocationManager.authorizationStatus())
            .asDriver(onErrorJustReturn: CLAuthorizationStatus.NotDetermined)
            .map {
                switch $0 {
                case .AuthorizedAlways:
                    return true
                default:
                    return false
                }
        }
        
        location = locationManager.rx_didUpdateLocations
            .asDriver(onErrorJustReturn: [])
            .filter { $0.count > 0 }
            .map {
                return $0.last!.coordinate
            }
        
        failure = locationManager.rx_didFailWithError
        
        location
            .driveNext { [unowned self] _ in                
                self.locationManager.stopUpdatingLocation()
            }
            .addDisposableTo(disposeBag)
        
        locationManager.requestWhenInUseAuthorization()
        update()
    }
    
    func update() {
        locationManager.startUpdatingLocation()
    }
    
}