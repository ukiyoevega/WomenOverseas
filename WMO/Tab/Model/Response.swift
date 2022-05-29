//
//  Response.swift
//  WMO
//
//  Created by weijia on 2022/5/28.
//

import Foundation

struct TopicListResponse: Decodable, Equatable {
    let users: [User.User]
    let topicList: TopicList
    let uuid = UUID().uuidString
    
    enum CodingKeys: String, CodingKey {
        case topicList = "topic_list"
        case users
    }
    
}

struct CategoriesResponse: Decodable {
    let categoryList: CategoryList
    
    enum CodingKeys: String, CodingKey {
        case categoryList = "category_list"
    }
    
}

struct UserResponse: Decodable {
    let badges: [User.Badge]
    let users: [User.User]
    let topics: [Topic]
    let summary: User.Summary
    
    enum CodingKeys: String, CodingKey {
        case badges
        case users
        case topics
        case summary = "user_summary"
    }
}
