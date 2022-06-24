//
//  UserAction.swift
//  WMO
//
//  Created by weijia on 2022/6/24.
//

import Foundation

struct UserAction: Decodable, Equatable {
    let id = UUID().uuidString
    let excerpt: String
    let truncated: Bool?
    let actionType: Int
    let createdAt: String
    let avatarTemplate: String
    let actingAvatarTemplate: String
    let slug: String
    let topicId: Int
    let targetUserId: Int
    let targetName: String
    let targetUsername: String
    let postNumber: Int
    let postId: Int
    let username: String
    let name: String?
    let userId: Int
    let actingUsername: String
    let actingName: String
    let actingUserId: Int
    let title: String
    let deleted: Bool
    let hidden: Bool
    let postType: Int
    let actionCode: Int?
    let categoryId: Int
    let closed: Bool
    let archived: Bool

    enum CodingKeys: String, CodingKey {
        case excerpt
        case truncated
        case actionType = "action_type"
        case createdAt = "created_at"
        case avatarTemplate = "avatar_template"
        case actingAvatarTemplate = "acting_avatar_template"
        case slug
        case topicId = "topic_id"
        case targetUserId = "target_user_id"
        case targetName = "target_name"
        case targetUsername = "target_username"
        case postNumber = "post_number"
        case postId = "post_id"
        case username
        case name
        case userId = "user_id"
        case actingUsername = "acting_username"
        case actingName = "acting_name"
        case actingUserId = "acting_user_id"
        case title
        case deleted
        case hidden
        case postType = "post_type"
        case actionCode = "action_code"
        case categoryId = "category_id"
        case closed
        case archived
    }
}
