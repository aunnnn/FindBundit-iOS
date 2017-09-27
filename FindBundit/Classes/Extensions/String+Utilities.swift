//
//  String+Utilities.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/11/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import Foundation

private let characterset = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")

extension String {
    func isValidUsername() -> Bool {
        return self.rangeOfCharacterFromSet(characterset.invertedSet) == nil && self.characters.count >= 4
    }
    
    func removeSpecialCharacters() -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_".characters)
        return String(self.characters.filter {okayChars.contains($0) })
    }
}

extension String {
    
    static func random(length: Int = 6) -> String {
        
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            
            let randomValue = arc4random_uniform(UInt32(base.characters.count))
            randomString += "\(base[base.startIndex.advancedBy(Int(randomValue))])"
        }
        
        return randomString
    }
}
