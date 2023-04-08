//
//  Notification.swift
//  WMO
//
//  Created by weijia on 2022/5/25.
//

import Foundation

struct NotificationMessage: Decodable, Equatable, Identifiable {
  let id: Int
  let userId: Int
  let externalId: Int?
  let type: `Type`?
  let read: Bool
  let highPriority: Bool
  let createdAt: String // server-side as ISO8601 format
  let postNumber: Int?
  let topicId: Int?
  let fancyTitle: String?
  let slug: String?
  let payload: Payload
  let isWarning: Bool?
  
  enum CodingKeys: String, CodingKey {
    case id
    case userId = "user_id"
    case type = "notification_type"
    case read
    case highPriority = "high_priority"
    case createdAt = "created_at"
    case postNumber = "post_number"
    case topicId = "topic_id"
    case slug
    case payload = "data"
    
    case externalId = "external_id"
    case fancyTitle = "fancy_title"
    case isWarning = "is_warning"
  }
}

extension NotificationMessage {
  struct Payload: Decodable, Equatable {
    // MARK: granted_badge
    let badgeId: Int?
    let badgeName: String?
    let badgeSlug: String?
    let badgeTitle: Bool?
    let username: String?
    // MARK: private_message, posted, mentioned, watching_first_post, replied
    let topicTitle: String?
    let originalPostId: Int?
    let originalPostType: Int?
    let originalUsername: String?
    let revisionNumber: Int?
    let displayUsername: String?
    // MARK: bookmark_reminder
    let title: String?
    let bookmarkName: String?
    let bookmarkableUrl: String?
    // MARK: liked_consolidated
    let count: Int?
    // MARK: group_message_summary
    let groupId: Int?
    let groupName: String?
    let inboxCount: Int?
    
    enum CodingKeys: String, CodingKey {
      case badgeId = "badge_id"
      case badgeName = "badge_name"
      case badgeSlug = "badge_slug"
      case badgeTitle = "badge_title"
      case username
      
      case topicTitle = "topic_title"
      case originalPostId = "original_post_id"
      case originalPostType = "original_post_type"
      case originalUsername = "original_username"
      case revisionNumber = "revision_number"
      case displayUsername = "display_username"
      
      case title
      case bookmarkName = "bookmark_name"
      case bookmarkableUrl = "bookmarkable_url"
      case count
      
      case groupId = "group_id"
      case groupName = "group_name"
      case inboxCount = "inbox_count"
      
    }
  }
  
  enum `Type`: Int, Decodable {
    
    var icon: String {
      switch self {
      case .replied: return "arrowshape.turn.up.left"
      case .mentioned: return "at"
      case .liked: return "heart"
      case .edited: return "pencil"
      case .quoted: return "quote.opening"
      case .posted: return "arrowshape.turn.up.left"
      case .granted_badge: return "checkmark.seal"
      case .private_message: return "envelope"
      case .linked: return "link"
      default:
        return ""
      }
    }
    
    case mentioned = 1
    case replied
    case quoted
    case edited
    case liked
    /*
     (topicTitle: String, originalPostId: String, originalPostType: Int, originalUsername: String, revisionNumber: Int?, displayUsername: String)
     */
    case private_message
    case invited_to_private_message
    case invitee_accepted
    case posted
    case moved_post
    case linked
    /*
     (badgeId: String, badgeName: String, badgeSlug: String, topicTitle: Bool, username: String)
     */
    case granted_badge
    case invited_to_topic
    case custom
    case group_mentioned
    case group_message_summary
    case watching_first_post
    case topic_reminder
    case liked_consolidated
    case post_approved
    case code_review_commit_approved
    case membership_request_accepted
    case membership_request_consolidated
    case bookmark_reminder
    case reaction
    case votes_released
    case event_reminder
    case event_invitation
    case chat_mention
    case chat_message
    case chat_invitation
    case chat_group_mention // March 2022 - This is obsolete, as all chat_mentions use `chat_mention` type
    case chat_quoted
    case assigned
    case question_answer_user_commented // Used by https://github.com/discourse/discourse-question-answer
  }
}
