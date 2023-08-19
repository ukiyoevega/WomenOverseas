//
//  HistoryCore.swift
//  WMO
//
//  Created by weijia on 2022/6/23.
//

import ComposableArchitecture
import SwiftUI

struct PlainTopicListState: Equatable {
  enum `Type` {
    case created
    case viewed
    
    var title: String {
      switch self {
      case .created: return "我的话题"
      case .viewed: return "浏览历史"
      }
    }
  }
  let type: `Type`
  var toastMessage: String?
  var topicResponse: [TopicListResponse] = []
  var currentPage: Int = 0
  var reachEnd = false
}

enum PlainTopicListAction {
  case loadTopics(onStart: Bool)
  case topicResponse(Result<TopicListResponse, Failure>)
  case dismissToast
}

let historyReducer = AnyReducer<PlainTopicListState, PlainTopicListAction, TopicEnvironment> { state, action, environment in
  switch action {
  case .loadTopics(let onStart):
    if onStart {
      state.topicResponse = []
      state.currentPage = 0
    }
    let endpoint: EndPoint.Topics
    switch state.type {
    case .created:
      let username = UserDefaults.standard.string(forKey: "com.womenoverseas.username")
      endpoint = .created(by: username ?? "", page: state.currentPage)
    case .viewed:
      endpoint = .history(page: state.currentPage)
    }
    return APIService.shared.getTopics(endpoint)
      .receive(on: environment.mainQueue)
      .catchToEffect(PlainTopicListAction.topicResponse)
    
  case .topicResponse(.success(let response)):
    state.currentPage += 1
    state.topicResponse.append(response)
    switch response.topicList?.topics?.isEmpty {
    case false:
      break
    default:
      state.reachEnd = true
    }
    
  case .topicResponse(.failure(let failure)):
    state.toastMessage = "\(failure.error)"
    
  case .dismissToast:
    state.toastMessage = nil
  }
  return .none
}
