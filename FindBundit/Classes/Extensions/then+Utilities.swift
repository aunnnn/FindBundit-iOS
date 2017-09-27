//
//  then+Utilities.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/17/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import then

extension Promise {
    static func resolveWith(value: T) -> Promise<T> {
        return Promise { (resolve, _) in
            resolve(value)
        }
    }
}