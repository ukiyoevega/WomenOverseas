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
    var likeContent: [String: [StringWithAttributes]] = [:]
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
            state.likeContent = [:]
            state.currentOffset = 0
        }
        let username = UserDefaults.standard.string(forKey: "com.womenoverseas.username")
        return APIService.shared.getLiked(.liked(username: username, offset: state.currentOffset))
            .receive(on: environment.mainQueue)
            .catchToEffect(LikeAction.likedResponse)

    case .likedResponse(.success(let response)):
        state.currentOffset += (response.userActions?.count ?? 0)
        state.likesElement.append(contentsOf: response.userActions ?? [])
        state.likesElement.forEach { userAction in
            if let data = userAction.excerpt.data(using: .unicode),
               let attributedString = try? NSAttributedString(data: data,
                                                              options: [.documentType: NSAttributedString.DocumentType.html],
                                                              documentAttributes: nil) {
                state.likeContent[userAction.id] = attributedString.stringsWithAttributes
            }
        }
        if response.userActions?.isEmpty == true || response.userActions == nil {
            state.reachEnd = true
        }

    case .likedResponse(.failure(let failure)):
        state.toastMessage = "\(failure.error)"

    case .dismissToast:
        state.toastMessage = nil
    }
    return .none
}
