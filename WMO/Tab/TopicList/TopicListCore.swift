//
//  TopicListAction.swift
//  WMO
//
//  Created by weijia on 2022/5/28.
//

import ComposableArchitecture

struct TopicState: Equatable {
    var topicResponse: [TopicListResponse] = []
}

enum TopicAction {
    case refresh
    case loadMoreTopics
    case topicsResponse(Result<TopicListResponse, Failure>)
}

struct TopicEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue> = .main
}

let topicReducer = Reducer<TopicState, TopicAction, TopicEnvironment> { state, action, environment in
    switch action {
    case .refresh:
        state.topicResponse.removeAll()
        return APIService.shared.getTopics("")
            .receive(on: environment.mainQueue)
            .catchToEffect(TopicAction.topicsResponse)
    case .loadMoreTopics:
        break
    case .topicsResponse(.success(let topicResponse)):
        state.topicResponse = [topicResponse]
    case .topicsResponse(.failure):
        break
    }
    return .none // Effect<TopicAction, Never>
}
