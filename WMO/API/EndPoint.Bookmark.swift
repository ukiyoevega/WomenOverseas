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
    case delete(id: Int)
    case togglePin(id: Int)
  }
}

extension EndPoint.Bookmarks: RESTful {
  var method: HTTPMethod {
    switch self {
    case .delete:
      return .DELETE
    case .togglePin:
      return .PUT
    default:
      return .GET
    }
  }
  
  var params: [String : Any] {
    switch self {
    case .list(_, let page):
      return ["page": page]
    default:
      return [:]
    }
  }
  
  var path: String {
    switch self {
    case .togglePin(let id):
      return "/bookmarks/\(id)/toggle_pin"
    case .delete(let id):
      return "/bookmarks/\(id)"
    case .list(let username, _):
      return "/u/\(username)/bookmarks.json"
    }
  }
}
