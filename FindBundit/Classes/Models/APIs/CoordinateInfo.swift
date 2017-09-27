//
//  CoordinateInfo.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/9/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import Mapper
import Result
import CoreLocation

struct CoordinateInfo {
    
    let isActive: Bool
    
    let latitude: Double
    let longitude: Double
    
    let updatedAt: String
    let updatedAtDate: NSDate?
    
    var coordinate2D :CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var isValid: Bool {
        return coordinate2D.isValid
    }
}

extension CLLocationCoordinate2D {
    var isValid: Bool {
        if latitude == 0 || longitude == 0 { return false }
        
        if !(latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180) { return false }
        return true
    }
}

extension CoordinateInfo: Mappable {
    init(map: Mapper) throws {        
        try latitude = map.from("lat")
        try longitude = map.from("lng")
        try updatedAt = map.from("updatedAt")
        
        isActive = map.optionalFrom("isActive") ?? false
        
        updatedAtDate = updatedAt.dateFromISO8601
    }
}
