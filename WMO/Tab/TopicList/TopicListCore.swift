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
    var currentPage: Int = 0
    var currentCategory: CategoryList.Category?
    var currentOrder: EndPoint.Topics.Order?
}

enum TopicAction {
    case tapCategory(CategoryList.Category)
    case tapOrder(EndPoint.Topics.Order)
    case tapPeriod(EndPoint.Topics.Period)
    case loadCategories
    case loadTopics
    case categoriesResponse(Result<[CategoryList.Category], Failure>)
    case topicsResponse(Result<TopicListResponse, Failure>)
}

struct TopicEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue> = .main
}

let topicReducer = Reducer<TopicState, TopicAction, TopicEnvironment> { state, action, environment in
    switch action {
    case .tapPeriod(let period):
        break
        
    case .tapCategory(let cat):
        state.topicResponse = []
        state.currentPage = 0
        state.currentCategory = cat
        state.currentOrder = nil // TODO: remove mutual exclusive
        return APIService.shared.getTopics(.category(slug: cat.slug, id: cat.id))
            .receive(on: environment.mainQueue)
            .catchToEffect(TopicAction.topicsResponse)
        
    case .tapOrder(let order):
        state.topicResponse = []
        state.currentPage = 0
        state.currentOrder = order
        state.currentCategory = nil  // TODO: remove mutual exclusive
        return APIService.shared.getTopics(.top(by: order, period: .all))
            .receive(on: environment.mainQueue)
            .catchToEffect(TopicAction.topicsResponse)

    case .loadCategories:
        state.categories.removeAll()
        return APIService.shared.getCategories(.list)
            .receive(on: environment.mainQueue)
            .catchToEffect(TopicAction.categoriesResponse)
        
    case .loadTopics:
        let endpoint: EndPoint.Topics
        if let cat = state.currentCategory {
            endpoint = .category(slug: cat.slug, id: cat.id, page: state.currentPage)
        } else if let order = state.currentOrder {  // TODO: remove mutual exclusive
            endpoint = .top(by: order, period: .all, page: state.currentPage)
        } else {
            endpoint = .latest(by: .default, ascending: false, page: state.currentPage)
        }
        return APIService.shared.getTopics(endpoint)
            .receive(on: environment.mainQueue)
            .catchToEffect(TopicAction.topicsResponse)
        
    case .topicsResponse(.success(let res)):
        state.currentPage += 1
        state.topicResponse.append(res)
        
    case .topicsResponse(.failure):
        break
        
    case .categoriesResponse(.success(let categories)):
        state.categories = categories
        state.topicResponse = []
        state.currentPage = 0
        // trigger `getTopics` to update category label inside topic row
        return APIService.shared.getTopics(.latest(by: .default, ascending: false, page: 0))
            .receive(on: environment.mainQueue)
            .catchToEffect(TopicAction.topicsResponse)
        
    case .categoriesResponse(.failure):
        break
    }
    return .none // Effect<TopicAction, Never>
}
