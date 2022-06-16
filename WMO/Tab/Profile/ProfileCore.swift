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
    var userAvatar: String? = nil
    var successMessage: String = ""
    var toastMessage: String? = nil
}

enum ProfileHeaderAction {
    case refresh
    case dismissToast
    case userResponse(Result<UserResponse, Failure>)

    case update(name: String, value: String)
    case updateResponse(Result<UserResponse, Failure>)
}

let profileHeaderReducer = Reducer<ProfileHeaderState, ProfileHeaderAction, ProfileEnvironment> { state, action, environment in
    let username = UserDefaults.standard.string(forKey: "com.womenoverseas.username")?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
    switch action {
    case .update(let name, let value):
        state.successMessage = ""
        return APIService.shared.updateUser(.update(username: username, name: name, value: value))
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileHeaderAction.updateResponse)
    case .updateResponse(.success(let userResponse)):
        state.userResponse.user = userResponse.user
        state.successMessage = "更新成功"
        break
    case .dismissToast:
        state.successMessage = ""

    case .updateResponse(.failure):
        break // TODO: errer handling

    case .refresh:
        return APIService.shared.getUser(.getUser(name: username))
            .receive(on: environment.mainQueue)
            .catchToEffect(ProfileHeaderAction.userResponse)
    case .userResponse(.success(let userResponse)):
        state.userResponse = userResponse
        if !userResponse.user.avatarTemplate.isEmpty {
            state.userAvatar = String("https://womenoverseas.com" + userResponse.user.avatarTemplate)
            .replacingOccurrences(of: "{size}", with: "400")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }
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

let profileSummaryReducer = Reducer<ProfileSummaryState, ProfileSummaryAction, ProfileEnvironment> { state, action, environment in
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
}

enum ProfileAction {
    case summary(ProfileSummaryAction)
    case header(ProfileHeaderAction)
    case toggleNativeMode(Bool)
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
    ).debug(),
    Reducer { state, action, _ in
        switch action {
        case .summary, .header:
            return .none
        case .toggleNativeMode(let isNative):
            return .none // TODO: 
        }
    }
)
