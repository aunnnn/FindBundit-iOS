//
//  AppError.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/9/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import Foundation

enum APIError {
    case InvalidJSONMapping(reason: String)
    case Custom(message: String)
    case Networking(error: NSError)
}

extension APIError: ErrorType {
    var description: String {
        switch self {
        case .InvalidJSONMapping(let reason):
            return "\(reason). (json)"
        case .Custom(let message):
            return message
        case .Networking(let error):
            return "(\(error.code)) \(error.localizedDescription)"
        }
    }
}

enum AppError: ErrorType {
    case Custom(message: String)
    
    var description: String {
        switch self {
        case .Custom(let message): return message
        }
    }
}

extension ErrorType {
    func description() -> String {
        switch self {
        case let api as APIError: return api.description
        case let app as AppError: return app.description
        case let ns as NSError:
            switch ns.code {
            case -1009: return "No internet connection."
            case 3840: return "Internal error."
            case -1001: return "Request time out."
            default: return "Oh God, unknown error."
            }
        default: return "This error is beyond expectation."
        }
    }
}