//
//  Bookmark.swift
//  WMO
//
//  Created by weijia on 2022/6/21.
//

import Foundation

struct BookmarkList: Decodable, Equatable {
  let loadMoreKey: String?
  let bookmarks: [Bookmark]
  
  enum CodingKeys: String, CodingKey {
    case loadMoreKey = "more_bookmarks_url"
    case bookmarks
  }
}

struct Bookmark: Decodable, Equatable, Identifiable {
  let id: Int
  let createdAt: String
  let updatedAt: String
  let name: String?
  let reminderAt: String?
  var pinned: Bool
  let title: String
  let fancyTitle: String
  let excerpt: String
  let bookmarkableId: Int
  let bookmarkableType: String
  let bookmarkableUrl: String
  let tags: [String]
  // TODO: tags_descriptions
  let truncated: Bool?
  let topicId: Int
  let linkedPostNumber: Int
  let deleted: Bool
  let hidden: Bool
  let categoryId: Int
  let closed: Bool
  let archived: Bool
  let archetype: String
  let highestPostNumber: Int
  let lastReadPostNumber: Int
  let bumpedAt: String
  let slug: String
  let user: User.User?
  
  enum CodingKeys: String, CodingKey {
    case id
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case name
    case reminderAt = "reminder_at"
    case pinned
    case title
    case fancyTitle = "fancy_title"
    case excerpt
    case bookmarkableId = "bookmarkable_id"
    case bookmarkableType = "bookmarkable_type"
    case bookmarkableUrl = "bookmarkable_url"
    case tags
    // tags_descriptions
    case truncated
    case topicId = "topic_id"
    case linkedPostNumber = "linked_post_number"
    case deleted
    case hidden
    case categoryId = "category_id"
    case closed
    case archived
    case archetype
    case highestPostNumber = "highest_post_number"
    case lastReadPostNumber = "last_read_post_number"
    case bumpedAt = "bumped_at"
    case slug
    case user
  }
}
