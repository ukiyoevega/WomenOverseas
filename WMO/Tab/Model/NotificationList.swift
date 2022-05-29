//
//  Notification.swift
//  WMO
//
//  Created by weijia on 2022/5/25.
//

import Foundation

struct NotificationList: Decodable {
    let total: Int
    let seenId: String
    let loadMoreKey: String
    let notifications: [Notification]
    
    enum CodingKeys: String, CodingKey {
        case total = "total_rows_notifications"
        case seenId = "seen_notification_id"
        case loadMoreKey = "load_more_notifications"
        case notifications
    }

    struct Notification: Decodable {
        let id: String
        let userId: String
        let type: Int
        let read: Bool
        let highPriority: Bool
        let createdAt: Date // server-side as ISO8601 format
        let postNumber: String
        let topicId: String
        let slug: String
        let data: NotificationData
        
        enum CodingKeys: String, CodingKey {
            case id
            case userId
            case type
            case read
            case highPriority = "high_priority"
            case createdAt = "created_at"
            case postNumber = "post_number"
            case topicId = "topic_id"
            case slug
            case data
        }
    }
    
    struct NotificationData: Decodable {
        let badgeId: String
        let badgeName: String
        let badgeSlug: String
        let badgeTitle: Bool
        let username: String
        
        let topicTitle: String
        let originalPostId: String
        let originalPostType: Int
        let originalUsername: String
        let revisionNumber: Int?
        let displayUsername: String
        
        // TODO: CodingKeys
    }
}

//  A raw value is something that uniquely identifies a value of a particular type. “Uniquely” means that you don’t lose any information by using the raw value instead of the original value.
extension NotificationList.Notification {
    // https://github.com/discourse/discourse/blob/main/app/models/notification.rb
    enum Payload: Codable, Equatable {
        case mentioned
        case replied
        case quoted
        case edited
        case liked
        case private_message(topicTitle: String, originalPostId: String, originalPostType: Int, originalUsername: String, revisionNumber: Int?, displayUsername: String)
        case invited_to_private_message
        case invitee_accepted
        case posted
        case moved_post
        case linked
        case granted_badge(badgeId: String, badgeName: String, badgeSlug: String, topicTitle: Bool, username: String)
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
        case chat_group_mention
        case chat_quoted
        case assigned
        case question_answer_user_commented
    }
}
