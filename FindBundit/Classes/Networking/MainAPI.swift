//
//  MainAPI.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/7/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import Moya

enum MainAPI {
    case register(profile: UserProfile, password: String)
    case login(username: String, password: String)
    case getMyProfile(token: String)
    
    case addFriend(friendUsername: String, token: String)
    case updateMyLocation(lat: Double, lng: Double, token: String)
    case updateMyActive(isActive: Bool, token: String)
    case updatePhoneNumber(phone: String, token: String)
    
    case getFriendLocation(name: String, token: String)
    case getFriendProfile(name: String, token: String)
    
    case exit(token: String)
}

extension MainAPI: TargetType {
//    var baseURL: NSURL { return NSURL(string: "http://169.254.200.51:3000/api")! }
//    var baseURL: NSURL { return NSURL(string: "http://localhost:3000/api")! }
    var baseURL: NSURL { return NSURL(string: "https://mmarcl.com/api")! }
    
    var path: String {
        switch self {
        case .register:                         return "/register"
        case .login:                            return "/login"
        case .getMyProfile:                     return "/getMyProfile"
        case .updateMyLocation:                 return "/updateMyLocation"
        case .updateMyActive:                   return "/updateMyActive"
        case .getFriendLocation(let name, _):   return "/getFriendLocation/\(name)"
        case .getFriendProfile:                 return "/getFriendProfile"
        case .addFriend:                        return "/addFriend"
        case .updatePhoneNumber:                return "/updatePhoneNumber"
        case .exit:                             return "/exit"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getFriendLocation,
             .getFriendProfile,
             .getMyProfile:
            return .GET
            
        default: return .POST
        }
    }
    
    var parameters: [String : AnyObject]? {
        switch self {
        case .register(let profile, let password):
            var dic: [String: AnyObject] = [:]
            dic["username"] = profile.username
            dic["password"] = password
            dic["phoneNumber"] = profile.phone
            if let pic = profile.picture?.absoluteString {
                dic["profilePicture"] = pic
            }
            return dic

        case .login(let username, let password):
            return [
                "username": username,
                "password": password
            ]
            
        case .getMyProfile(let token):
            return [
                "token": token
            ]
            
        case .updateMyLocation(let lat, let lng, let token):
            return [
                "lat": lat,
                "lng": lng,
                "token": token
            ]
            
        case .updateMyActive(let isActive, let token):
            return [
                "isActive": isActive,
                "token": token
            ]
            
        case .getFriendLocation(_, let token):
            return [                
                "token": token
            ]
            
        case .getFriendProfile(let name, let token):
            return [
                "friendUsername": name,
                "token": token
            ]
            
        case .addFriend(let friendUsername, let token):
            return [
                "friendUsername": friendUsername,
                "token": token
            ]
            
        case .updatePhoneNumber(let phone, let token):
            return [
                "phoneNumber": phone,
                "token": token
            ]
            
        case .exit(let token):
            return [
                "token": token
            ]
        }
        
    }
    
    var sampleData: NSData {
        return NSData()
    }
    
    var multipartBody: [MultipartFormData]? {
        return nil
    }
}

