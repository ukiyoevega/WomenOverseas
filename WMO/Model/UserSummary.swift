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
    }

    struct FlairGroup: Decodable, Equatable {
        let id: Int
        let name: String
        let flairURL: String?
        let fullName: String?

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case flairURL = "flair_url"
            case fullName = "full_name"
        }
    }

    struct UserBadge: Decodable, Equatable {
        let id: Int
        let grantedAt: String
        let createdAt: String?
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

        func getInfo(_ infoEntry: EditEntry) -> String? {
            switch infoEntry {
            case .avatar:
                return nil
            case .name:
                return self.name
            case .bio_raw:
                return self.bioRaw
            case .title:
                return self.title
            case .group:
                return self.flairName
            case .website:
                return self.websiteName
            case .date_of_birth:
                return self.birthday
            }
        }

        let id: Int
        let username: String
        let name: String?
        let avatarTemplate: String
        let flairName: String? // LGBTQ
        let flairGroupId: Int?
        let groups: [FlairGroup]?
        
        let email: String?
        let lastPostedAt: String?
        let lastSeenAt: String?
        let createdAt: String?
        let timezone: String?
        let canUploadProfileHeader: Bool?
        let canUploadUserCardBackground: Bool?
        let canChangeBio: Bool?
        let canChangeLocation: Bool?
        let canChangeWebsite: Bool?
        let canChangeTrackingPreference: Bool?
        let birthday: String?
        let website: String?
        let websiteName: String?

        let admin: Bool?
        let moderator: Bool?
        let trustLevel: Int
        let bioRaw: String?
        let flairURL: String?
        let title: String?
        let customAvatarTemplate: String?
        let systemAvatarTemplate: String?

        enum CodingKeys: String, CodingKey {
            case id
            case username
            case name
            case avatarTemplate = "avatar_template"
            case flairName = "flair_name"
            case flairGroupId = "flair_group_id"
            case groups
            
            case admin
            case moderator
            case trustLevel = "trust_level"
            case bioRaw = "bio_raw"
            case flairURL = "flair_url"
            case title
            case customAvatarTemplate = "custom_avatar_template"
            case systemAvatarTemplate = "system_avatar_template"
            
            case email
            case lastPostedAt = "last_posted_at"
            case lastSeenAt = "last_seen_at"
            case createdAt = "created_at"
            case timezone
            
            case canUploadProfileHeader = "can_upload_profile_header"
            case canUploadUserCardBackground = "can_upload_user_card_background"
            case canChangeBio = "can_change_bio"
            case canChangeLocation = "can_change_location"
            case canChangeWebsite = "can_change_website"
            case canChangeTrackingPreference = "can_change_tracking_preferences"
            case birthday = "date_of_birth"
            case website
            case websiteName = "website_name"
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
        let bookmarkCount: Int?
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
            case timeRead = "time_read" //
            case recentTimeRead = "recent_time_read" //
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
