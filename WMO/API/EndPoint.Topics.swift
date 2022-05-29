//
//  EndPoint.Topics.swift
//  WMO
//
//  Created by weijia on 2022/5/26.
//

import Foundation

extension EndPoint {
    enum Topics {
        case latest(by: Order = .default, ascending: Bool = false)
        case top(by: Order = .default, period: Period = .all)
        case category(slug: String, id: Int) // TODO: more params
        case tag(by: Tag) // TODO: more params

        enum Order: String {
            // latest
            case `default` // by default?
            case poster // replied latest? same as default
            case activity // seems to be the same as replied latest
            case created // created latest
            // top
            case likes
            case views
            case posts
            // N/A
            case category, op_likes
        }
        
        enum Period: String {
            case all, yearly, quarterly, monthly, weekly, daily
        }
    }
}

extension EndPoint.Topics: RESTful {
    var path: String {
        switch self {
        case .latest: return "/latest.json"
        case .top: return "/top.json"
        case .category(let slug, let id): return "/c/\(slug)/\(id).json"
        case .tag(let tag): return "/tag/\(tag).json"
        }
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    var params: [String : Any] {
        switch self {
        case .latest(let order, let ascending):
            return ["order": order.rawValue, "ascending": ascending]
        case .top(let order, let period):
            return ["order": order.rawValue, "period": period.rawValue]
        default:
            return [:]
        }
    }
}
