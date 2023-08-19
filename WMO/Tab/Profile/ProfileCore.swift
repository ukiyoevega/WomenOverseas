//
//  ProfileCore.swift
//  WMO
//
//  Created by weijia on 2022/5/30.
//

import ComposableArchitecture
import UIKit

// MARK: - Header

struct ProfileEnvironment {
  let mainQueue: AnySchedulerOf<DispatchQueue> = .main
}

struct ProfileHeaderState: Equatable {
  var userResponse: UserResponse = .empty
  var toastMessage: String? = nil
  var isLoading = false
  var showInfo = false
}

enum ProfileHeaderAction {
  case refresh
  case dismissToast
  case userResponse(Result<UserResponse, Failure>)
  case togglshowInfo
  
  case update(name: String, value: String)
  case updateResponse(Result<UserResponse, Failure>)
}

let profileHeaderReducer = AnyReducer<ProfileHeaderState, ProfileHeaderAction, ProfileEnvironment> { state, action, environment in
  let username = UserDefaults.standard.string(forKey: "com.womenoverseas.username")?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
  switch action {
  case .togglshowInfo:
    state.showInfo = !state.showInfo
    
  case .update(let name, let value):
    state.isLoading = true
    return APIService.shared.updateUser(.update(username: username, name: name, value: value))
      .receive(on: environment.mainQueue)
      .catchToEffect(ProfileHeaderAction.updateResponse)
    
  case .updateResponse(.success(let userResponse)):
    state.isLoading = false
    state.userResponse.user = userResponse.user
    state.toastMessage = "更新成功"
    
  case .dismissToast:
    state.toastMessage = nil
    
  case .updateResponse(.failure(let failure)):
    state.isLoading = false
    state.toastMessage = "\(failure.error)"
    
  case .refresh:
    return APIService.shared.getUser(.getUser(name: username))
      .receive(on: environment.mainQueue)
      .catchToEffect(ProfileHeaderAction.userResponse)
  case .userResponse(.success(let userResponse)):
    state.userResponse = userResponse
  case .userResponse(.failure(let failure)):
    state.toastMessage = "\(failure.error)"
  }
  return .none // Effect<ProfileAction, Never>
}

// MARK: - Summary

struct ProfileSummaryState: Equatable {
  var userResponse: UserSummaryResponse = .empty
  var toastMessage: String? = nil
}

enum ProfileSummaryAction {
  case refresh
  case dismissToast
  case userResponse(Result<UserSummaryResponse, Failure>)
}

let profileSummaryReducer = AnyReducer<ProfileSummaryState, ProfileSummaryAction, ProfileEnvironment> { state, action, environment in
  switch action {
  case .refresh:
    let username = UserDefaults.standard.string(forKey: "com.womenoverseas.username")?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
    return APIService.shared.getUserSummary(.summary(username: username))
      .receive(on: environment.mainQueue)
      .catchToEffect(ProfileSummaryAction.userResponse)
  case .userResponse(.success(let userResponse)):
    state.userResponse = userResponse
  case .userResponse(.failure(let failure)):
    state.toastMessage = "\(failure.error)"
  case .dismissToast:
    state.toastMessage = nil
  }
  return .none // Effect<ProfileAction, Never>
}

// MARK: - Profile

struct ProfileState: Equatable {
  var isNativeMode: Bool = true
  var profileSummaryState = ProfileSummaryState()
  var profileHeaderState = ProfileHeaderState()
  var notificationState = NotificationState()
}

enum ProfileAction {
  case summary(ProfileSummaryAction)
  case header(ProfileHeaderAction)
  case notification(NotificationAction)
  case toggleNativeMode(Bool)
  case logout
  case deleteAccount
  case logoutResponse(Result<[String: String], Failure>)
}

// TODO: reducer should not be global instance
let profileReducer = AnyReducer<ProfileState, ProfileAction, Void>.combine(
  profileSummaryReducer.pullback(
    state: \ProfileState.profileSummaryState,
    action: /ProfileAction.summary,
    environment: { ProfileEnvironment() }
  ),
  profileHeaderReducer.pullback(
    state: \ProfileState.profileHeaderState,
    action: /ProfileAction.header,
    environment: { ProfileEnvironment() }
  ),
  notificationReducer.pullback(
    state: \ProfileState.notificationState,
    action: /ProfileAction.notification,
    environment: { ProfileEnvironment() }
  ),
  AnyReducer { state, action, _ in
    switch action {
    case .summary, .header, .notification:
      break
    case .toggleNativeMode(let isNative):
      break // TODO: dark mode
    case .deleteAccount:
      let username = UserDefaults.standard.string(forKey: "com.womenoverseas.username")
      UserDefaults.standard.set(username, forKey: "com.womenoverseas.deletedAccount")
      return APIService.generateDataTaskPublisher(endpoint: EndPoint.User.logout)
        .catchToEffect(ProfileAction.logoutResponse)
    case .logout:
      return APIService.generateDataTaskPublisher(endpoint: EndPoint.User.logout)
        .catchToEffect(ProfileAction.logoutResponse)
    case .logoutResponse(.success(let data)):
      DispatchQueue.main.async {
        APIService.shared.apiKey = ""
        APIService.removeCache()
        Router.showMain()
      }
    case .logoutResponse(.failure(let failure)):
      print("logout failed: \(failure.error)")
    }
    return .none
  }
)
