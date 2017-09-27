//
//  ActiveStatus.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/31/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import Mapper

struct ActiveStatus: Mappable {
    let isActive: Bool
    
    init(map: Mapper) throws {
        try isActive = map.from("isActive")
    }
}