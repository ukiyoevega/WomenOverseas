//
//  EndPoint.Noti.swift
//  WMO
//
//  Created by weijia on 2022/5/26.
//

import Foundation

extension EndPoint {
  enum Noti {
    case list
  }
}

extension EndPoint.Noti: RESTful {
  var path: String {
    switch self {
    case .list: return "/notifications.json"
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
