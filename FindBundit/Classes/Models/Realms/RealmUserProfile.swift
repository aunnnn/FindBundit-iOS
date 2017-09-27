//
//  RealmUserProfile.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/16/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import RealmSwift
import CoreLocation

class RealmUserProfile: Object {
    dynamic var username = ""
    
    dynamic var phone: String? = nil
    dynamic var picture: String? = nil
    
    dynamic var isActive = false
    dynamic var latestLatitude: Double = 0
    dynamic var latestLongitude: Double = 0
    dynamic var latestUpdateAt: NSDate? = nil
    
    var latestCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latestLongitude, longitude: self.latestLongitude)
    }
    
    var pictureURL: NSURL? {
        guard let picture = picture else { return nil }
        return NSURL(string: picture)
    }
    
    class func create(profile: UserProfile) -> RealmUserProfile {
        return RealmUserProfile().then { p in
            p.username = profile.username
            p.phone = profile.phone
            p.picture = profile.picture?.absoluteString
        }
    }
    
    class func create(username: String) -> RealmUserProfile {
        return RealmUserProfile().then { p in
            p.username = username
        }
    }
    
}
