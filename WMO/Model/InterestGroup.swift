//
//  InterestGroup.swift
//  WMO
//
//  Created by weijia on 2022/6/19.
//

import Foundation

struct InterestGroup: Decodable {
  let id: Int
  let automatic: Bool
  let name: String
  let userCount: Int
  let mentionableLevel: Int
  let messageableLevel: Int
  let visibilityLevel: Int
  let primaryGroup: Bool
  let title: String
  let grantTrustLevel: String?
  let hasMessages: Bool?
  let flairUrl: String?
  let flairBgColor: String?
  let flairColor: String?
  let bioCooked: Bool?
  let bioExcerpt: Bool? // TODO:
  let publicAdmission: Bool
  let publicExit: Bool
  let allowMembershipRequests: Bool
  let fullname: String
  let defaultNotificationLevel: Int
  let membershipRequestTemplate: String
  let membersVisibilityLevel: Int
  let canSeeMembers: Bool
  let publishReadState: Bool
  
  enum CodingKeys: String, CodingKey {
    case id
    case automatic
    case name
    case userCount = "user_count"
    case mentionableLevel = "mentionable_level"
    case messageableLevel = "messageable_level"
    case visibilityLevel = "visibility_level"
    case primaryGroup = "primary_group"
    case title
    case grantTrustLevel = "grant_trust_level"
    case hasMessages = "has_messages"
    case flairUrl = "flair_url"
    case flairBgColor = "flair_bg_color"
    case flairColor = "flair_color"
    case bioCooked = "bio_cooked"
    case bioExcerpt = "bio_excerpt"
    case publicAdmission = "public_admission"
    case publicExit = "public_exit"
    case allowMembershipRequests = "allow_membership_requests"
    case fullname = "full_name"
    case defaultNotificationLevel = "default_notification_level"
    case membershipRequestTemplate = "membership_request_template"
    case membersVisibilityLevel = "members_visibility_level"
    case canSeeMembers = "can_see_members"
    case publishReadState = "publish_read_state"
  }
}
