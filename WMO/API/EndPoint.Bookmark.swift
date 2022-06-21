//
//  EndPoint.Bookmark.swift
//  WMO
//
//  Created by weijia on 2022/6/21.
//

import Foundation

extension EndPoint {
    enum Bookmarks {
        case list(username: String, page: Int)
    }
}

extension EndPoint.Bookmarks: RESTful {
    var method: HTTPMethod {
        return .GET
    }

    var params: [String : Any] {
        switch self {
        case .list(_, let page): return ["page": page]
        }
    }

    var path: String {
        switch self {
        case .list(let username, _):
            return "/u/\(username)/bookmarks.json"
        }
    }
}
