//
//  Search.swift
//  WMO
//
//  Created by weijia on 2022/6/19.
//

import Foundation

struct SearchResult: Decodable {
  let posts: [Post]
  let topics: [Topic]
  let users: [User.User]
  let categories: [CategoryList.Category]
  let tags: [Tag]
  let groups: [InterestGroup]
  let groupedSearchSesult: GroupedSearchSesult
  
  enum CodingKeys: String, CodingKey {
    case posts, topics, users, categories, tags, groups
    case groupedSearchSesult = "grouped_search_result"
  }
}

struct GroupedSearchSesult: Decodable {
  let morePosts: Bool?
  let moreUsers: Bool?
  let moreCategories: Bool?
  let term: String?
  let searchLogId: Int?
  let moreFullPageResults: Bool?
  let canCreateTopic: Bool?
  let error: String?
  let postIds: [Int]?
  let userIds: [Int]?
  let categoryIds: [Int]?
  let tagIds: [Int]?
  let groupIds: [Int]?
  
  enum CodingKeys: String, CodingKey {
    case morePosts = "more_posts"
    case moreUsers = "more_users"
    case moreCategories = "more_categories"
    case term
    case searchLogId = "search_log_id"
    case moreFullPageResults = "more_full_page_results"
    case canCreateTopic = "can_create_topic"
    case error
    case postIds = "post_ids"
    case userIds = "user_ids"
    case categoryIds = "category_ids"
    case tagIds = "tag_ids"
    case groupIds = "group_ids"
  }
}
