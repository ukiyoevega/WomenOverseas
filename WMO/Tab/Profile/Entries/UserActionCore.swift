//
//  LikeCore.swift
//  WMO
//
//  Created by weijia on 2022/6/23.
//

import ComposableArchitecture
import Foundation

struct UserActionState: Equatable {
  enum `Type`: Int {
    case liked = 1
    case replied = 5
    
    var title: String {
      switch self {
      case .liked: return "我点赞的"
      case .replied: return "我回复的"
      }
    }
  }
  let type: `Type`
  var toastMessage: String?
  var userActions: [UserAction] = []
  var userActionAttributes: [String: [StringWithAttributes]] = [:]
  var currentOffset: Int = 0
  var reachEnd = false
}

enum UserActionAction {
  case loadUserAction(onStart: Bool)
  case userActionResponse(Result<UserActionResponse, Failure>)
  case dismissToast
}

let userActionReducer = AnyReducer<UserActionState, UserActionAction, TopicEnvironment> { state, action, environment in
  switch action {
  case .loadUserAction(let onStart):
    if onStart {
      state.userActions = []
      state.userActionAttributes = [:]
      state.currentOffset = 0
    }
    let username = UserDefaults.standard.string(forKey: "com.womenoverseas.username")
    return APIService.shared.getUserActions(.userAction(username: username, offset: state.currentOffset, type: state.type))
      .receive(on: environment.mainQueue)
      .catchToEffect(UserActionAction.userActionResponse)
    
  case .userActionResponse(.success(let response)):
    state.currentOffset += (response.userActions?.count ?? 0)
    state.userActions.append(contentsOf: response.userActions ?? [])
    var userActionAttributes: [String: [StringWithAttributes]] = [:]
    state.userActions.forEach { userAction in
      if let data = userAction.excerpt.data(using: .unicode),
         let attributedString = try? NSAttributedString(data: data,
                                                        options: [.documentType: NSAttributedString.DocumentType.html],
                                                        documentAttributes: nil) {
        userActionAttributes[userAction.id] = attributedString.stringsWithAttributes
      }
    }
    state.userActionAttributes = userActionAttributes
    if response.userActions?.isEmpty == true || response.userActions == nil {
      state.reachEnd = true
    }
    
  case .userActionResponse(.failure(let failure)):
    state.toastMessage = "\(failure.error)"
    
  case .dismissToast:
    state.toastMessage = nil
  }
  return .none
}
