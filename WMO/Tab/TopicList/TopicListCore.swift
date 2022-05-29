//
//  TopicListAction.swift
//  WMO
//
//  Created by weijia on 2022/5/28.
//

import ComposableArchitecture

struct TopicState: Equatable {
    var topicResponse: [TopicListResponse] = []
    var categories: [CategoryList.Category] = []
}

enum TopicAction {
    case loadCategories
    case loadTopics
    case loadMoreTopics
    case categoriesResponse(Result<[CategoryList.Category], Failure>)
    case topicsResponse(Result<TopicListResponse, Failure>)
}

struct TopicEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue> = .main
}

let topicReducer = Reducer<TopicState, TopicAction, TopicEnvironment> { state, action, environment in
    switch action {
    case .loadTopics:
        break
    case .loadCategories:
        state.categories.removeAll()
        return APIService.shared.getCategories("")
            .receive(on: environment.mainQueue)
            .catchToEffect(TopicAction.categoriesResponse)
    case .loadMoreTopics:
        break // TODO: load more

    case .topicsResponse(.success(let topicResponse)):
        state.topicResponse = [topicResponse]
    case .topicsResponse(.failure):
        break
    case .categoriesResponse(.success(let categories)):
        state.categories = categories
        // trigger `getTopics` to update category label inside topic row
        return APIService.shared.getTopics("")
            .receive(on: environment.mainQueue)
            .catchToEffect(TopicAction.topicsResponse)
    case .categoriesResponse(.failure):
        break
    }
    return .none // Effect<TopicAction, Never>
}
