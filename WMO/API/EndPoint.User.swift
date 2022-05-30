//
//  EndPoint.User.swift
//  WMO
//
//  Created by weijia on 2022/5/26.
//

import Foundation

enum Preference: String {
    case email
    case username
}

enum UploadType: String {
    case avatar
    case profileBackground = "profile_background"
    case cardBackground = "card_background"
    case customEmoji = "custom_emoji"
    case composer
}

extension EndPoint {
    enum User {
        case getUser(name: String)
        case summary(username: String)
        case activity(username: String) // N/A
        // detailed
        case followings(username: String)
        case followers(username: String)
        case badges(username: String)
        // settings
        case preference(name: String, type: String, payload: String)
        case upload(file: Data, type: UploadType, uid: Int)
    }
    
}

extension EndPoint.User: RESTful {
    
    var path: String {
        switch self {
        case .getUser(let name): return "/u/\(name).json"
        case .summary(let name): return "/u/\(name)/summary.json"
        case .activity(let name): return "/u/\(name)/activity.json"
        case .followings(let name): return "/u/\(name)/follow/following.json"
        case .followers(let name): return "/u/\(name)/follow/followers.json"
        case .badges(let name): return "/user-badges/\(name).json"
        case .preference(let name, let type, _): return "/u/\(name)/preferences/\(type).json"
        case .upload: return "/uploads.json"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .upload: return .POST
        case .preference: return .PUT
        default: return .GET
        }
    }
    
    var params: [String : Any] {
        switch self {
        case .preference(let name, let type, let payload):
            return ["username": name, type: payload]
        case .upload(let file, let type, let uid):
            return ["type": type.rawValue, "user_id": uid, "file": file] // TODO: decode data
        default:
            return [:]
        }
    }
}
