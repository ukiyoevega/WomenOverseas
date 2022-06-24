//
//  LikeCore.swift
//  WMO
//
//  Created by weijia on 2022/6/23.
//

import ComposableArchitecture

struct LikeState: Equatable {
    var toastMessage: String?
    var likesElement: [UserAction] = []
    var currentOffset: Int = 0
    var reachEnd = false
}

enum LikeAction {
    case loadLike(onStart: Bool)
    case likedResponse(Result<LikesResponse, Failure>)
    case dismissToast
}

let likeReducer = Reducer<LikeState, LikeAction, TopicEnvironment> { state, action, environment in
    switch action {
    case .loadLike(let onStart):
        if onStart {
            state.likesElement = []
            state.currentOffset = 0
        }
        let username = UserDefaults.standard.string(forKey: "com.womenoverseas.username")
        return APIService.shared.getLiked(.liked(username: username, offset: state.currentOffset))
            .receive(on: environment.mainQueue)
            .catchToEffect(LikeAction.likedResponse)

    case .likedResponse(.success(let response)):
        state.currentOffset += (response.userActions.count)
        state.likesElement.append(contentsOf: response.userActions)
        if response.userActions.isEmpty {
            state.reachEnd = true
        }

    case .likedResponse(.failure(let failure)):
        state.toastMessage = "\(failure.error)"

    case .dismissToast:
        state.toastMessage = nil
    }
    return .none
}
