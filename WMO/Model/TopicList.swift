//
//  TopicList.swift
//  WMO
//
//  Created by weijia on 2022/5/25.
//

import Foundation

struct TopicList: Decodable, Equatable {
  let topics: [Topic]?
  let perPage: Int
  let canCreatTopics: Bool
  let loadMoreKey: String?
  let topTags: [String]
  
  enum CodingKeys: String, CodingKey {
    case perPage = "per_page"
    case canCreatTopics = "can_create_topic"
    case loadMoreKey = "more_topics_url"
    case topTags = "top_tags"
    case topics
  }
}

protocol Engageable {
  var eventStartDate: Date? { get }
  var eventEndDate: Date? { get }
}

struct Topic: Decodable, Equatable, Identifiable, Hashable {
  static func == (lhs: Topic, rhs: Topic) -> Bool {
    return lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  let id: Int
  let title: String
  let fancyTitle: String
  let slug: String
  let postsCount: Int
  let replyCount: Int?
  let highestPostNumber: Int?
  let imageUrl: String?
  let createdAt: String?
  let lastPostedAt: String?
  let bumped: Bool?
  let bumpedAt: String?
  let archetype: String?
  let unseen: Bool?
  let lastReadPostNumber: Int?
  let unread: Int?
  let newPosts: Int?
  let unreadPosts: Int?
  let pinned: Bool?
  let unpinned: Bool?
  let visible: Bool?
  let closed: Bool?
  let archived: Bool?
  let notificationLevel: Int?
  let bookmarked: Bool?
  let liked: Bool?
  let tags: [String]?
  let views: Int?
  let likeCount: Int?
  let hasSummary: Bool?
  let lastPosterUsername: String?
  let categoryId: Int?
  let pinnedGlobally: Bool?
  let featuredLink: String?
  let hasAcceptedAnswer: Bool?
  let posters: [Poster]?
  // events
  let eventStartsAt: String? // "2021-02-13 17:00:00"
  let eventEndsAt: String? // "2021-02-13 19:30:00"

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case fancyTitle = "fancy_title"
    case slug
    case postsCount = "posts_count"
    case replyCount = "reply_count"
    case highestPostNumber = "highest_post_number"
    case imageUrl = "image_url"
    case createdAt = "created_at"
    case lastPostedAt = "last_posted_at"
    case bumped
    case bumpedAt = "bumped_at"
    case archetype
    case unseen
    case lastReadPostNumber = "last_read_post_number"
    case unread
    case newPosts = "new_posts"
    case unreadPosts = "unread_posts"
    case pinned
    case unpinned
    case visible
    case closed
    case archived
    case notificationLevel = "notification_level"
    case bookmarked
    case liked
    case tags
    case views
    case likeCount = "like_count"
    case hasSummary = "has_summary"
    case lastPosterUsername = "last_poster_username"
    case categoryId = "category_id"
    case pinnedGlobally = "pinned_globally"
    case featuredLink = "featured_link"
    case hasAcceptedAnswer = "has_accepted_answer"
    case posters
    case eventStartsAt = "event_starts_at"
    case eventEndsAt = "event_ends_at"
  }
}

extension Topic: Engageable {
  var eventStartDate: Date? {
    if let start = eventStartsAt {
      let formatter = Date.dateFormatter
      formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      return formatter.date(from: start)
    }
    return nil
  }

  var eventEndDate: Date? {
    if let end = eventEndsAt {
      let formatter = Date.dateFormatter
      formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      return formatter.date(from: end)
    }
    return nil
  }
}
