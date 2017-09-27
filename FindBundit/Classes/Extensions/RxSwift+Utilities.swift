//
//  RxSwift+Utilities.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/16/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import RxSwift

extension ObservableType where E: BooleanType {
    
    /// Boolean not operator
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func not() -> Observable<Bool> {
        return self.map { value -> Bool in
            return !value
        }
    }
}