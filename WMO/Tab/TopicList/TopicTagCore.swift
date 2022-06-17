//
//  TopicTagCore.swift
//  WMO
//
//  Created by weijia on 2022/6/17.
//

import ComposableArchitecture
import Combine

struct TagState: Equatable {
    var tags: [Tag] = []
    var toastMessage: String?
    var topicResponse: [TopicListResponse] = []
    var currentPage: Int = 0
    var reachEnd = false
}

enum TagAction {
    case loadTags
    case tagsResponse(Result<[Tag], Failure>)
    case tapTagOrder(TagOrder)

    case loadMoreTopics
    case tagTopicResponse(Result<TopicListResponse, Failure>)
    case dismissToast
}

let tagReducer = Reducer<TagState, TagAction, TopicEnvironment> { state, action, environment in
    switch action {
    case .loadMoreTopics:
        break

    case .tagTopicResponse(.success(let response)):
        break

    case .tagTopicResponse(.failure(let failure)):
        break

    case .dismissToast:
        state.toastMessage = nil

    case .loadTags:
        return APIService.shared.getTags(.list)
            .receive(on: environment.mainQueue)
            .map(\.tags)
            .catchToEffect(TagAction.tagsResponse)

    case .tagsResponse(.success(let tags)):
        state.tags = tags

    case .tagsResponse(.failure(let failure)):
        state.toastMessage = "\(failure.error)"

    case .tapTagOrder(let order):
        let sortedTags: [Tag]
        switch order {
        case .alphabet:
            sortedTags = state.tags.sorted(by: { $0.name < $1.name })
        case .counts:
            sortedTags = state.tags.sorted(by: { $0.count > $1.count })
        }
        state.tags = sortedTags
    }
    return .none
}
