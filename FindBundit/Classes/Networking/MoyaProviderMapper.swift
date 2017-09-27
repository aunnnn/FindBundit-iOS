//
//  MoyaProviderMapper.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/10/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import Moya
import Mapper
import Moya_ModelMapper
import Result
import then


struct MoyaProviderMapper<T: TargetType, M: Mappable> {
    
    let provider: MoyaProvider<T>
    
    init(provider: MoyaProvider<T>) {
        self.provider = provider
    }
    
    func requestAndMapObject(api: T) -> Promise<M> {
        return Promise(callback: { [unowned provider] (resolve, reject) in
            provider.request(api) { result in
                switch result {
                case .Success(let response):
                    
//                    print("Raw json is \(String(data: response.data, encoding: NSUTF8StringEncoding))")
                    
                    do {                        
                        let checkable = try response.mapObject() as IsAPISuccess
                        
                        guard checkable.success else {
                            do {
                                let failed = try response.mapObject() as APIMessage
                                reject(APIError.Custom(message: failed.message))
                                return
                            } catch _ {
                                reject(APIError.InvalidJSONMapping(reason: "There's something wrong. Please try again."))
                                return
                            }                            
                        }
                        
                        // success = true
                        do {
                            let model = try response.mapObject() as M
                            resolve(model)
                        } catch let error {
                            reject(APIError.InvalidJSONMapping(reason: "Cannot convert to model '\(M.self)'. (\(error))"))
                        }
                        return
                        
                    } catch let error {
                        
                        // second try
                        do {
                            let isOk = try response.mapObject() as IsStatusOK
                            if isOk.status == "OK" {
                                // success = true
                                do {
                                    let model = try response.mapObject() as M
                                    resolve(model)
                                } catch let error {
                                    reject(APIError.InvalidJSONMapping(reason: "Cannot convert to model '\(M.self)'. (\(error))"))
                                }
                            } else {
                                reject(APIError.InvalidJSONMapping(reason: "\(error)"))
                            }
                        } catch let error2 {
                            reject(APIError.InvalidJSONMapping(reason: "\(error2)"))
                        }
                        
                        return
                    }
                case .Failure(let error):
                    switch error {
                    case .Underlying(let nserror):
                        reject(APIError.Networking(error: nserror))
                    default:
                        reject(APIError.Custom(message: "Something wrong..."))
                    }                    
                }
            }
        })
    }
}
