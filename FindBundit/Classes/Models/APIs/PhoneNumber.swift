//
//  PhoneNumber.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/31/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import Mapper

struct PhoneNumber: Mappable {
    
    let phoneNumber: String
    
    init(map: Mapper) throws {
        try phoneNumber = map.from("phoneNumber")
    }
}
