//
//  EndPoint.Topics.swift
//  WMO
//
//  Created by weijia on 2022/5/26.
//

import Foundation

extension EndPoint {
    enum Topics {
        case latest(by: Order = .default, ascending: Bool = false, page: Int = 0)
        case top(by: Order = .default, period: Period = .all, page: Int = 0)
        case category(slug: String, id: Int, page: Int = 0, order: Order? = nil)
        case tag(by: String, page: Int = 0)
        // user activities
        case history(page: Int)

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

            var icon: String {
                switch self {
                case .likes:
                    return "heart.fill"
                case .views:
                    return "eye.fill"
                case .posts:
                    return "text.bubble.fill"
                case .`default`:
                    return "flame.fill"
                default:
                    return ""
                }
            }
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
        case .category(let slug, let id, _, _): return "/c/\(slug)/\(id).json"
        case .tag(let tag, _):
            let escapedTag = tag.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
            return "/tag/\(escapedTag).json"
        case .history:
            return "/read.json"
        }
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    var params: [String : Any] {
        switch self {
        case .latest(let order, let ascending, let page):
            return ["order": order.rawValue, "ascending": ascending, "page": page]
        case .top(let order, let period, let page):
            return ["order": order.rawValue, "period": period.rawValue, "page": page]
        case .category(_, _, let page, let order):
            var params: [String: Any] = ["page": page]
            if let order = order {
                params["order"] = order.rawValue
            }
            return params
        case .tag(_, let page):
            return ["page": page]
        case .history(let page):
            return ["page": page]
        }
    }
}
