//
//  Fonts.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/10/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import UIKit

struct Fonts {
    
    static let normalFontName = "Avenir-Book"
    static let boldFontName = "Avenir-Heavy"
    static let lightFontName = "Avenir-Light"
    
    static func normal(size: CGFloat=16) -> UIFont {
        return UIFont(name: normalFontName, size: size)!
    }
    
    static func normalTiny() -> UIFont {
        return normal(12)
    }
    
    static func bold(size: CGFloat=16) -> UIFont {
        return UIFont(name: boldFontName, size: size)!
    }
    
    static func boldPrimary() -> UIFont {
        return bold(20)
    }
    
    static func boldSecondary() -> UIFont {
        return bold(16)
    }
    
    static func light(size: CGFloat=16) -> UIFont {
        return UIFont(name: lightFontName, size: size)!
    }
}