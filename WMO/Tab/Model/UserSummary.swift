//
//  CategoriesMenu.swift
//  WMO
//
//  Created by weijia on 2022/4/22.
//

import Foundation

// moving to the standard that Apple have created without having to bring in another library
enum User {
    struct UserSummary: Decodable {
        let badge: [Badge]
        let users: [User]
        let summary: Summary
        
        enum CodingKeys: String, CodingKey {
            case badge
            case users
            case summary = "user_summary"
        }
    }

    struct Badge: Decodable {
        let name: String
    }
    
    struct User: Decodable, Equatable {
        let id: Int
        let username: String
        let name: String?
        let avatarTemplate: String
        let flairName: String?
        let admin: Bool?
        let moderator: Bool?
        let trustLevel: Int
        
        enum CodingKeys: String, CodingKey {
            case id
            case username
            case name
            case avatarTemplate = "avatar_template"
            case flairName = "flair_name"
            case admin
            case moderator
            case trustLevel = "trust_level"
        }
    }
    
    struct Summary: Decodable {
        let likesGivens: Int
        let likesReceived: Int
        let topicsEntered: Int
        let postsReadCount: Int
        let daysVisited: Int
        let topicCount: Int
        let postCount: Int
        let timeRead: Int
        let recentTimeRead: Int
        let bookmarkCount: Int
        let canSeeSummaryStats: Bool
        let solvedCount: Int

        enum CodingKeys: String, CodingKey {
            case likesGivens = "likes_given"
            case likesReceived = "likes_received"
            case topicsEntered = "topics_entered"
            case postsReadCount = "posts_read_count"
            case daysVisited = "days_visited"
            case topicCount = "topic_count"
            case postCount = "post_count"
            case timeRead = "time_read"
            case recentTimeRead = "recent_time_read"
            case bookmarkCount = "bookmark_count"
            case canSeeSummaryStats = "can_see_summary_stats"
            case solvedCount = "solved_count"
        }
    }
}
