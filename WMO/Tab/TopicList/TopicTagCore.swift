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
  var currentTag: String?
  var reachEnd = false
  var showSortSheet = false
}

enum TagAction {
  case loadTags
  case tagsResponse(Result<[Tag], Failure>)
  case tapTagOrder(TagOrder)
  
  case loadTopics(onStart: Bool, tag: String)
  case tagTopicResponse(Result<TopicListResponse, Failure>)
  case dismissToast
  case toggleSortSheet
}

let tagReducer = AnyReducer<TagState, TagAction, TopicEnvironment> { state, action, environment in
  switch action {
  case .toggleSortSheet:
    state.showSortSheet = !state.showSortSheet
    
  case .loadTopics(let onStart, let tag):
    state.currentTag = tag
    if onStart {
      state.topicResponse = []
      state.currentPage = 0
    }
    return APIService.shared.getTopics(.tag(by: tag, page: state.currentPage))
      .receive(on: environment.mainQueue)
      .catchToEffect(TagAction.tagTopicResponse)
    
  case .tagTopicResponse(.success(let response)):
    state.currentPage += 1
    state.topicResponse.append(response)
    if response.topicList?.topics?.isEmpty == true {
      state.reachEnd = true
    }
    
  case .tagTopicResponse(.failure(let failure)):
    state.toastMessage = "\(failure.error)"
    
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
