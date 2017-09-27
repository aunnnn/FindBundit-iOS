//
//  FailedMessage.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/9/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import Mapper

struct IsAPISuccess: Mappable {
    
    let success: Bool
    
    init(map: Mapper) throws {
        try success = map.from("success")
    }
}

struct IsStatusOK: Mappable {
    let status: String
    
    init(map: Mapper) throws {
        try status = map.from("status")
    }
}

struct APIMessage: Mappable {
    let message: String
    
    init(map: Mapper) throws {
        try message = map.from("message") ?? map.from("message.message") ??  map.from("message.errmsg")
    }
}