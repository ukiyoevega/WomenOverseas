//
//  Poster.swift
//  WMO
//
//  Created by weijia on 2022/5/26.
//

import Foundation

struct Post: Decodable {
    let id: Int
    let name: String?
    let username: String?
    let avatarTemplate: String?
    let createdAt: String?
    let likeCount: Int
    let blurb: String
    let postNumber: Int
    let topicId: Int

    enum CodingKeys: String, CodingKey {
        case id, name, username
        case avatarTemplate = "avatar_template"
        case createdAt = "created_at"
        case likeCount = "like_count"
        case blurb
        case postNumber = "post_number"
        case topicId = "topic_id"
    }
}

struct Poster: Decodable {
    let extras: String? // latest
    let description: String
    let uid: Int
    /*
    let primaryGroupId: Int?
    let flairGroupId: Int?
    */
    enum CodingKeys: String, CodingKey {
        case extras
        case description
        case uid = "user_id"
    }
}
