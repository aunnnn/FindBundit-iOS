//
//  TokenString.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/13/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import Mapper


struct TokenString: Mappable {
    let token: String
    
    init(map: Mapper) throws {
        try token = map.from("token")
    }
}