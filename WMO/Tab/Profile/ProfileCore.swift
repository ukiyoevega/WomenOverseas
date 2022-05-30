//
//  ProfileCore.swift
//  WMO
//
//  Created by weijia on 2022/5/30.
//

import ComposableArchitecture

// MARK: - Summary

struct ProfileSummaryState: Equatable {
    var userResponse: UserResponse = .empty
}

enum ProfileSummaryAction {
    case refresh
    case userResponse(Result<UserResponse, Failure>)
}

struct ProfileSummaryEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue> = .main
}

let profileSummaryReducer = Reducer<ProfileSummaryState, ProfileSummaryAction, ProfileSummaryEnvironment> { state, action, environment in
    switch action {
    case .refresh:
        return APIService.shared.getUser(.summary(username: "weijia"))
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
}

enum ProfileAction {
    case summary(ProfileSummaryAction)
}

// TODO: reducer should not be global instance
let profileReducer = Reducer<ProfileState, ProfileAction, Void>.combine(
    profileSummaryReducer.pullback(
      state: \ProfileState.profileSummaryState,
      action: /ProfileAction.summary,
      environment: { ProfileSummaryEnvironment() }
    ),
    Reducer { state, action, _ in
        switch action {
        case .summary:
            return .none
        }
    }
)
