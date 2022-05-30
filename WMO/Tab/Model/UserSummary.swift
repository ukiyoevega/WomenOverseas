//
//  CategoriesMenu.swift
//  WMO
//
//  Created by weijia on 2022/4/22.
//

import Foundation

// moving to the standard that Apple have created without having to bring in another library
enum User {
    
    struct Badge: Decodable, Equatable {
        let id: Int
        let name: String
        /*
         "description": "\u003ca href=\"https://blog.discourse.org/2018/06/understanding-discourse-trust-levels/\"\u003e授予\u003c/a\u003e所有基础社区功能",
         "grant_count": 9516,
         "allow_title": true,
         "multiple_grant": false,
         "icon": "fa-user",
         "image_url": null,
         "listable": true,
         "enabled": true,
         "badge_grouping_id": 4,
         "system": true,
         "slug": "-",
         "manually_grantable": false,
         "badge_type_id": 3
         */
    }
    
    struct UserBadge: Decodable, Equatable {
        let id: Int
        let grantedAt: String
        let createdAt: String
        let count: Int
        let badgeId: Int
        let userId: Int
        let grantedById: Int
        
        enum CodingKeys: String, CodingKey {
            case id
            case grantedAt = "granted_at"
            case createdAt = "created_at"
            case count
            case badgeId = "badge_id"
            case userId = "user_id"
            case grantedById = "granted_by_id"
        }
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
    
    struct Summary: Decodable, Equatable {
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
        let badges: [UserBadge]

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
            case badges
        }
        
        var statisticEntries: [(title: String, count: Int)] {
            return [("访问天数", daysVisited),
                    ("阅读时间", timeRead), ("最近阅读时间", recentTimeRead),
                    ("浏览的话题", topicsEntered), ("已读帖子", postsReadCount),
                    ("已送出", likesGivens), ("已收到", likesReceived),
                    ("话题数", topicCount), ("发帖量", postCount)] // bookmarkCount
        }
    }
}
