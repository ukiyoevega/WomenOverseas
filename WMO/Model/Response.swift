//
//  Response.swift
//  WMO
//
//  Created by weijia on 2022/5/28.
//

import Foundation

// https://meta.discourse.org/t/how-to-get-notifications-via-the-api/120951
struct NotificationResponse: Decodable {
  let total: Int?
  let seenId: Int?
  let loadMoreKey: String?
  let notifications: [NotificationMessage]
  
  enum CodingKeys: String, CodingKey {
    case total = "total_rows_notifications"
    case seenId = "seen_notification_id"
    case loadMoreKey = "load_more_notifications"
    case notifications
  }
}

struct BookmarkResponse: Decodable, Equatable {
  let bookmarkList: BookmarkList?
  
  enum CodingKeys: String, CodingKey {
    case bookmarkList = "user_bookmark_list"
  }
}

struct UserActionResponse: Decodable, Equatable {
  let userActions: [UserAction]?
  
  enum CodingKeys: String, CodingKey {
    case userActions = "user_actions"
  }
}

struct TopicListResponse: Decodable, Equatable {
  let users: [User.User]?
  let topicList: TopicList?
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

struct TagsResponse: Decodable {
  let tags: [Tag]
}

struct UserResponse: Decodable, Equatable {
  let badges: [User.Badge]?
  let userBadges: [User.UserBadge]? // UserBadge.badgeId -> Badge.id
  let users: [User.User]?
  var user: User.User? // udpate profile will set
  
  enum CodingKeys: String, CodingKey {
    case badges
    case userBadges = "user_badges"
    case users
    case user
  }
  
  static let empty = UserResponse(badges: [], userBadges: [], users: [], user: User.User(id: 1, username: "", name: nil, avatarTemplate: "", flairName: nil, flairGroupId: nil, groups: nil, email: nil, lastPostedAt: nil, lastSeenAt: nil, createdAt: nil, viewCount: 111, timezone: nil, canUploadProfileHeader: false, canUploadUserCardBackground: false, canChangeBio: false, canChangeLocation: false, canChangeWebsite: false, canChangeTrackingPreference: false, birthday: "", website: nil, websiteName: nil, admin: nil, moderator: nil, trustLevel: 1, bioRaw: nil, flairURL: nil, title: nil, customAvatarTemplate: nil, systemAvatarTemplate: nil))
}

struct UserSummaryResponse: Decodable, Equatable {
  let badges: [User.Badge]?
  let users: [User.User]?
  let topics: [Topic]?
  let summary: User.Summary
  
  enum CodingKeys: String, CodingKey {
    case badges
    case users
    case topics
    case summary = "user_summary"
  }
  
  static let empty = UserSummaryResponse(badges: [], users: [], topics: [],
                                         summary: User.Summary(likesGivens: 0, likesReceived: 0, topicsEntered: 0, postsReadCount: 0, daysVisited: 0, topicCount: 0, postCount: 0, timeRead: 0, recentTimeRead: 0, bookmarkCount: 0, canSeeSummaryStats: false, solvedCount: 0, badges: []))
}

// MARK: - Settings Helper

extension UserResponse {
  func updatedBadgeName(id: Int) -> String {
    if id == -1 { return "" }
    return self.badges?.first(where: { $0.id == id })?.name ?? ""
  }
  
  var selectedBadge: User.Badge {
    let emptyBadge = User.Badge(id: -1, name: "")
    switch self.badges {
    case .none:
      return emptyBadge
    case .some(let content):
      if user?.title?.isEmpty == true || user?.title == nil {
        return emptyBadge
      } else {
        return content.first(where: { $0.name == self.user?.title }) ?? emptyBadge
      }
    }
  }
}
