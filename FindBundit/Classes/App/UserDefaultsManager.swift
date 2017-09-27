//
//  UserDefaultsManager.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/13/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    private init() {
        
    }
    
    private func getValue(forKey key: String) -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().valueForKey(key)
    }
    
    private func setValue(value: AnyObject?, forKey key: String) {
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}