//
//  CategoryList.API.swift
//  WMO
//
//  Created by weijia on 2022/5/26.
//

import Foundation

extension EndPoint {
    enum Category {
        case list(includeSubcategories: Bool = false)
        case sublist(parentId: Int)
    }
    
    enum Tag {
        case list
    }
}

extension EndPoint.Category: RESTful {
    var path: String {
        switch self {
        case .list, .sublist: return "/categories.json"
        }
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    var params: [String : Any] {
        switch self {
        case .list(let includeSub):
            if includeSub {
                return ["include_subcategories": includeSub]
            }
            return [:]
        case .sublist(let parentId): return ["parent_category_id": parentId]
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
