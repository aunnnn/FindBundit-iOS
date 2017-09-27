//
//  Realm+Utilities.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/17/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import Foundation

import RealmSwift
import Realm

protocol CascadingDeletable {
    func childrenToDelete() -> [AnyObject?]
}

// This is quite dirty? But why do it?
// In deleteWithCascading we can't simply delete(List) because we don't know generic type of List to cast!
// So just make it CascadingDeletable and return all objects.
extension List: CascadingDeletable {
    func childrenToDelete() -> [AnyObject?] {
        return self.map { $0 }
    }
}

extension Realm {
    
    func deleteResultsWithCascading<T: Object>(realmResult: Results<T>) throws {
        // Results of Realm need to be manually enumerated to cascade delete
        let objs = realmResult.flatMap{$0}
        try objs.forEach { item in
            try deleteWithCascading(item)
        }
    }
    
    func deleteWithCascading(object: AnyObject?) throws {
        // nothing to do if nil
        guard let `object` = object else { return }
        
        if let deletable = object as? CascadingDeletable {
            try deletable.childrenToDelete().forEach{ child in
                try deleteWithCascading(child)
            }
        }
        // Actually delete the Realm Object
        if let realmObject = object as? Object {
            /// This has downside in that it has many write transactions, thus not an atomic operation.
            /// There will be intermittent result while we delete it.
            
            try self.write {
                self.delete(realmObject)
            }
        }
    }
    
    /// Perform cascading delete without realm.write called.
    /// You **must** open your own write transaction in order to use this!!!
    ///
    /// IMPORTANT: Don't use if you don't know what it's mean.
    func _deleteWithCascadingWithoutWrite(object: AnyObject?) {
        // nothing to do if nil
        guard let `object` = object else { return }
        
        if let deletable = object as? CascadingDeletable {
            deletable.childrenToDelete().forEach{ child in
                _deleteWithCascadingWithoutWrite(child)
            }
        }
        // Actually delete the Realm Object
        if let realmObject = object as? Object {
            self.delete(realmObject)
        }
    }
}