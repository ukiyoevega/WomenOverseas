//
//  EndPoint.swift
//  WMO
//
//  Created by weijia on 2022/4/22.
//

import Foundation

enum EndPoint {
    enum User {
        case login(phone: String)
        case logout
        case profile(phone: String)
    }
}

extension EndPoint.User: APIRequest {
    var method: Method {
        switch self {
        case .login: return .POST
        case .logout: return .GET
        case .profile: return .GET
        }
    }
    
    var parameters: [String : String] {
        switch self {
        case .login(let phoneNumber): return ["phone": phoneNumber]
        case .logout: return [:]
        case .profile(let phoneNumber): return ["phone": phoneNumber]
        }
    }
    
    var body: [String : Any] {
        return [:]
    }
    
    var path: String {
        switch self {
        case .login: return "/user/login"
        case .logout: return "/user/logout"
        case .profile: return "/user/profile"
        }
    }
}
