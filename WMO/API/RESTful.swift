//
//  EndPoint.swift
//  WMO
//
//  Created by weijia on 2022/4/22.
//

import Foundation

enum EndPoint {}

enum HTTPMethod {
    case GET
    case HEAD
    
    case POST
    case PUT
    case PATCH
    
    case DELETE
    case TRACE
    case OPTIONS
}

protocol RESTful {
    var path: String { get }
    var method: HTTPMethod { get }
    var params: [String: Any] { get }
}
