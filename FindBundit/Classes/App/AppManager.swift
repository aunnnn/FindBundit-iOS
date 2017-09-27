//
//  AppManager.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/9/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import Moya
import RxSwift

class AppManager {
    
    let shared = AppManager()
    
    private(set) var currentUser: User?
    
    private init() {}
    
}