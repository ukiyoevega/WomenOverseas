//
//  TopicListAction.swift
//  WMO
//
//  Created by weijia on 2022/5/28.
//

import ComposableArchitecture
import Combine
import Foundation

// MARK: - Topic

struct TopicState: Equatable {
  var topicResponse: [TopicListResponse] = []
  var categories: [CategoryList.Category] = []
  var subCategories: [Int: [CategoryList.Category]] = [:]
  var currentPage: Int = 0
  var currentCategory: CategoryList.Category = .all
  var currentOrder: EndPoint.Topics.Order?
  var toastMessage: String?
  var reachEnd = false
  var showSortSheet = false
  
  mutating func resetResponse() {
    self.currentPage = 0
    self.topicResponse = []
    self.reachEnd = false
  }
}

enum TopicAction {
  case tapCategory(CategoryList.Category)
  case tapOrder(EndPoint.Topics.Order)
  case loadCategories
  case loadTopics
  case categoriesResponse(Result<[CategoryList.Category], Failure>)
  case topicsResponse(Result<TopicListResponse, Failure>)
  case topicsCategriesResponse(Result<([CategoryList.Category], TopicListResponse), Failure>)
  case dismissToast
  case toggleSortSheet
}

struct TopicEnvironment {
  let mainQueue: AnySchedulerOf<DispatchQueue> = .main
}

let topicReducer = AnyReducer<TopicState, TopicAction, TopicEnvironment> { state, action, environment in
  switch action {
  case .toggleSortSheet:
    state.showSortSheet = !state.showSortSheet
    
  case .dismissToast:
    state.toastMessage = nil
    
  case .tapCategory(let cat):
    state.resetResponse()
    state.currentOrder = nil
    state.currentCategory = cat
    let endpoint: EndPoint.Topics
    if cat.isAllCategories {
      endpoint = .latest(by: .default, ascending: false, page: state.currentPage)
    } else {
      endpoint = .category(slug: cat.slug, id: cat.id)
    }
    let topicEffect = APIService.shared.getTopics(endpoint)
    let subCatEffect = APIService.shared.getCategories(.sublist(parentId: cat.id))
    if cat.id != -1, state.subCategories[cat.id] == nil {
      return Publishers
        .Zip(subCatEffect.upstream, topicEffect.upstream)
        .receive(on: environment.mainQueue)
        .catchToEffect(TopicAction.topicsCategriesResponse)
    } else {
      return topicEffect
        .receive(on: environment.mainQueue)
        .catchToEffect(TopicAction.topicsResponse)
    }
    
  case .tapOrder(let order):
    state.resetResponse()
    state.currentOrder = order
    if state.currentCategory.isAllCategories {
      return APIService.shared.getTopics(.top(by: order, period: .all))
        .receive(on: environment.mainQueue)
        .catchToEffect(TopicAction.topicsResponse)
    } else {
      return APIService.shared.getTopics(.category(slug: state.currentCategory.slug, id: state.currentCategory.id, order: order))
        .receive(on: environment.mainQueue)
        .catchToEffect(TopicAction.topicsResponse)
    }
    
  case .loadCategories:
    state.categories.removeAll()
    return APIService.shared.getCategories(.list(includeSubcategories: false))
      .receive(on: environment.mainQueue)
      .catchToEffect(TopicAction.categoriesResponse)
    
  case .loadTopics:
    let endpoint: EndPoint.Topics
    switch (state.currentOrder, state.currentCategory.isAllCategories) {
    case (let optionalOrder, false):
      endpoint = .category(slug: state.currentCategory.slug, id: state.currentCategory.id, page: state.currentPage, order: optionalOrder)
    case (nil, true):
      endpoint = .latest(by: .default, ascending: false, page: state.currentPage)
    case (.some(let order), true):
      endpoint = .top(by: order, period: .all, page: state.currentPage)
    }
    return APIService.shared.getTopics(endpoint)
      .receive(on: environment.mainQueue)
      .catchToEffect(TopicAction.topicsResponse)
    
  case .topicsResponse(.success(let res)):
    state.currentPage += 1
    state.topicResponse.append(res)
    if res.topicList?.topics?.isEmpty == true {
      state.reachEnd = true
    }
    
  case .topicsResponse(.failure(let failure)):
    state.toastMessage = "\(failure.error)"
    
  case .categoriesResponse(.success(let categories)):
    state.categories = [CategoryList.Category.all] + categories
    state.resetResponse()
    // trigger `getTopics` to update category label inside topic row
    return APIService.shared.getTopics(.latest(by: .default, ascending: false, page: 0))
      .receive(on: environment.mainQueue)
      .catchToEffect(TopicAction.topicsResponse)
    
  case .categoriesResponse(.failure(let failure)):
    state.toastMessage = "\(failure.error)"
    
  case .topicsCategriesResponse(.success(let (subCategories, topicResponse))):
    state.subCategories[state.currentCategory.id] = subCategories
    state.topicResponse.append(topicResponse)
    
  case .topicsCategriesResponse(.failure(let failure)):
    state.toastMessage = "\(failure.error)"
  }
  return .none // Effect<TopicAction, Never>
}
