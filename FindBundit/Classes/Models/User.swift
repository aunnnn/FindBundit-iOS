//
//  User.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/9/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import Moya
import RxSwift
import CoreLocation
import then
import Mapper
import RealmSwift
import RxRealm

class User: Object, CascadingDeletable {
    
    dynamic var token = ""
    dynamic var password = ""
    dynamic var profile: RealmUserProfile?
    
    let friends = List<RealmUserProfile>()
    
    private convenience init(profile: UserProfile, token: String, password: String) {
        self.init()
        self.profile = RealmUserProfile.create(profile)
        self.token = token
        self.password = password
    }
    
    func childrenToDelete() -> [AnyObject?] {
        return [profile, friends]
    }
}

extension User {

    private static let provider = MoyaProvider<MainAPI>()
        
    static func login(profile: UserProfile, password: String) -> Promise<User> {
        return
            MoyaProviderMapper<MainAPI, TokenString>(provider: provider)
                .requestAndMapObject(MainAPI.login(username: profile.username, password: password))
                .then { persistUser(profile, token: $0.token, password: password) }
    }
    
    static func register(profile: UserProfile, password: String) -> Promise<User> {
        return
            MoyaProviderMapper<MainAPI, TokenString>(provider: provider)
                .requestAndMapObject(MainAPI.register(profile: profile, password: password))
                .then { persistUser(profile, token: $0.token, password: password) }
    }
    
    func renewToken() -> Promise<User> {
        return
            MoyaProviderMapper<MainAPI, TokenString>(provider: User.provider)
                .requestAndMapObject(MainAPI.login(username: self.profile?.username ?? "", password: password))
                .then { [unowned self] in self.persistToken($0.token) }
    }
    
    func addFriend(username: String) -> Promise<Void> {
        return
            MoyaProviderMapper<MainAPI, UserProfile>(provider: User.provider)
                .requestAndMapObject(MainAPI.addFriend(friendUsername: username, token: token))
                .then { [unowned self] in self.persistFriend($0) }
    }
    
    func updateMyLocation(location: CLLocationCoordinate2D) -> Promise<CoordinateInfo> {
        let lat = location.latitude
        let lng = location.longitude
        return
            MoyaProviderMapper<MainAPI, CoordinateInfo>(provider: User.provider)
                .requestAndMapObject(MainAPI.updateMyLocation(lat: lat, lng: lng, token: self.token))
    }
    
    func updateFriendsActive() {
        // loop all friends and check their status
        for profile in self.friends {
            if profile.invalidated { continue }
            self.getFriendLocation(profile.username).onError({ [unowned self] (error) in
                
                // set to false if error
                self.persistUpdateFriendActive(profile.username, isActive: false)
            }).start()
        }
    }
    
    func updateMyActive(active: Bool) -> Promise<ActiveStatus> {
        return
            MoyaProviderMapper<MainAPI, ActiveStatus>(provider: User.provider)
                .requestAndMapObject(MainAPI.updateMyActive(isActive: active, token: self.token))
    }
    
    func updateMyPhoneNumber(phone: String) -> Promise<String> {
        return
            MoyaProviderMapper<MainAPI, PhoneNumber>(provider: User.provider)
                .requestAndMapObject(MainAPI.updatePhoneNumber(phone: phone, token: self.token))
                .then({ [unowned self] (phoneNumber) in
                    self.persistUpdatePhoneNumber(phoneNumber.phoneNumber)
                })
    }
    
    func getFriendLocation(username: String) -> Promise<CoordinateInfo> {
        return
            MoyaProviderMapper<MainAPI, CoordinateInfo>(provider: User.provider)
                .requestAndMapObject(MainAPI.getFriendLocation(name: username, token: self.token))
                .then({ [weak self] (coor) in
                    self?.persistUpdateFriendLocation(username, coor: coor)
                    return Promise.resolveWith(coor)
                })
    }
    
    func getAndUpdateFriendProfile(username: String) -> Promise<Void> {
        return
            MoyaProviderMapper<MainAPI, UserProfile>(provider: User.provider)
                .requestAndMapObject(MainAPI.getFriendProfile(name: username, token: self.token))
                .then({ [unowned self] (friend) in
                    return self.persistUpdateFriendProfile(username, updatedProfile: friend)
                })
    }
    
    func exit() -> Promise<String> {
        return MoyaProviderMapper<MainAPI, APIMessage>(provider: User.provider)
            .requestAndMapObject(MainAPI.exit(token: self.token))
            .then({ (message) in
                return Promise.resolveWith(message.message)
            })
    }
}

extension User {
    
    
    static let realm = try! Realm()
    static let users = realm.objects(User)
    static let userProfiles = realm.objects(RealmUserProfile)
    
    static var currentUser: User? {
        return users.first
    }
    
    static func persistUser(profile: UserProfile, token: String, password: String) -> Promise<User> {
        return Promise { (resolve, reject) in
            do {
                
                try User.realm.deleteResultsWithCascading(users)
                
                try realm.write {
                    let user = User(profile: profile, token: token, password: password)
                    
                    // add
                    User.realm.add(user)
                    
                    resolve(user)
                }
            } catch let error {
                reject(error)
            }
            
        }
    }
    
    func persistToken(token: String) -> Promise<User> {
        return Promise { [unowned self] (resolve, reject) in
            do {
                try User.realm.write {
                    self.token = token
                    resolve(self)
                }
            } catch let error {
                reject(error)
            }
            
        }
    }
    
    func persistUserProfile(profile: UserProfile) -> Promise<RealmUserProfile> {
        return Promise { [unowned self] (resolve, reject) in
            do {
                try User.realm.write {
                    
                    if let currentProfile = self.profile {
                        User.realm.delete(currentProfile)
                    }
                    
                    let newProfile = RealmUserProfile.create(profile)
                    User.realm.add(newProfile)
                    self.profile = newProfile
                    
                    resolve(newProfile)
                }
            } catch let error {
                reject(error)
            }
            
        }
    }
    
    func persistUpdatePhoneNumber(phone: String) -> Promise<String> {
        return Promise { [unowned self] (resolve, reject) in
            do {
                try User.realm.write {
                    self.profile?.phone = phone
                    resolve(phone)
                }
            } catch let error {
                reject(error)
            }
            
        }
    }
    
    func persistUpdateFriendProfile(username: String, updatedProfile: UserProfile) -> Promise<Void> {
        return Promise { (resolve, reject) in
            do {
                if let profile = User.userProfiles.filter("username = '\(username)'").first {
                    try User.realm.write {
                        profile.phone = updatedProfile.phone
                        profile.username = updatedProfile.username
                        profile.picture = updatedProfile.picture?.absoluteString
                        resolve()
                    }
                } else {
                    reject(APIError.Custom(message: "Local friend profile not found."))
                }
            } catch let error {
                reject(error)
            }
        }
    }
    
    func persistUpdateFriendLocation(username: String, coor: CoordinateInfo) {
        do {
            if let profile = User.userProfiles.filter("username = '\(username)'").first {
                try User.realm.write {
                    profile.isActive = coor.isActive
                    profile.latestLatitude = coor.latitude
                    profile.latestLongitude = coor.longitude
                    profile.latestUpdateAt = coor.updatedAtDate
                }
            }
        } catch let error {
            print("Cannot update is active for user: \(username), \(error)")
        }
    }
    
    func persistUpdateFriendActive(username: String, isActive: Bool) {
        do {
            if let profile = User.userProfiles.filter("username = '\(username)'").first {
                try User.realm.write {
                    profile.isActive = isActive
                }
            }
        } catch let error {
            print("Cannot update is active for user: \(username), \(error)")
        }
    }
    
    func persistFriend(friend: UserProfile) -> Promise<Void> {
        return Promise { [unowned self] (resolve, reject) in
            do {
                let newFriend = RealmUserProfile.create(friend)
                
                try User.realm.write {
                    User.realm.add(newFriend)
                    self.friends.append(newFriend)
                }
                resolve()
            } catch let error {
                reject(error)
            }
        }
    }
}
