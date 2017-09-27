//
//  UserProfile.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/12/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import Mapper

struct UserProfile: Mappable {
    let username: String
    
    let picture: NSURL?
    var phone: String?
    
    init(username: String, picture: NSURL?=nil, phone: String?=nil) {
        self.username = username
        self.picture = picture
        self.phone = phone
    }
    
    init(map: Mapper) throws {
        try username = map.from("profile.username")
            
        picture = map.optionalFrom("profile.picture")
        phone = map.optionalFrom("profile.phoneNumber")
    }
}
