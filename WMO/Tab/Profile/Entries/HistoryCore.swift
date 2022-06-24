//
//  HistoryCore.swift
//  WMO
//
//  Created by weijia on 2022/6/23.
//

import ComposableArchitecture

struct HistoryState: Equatable {
    var toastMessage: String?
    var topicResponse: [TopicListResponse] = []
    var currentPage: Int = 0
    var reachEnd = false
}

enum HistoryAction {
    case loadHistory(onStart: Bool)
    case historyTopicResponse(Result<TopicListResponse, Failure>)
    case dismissToast
}

let historyReducer = Reducer<HistoryState, HistoryAction, TopicEnvironment> { state, action, environment in
    switch action {
    case .loadHistory(let onStart):
        if onStart {
            state.topicResponse = []
            state.currentPage = 0
        }
        return APIService.shared.getTopics(.history(page: state.currentPage))
            .receive(on: environment.mainQueue)
            .catchToEffect(HistoryAction.historyTopicResponse)

    case .historyTopicResponse(.success(let response)):
        state.currentPage += 1
        state.topicResponse.append(response)
        if response.topicList?.topics?.isEmpty == true {
            state.reachEnd = true
        }

    case .historyTopicResponse(.failure(let failure)):
        state.toastMessage = "\(failure.error)"

    case .dismissToast:
        state.toastMessage = nil
    }
    return .none
}
