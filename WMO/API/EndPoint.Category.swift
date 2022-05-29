//
//  CategoryList.API.swift
//  WMO
//
//  Created by weijia on 2022/5/26.
//

import Foundation

extension EndPoint {
    enum Category {
        case list
    }
    
    enum Tag {
        case list
    }
}

extension EndPoint.Category: RESTful {
    var path: String {
        switch self {
        case .list: return "/categories.json"
        }
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    var params: [String : Any] {
        switch self {
        case .list: return [:]
        }
    }
}

extension EndPoint.Tag: RESTful {
    var path: String {
        switch self {
        case .list: return "/tags.json"
        }
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    var params: [String : Any] {
        switch self {
        case .list: return [:]
        }
    }
}
