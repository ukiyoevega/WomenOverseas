//
//  ProfileCore.swift
//  WMO
//
//  Created by weijia on 2022/5/30.
//

import ComposableArchitecture

// MARK: - Header

struct ProfileEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue> = .main
}

struct ProfileHeaderState: Equatable {
    var userResponse: UserResponse = .empty
}

enum ProfileHeaderAction {
    case refresh
    case userResponse(Result<UserResponse, Failure>)
}

let profileHeaderReducer = Reducer<ProfileHeaderState, ProfileHeaderAction, ProfileEnvironment> { state, action, environment in
    switch action {
    case .refresh:
        return APIService.shared.getUser(.getUser(name: "weijia"))
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileHeaderAction.userResponse)
    case .userResponse(.success(let userResponse)):
        state.userResponse = userResponse
    case .userResponse(.failure):
        break // TODO: error handling
    }
    return .none // Effect<ProfileAction, Never>
}

// MARK: - Summary

struct ProfileSummaryState: Equatable {
    var userResponse: UserSummaryResponse = .empty
}

enum ProfileSummaryAction {
    case refresh
    case userResponse(Result<UserSummaryResponse, Failure>)
}

let profileSummaryReducer = Reducer<ProfileSummaryState, ProfileSummaryAction, ProfileEnvironment> { state, action, environment in
    switch action {
    case .refresh:
        return APIService.shared.getUserSummary(.summary(username: "weijia"))
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileSummaryAction.userResponse)
    case .userResponse(.success(let userResponse)):
        state.userResponse = userResponse
    case .userResponse(.failure):
        break // TODO: error handling
    }
    return .none // Effect<ProfileAction, Never>
}


// MARK: - Profile

struct ProfileState: Equatable {
    var profileSummaryState = ProfileSummaryState()
    var profileHeaderState = ProfileHeaderState()
}

enum ProfileAction {
    case summary(ProfileSummaryAction)
    case header(ProfileHeaderAction)
}

// TODO: reducer should not be global instance
let profileReducer = Reducer<ProfileState, ProfileAction, Void>.combine(
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
    Reducer { state, action, _ in
        switch action {
        case .summary, .header:
            return .none
        }
    }
)
