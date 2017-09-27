//
//  HomeNavigator.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/17/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import Foundation

struct HomeNavigator {
    
    let user: User
    
    init(user: User) {
        self.user = user
    }
    
    func addFriend(username: String) {
        self.user.addFriend(username)
        
    }
    
}