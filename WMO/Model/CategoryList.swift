//
//  Categories.swift
//  WMO
//
//  Created by weijia on 2022/5/24.
//

import Foundation

struct CategoryList: Decodable, Equatable {
    
    let canCreateTopic: Bool
    let canCreateCategories: Bool
    let categories: [Category]
    
    enum CodingKeys: String, CodingKey {
        case categories
        case canCreateTopic = "can_create_topic"
        case canCreateCategories = "can_create_category"
    }

    struct Category: Decodable, Equatable {
        let id: Int
        let name: String // 论坛活动(Events), 职业生涯(Career)
        let slug: String // events, career
        let color: String
        let textColor: String
        let topicCount: Int
        let postCount: Int
        let position: Int
        let description: String?
        let descriptionText: String?
        let descriptionExcerpt: String?
        let topicUrl: String
        let readRestricted: Bool
        let permission: Int
        let notificationLevel: Int?
        let topicTemplate: String
        let hasChildren: Bool
        let sortOrder: String
        let sortAscending: Bool?
        let showSubcategoryList: Bool
        let numFeaturedTopics: Int
        let defaultView: String
        let subcategoryListStyle: String
        let defaultTopPeriod: String
        let defaultListFilter: String
        let minimumRequiredTags: Int
        let navigateToFirstPostAfterRead: Bool
        let topicsDay: Int
        let topicsWeek: Int
        let topicsMonth: Int
        let topicsYear: Int
        let topicsAllTime: Int
        let subcategoryIds: [Int]
        let uploadedLogo: String?
        let uploadedBackground: String?
        // TODO: support
//        let topics: [Topic]
        
        var displayName: String {
            return name.components(separatedBy: .init(charactersIn: " (（")).first ?? name
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case color
            case textColor = "text_color"
            case slug
            case topicCount = "topic_count"
            case postCount = "post_count"
            case position
            case description
            case descriptionText = "description_text"
            case descriptionExcerpt = "description_excerpt"
            case topicUrl = "topic_url"
            case readRestricted = "read_restricted"
            case permission
            case notificationLevel = "notification_level"
            case topicTemplate = "topic_template"
            case hasChildren = "has_children"
            case sortOrder = "sort_order"
            case sortAscending = "sort_ascending"
            case showSubcategoryList = "show_subcategory_list"
            case numFeaturedTopics = "num_featured_topics"
            case defaultView = "default_view"
            case subcategoryListStyle = "subcategory_list_style"
            case defaultTopPeriod = "default_top_period"
            case defaultListFilter = "default_list_filter"
            case minimumRequiredTags = "minimum_required_tags"
            case navigateToFirstPostAfterRead = "navigate_to_first_post_after_read"
            case topicsDay = "topics_day"
            case topicsWeek = "topics_week"
            case topicsMonth = "topics_month"
            case topicsYear = "topics_year"
            case topicsAllTime = "topics_all_time"
            case subcategoryIds = "subcategory_ids"
            case uploadedLogo = "uploaded_logo"
            case uploadedBackground = "uploaded_background"
        }
    }
}

enum Category: String, CustomStringConvertible, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case activity
    case meetup
    case study
    case career
    case development
    case relationship
    case recreation
    case lifeshare
    case showup
    case feedback
    
    var description: String {
        get {
            switch self {
            case.activity: return "论坛活动"
            case.meetup: return "她乡同城"
            case.study: return "海外学习"
            case.career: return "职业生涯"
            case.development: return "自我发展"
            case.relationship: return "人际关系"
            case.recreation: return "书影音游"
            case.lifeshare: return "生活分享"
            case.showup: return "打卡专区"
            case.feedback: return "站点反馈"
            }
        }
    }
}
