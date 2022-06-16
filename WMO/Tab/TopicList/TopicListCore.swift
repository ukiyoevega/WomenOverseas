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
    var currentCategory: CategoryList.Category = .all
    var currentOrder: EndPoint.Topics.Order?
    var toastMessage: String?
    var reachEnd = false

    mutating func reset() {
        self.currentPage = 0
        self.topicResponse = []
        self.reachEnd = false
    }
}

enum TopicAction {
    case tapCategory(CategoryList.Category)
    case tapOrder(EndPoint.Topics.Order)
    case tapPeriod(EndPoint.Topics.Period)
    case loadCategories
    case loadTopics
    case categoriesResponse(Result<[CategoryList.Category], Failure>)
    case topicsResponse(Result<TopicListResponse, Failure>)
    case dismissToast
}

struct TopicEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue> = .main
}

let topicReducer = Reducer<TopicState, TopicAction, TopicEnvironment> { state, action, environment in
    switch action {
    case .tapPeriod(let period):
        break

    case .dismissToast:
        state.toastMessage = nil
        break

    case .tapCategory(let cat):
        state.reset()
        state.currentCategory = cat
        state.currentOrder = nil // TODO: remove mutual exclusive
        let endpoint: EndPoint.Topics
        if cat.id != -1 {
            endpoint = .category(slug: cat.slug, id: cat.id)
        } else {
            endpoint = .latest(by: .default, ascending: false, page: state.currentPage)
        }
        return APIService.shared.getTopics(endpoint)
            .receive(on: environment.mainQueue)
            .catchToEffect(TopicAction.topicsResponse)
    case .tapOrder(let order):
        state.reset()
        state.currentOrder = order
        state.currentCategory = .all  // TODO: remove mutual exclusive
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
        if state.currentCategory.id != -1 {
            endpoint = .category(slug: state.currentCategory.slug, id: state.currentCategory.id, page: state.currentPage)
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
        if res.topicList?.topics?.isEmpty == true {
            state.reachEnd = true
        }
    case .topicsResponse(.failure(let failure)):
        state.toastMessage = "\(failure.error)"

    case .categoriesResponse(.success(let categories)):
        state.categories = [CategoryList.Category.all] + categories
        state.reset()
        // trigger `getTopics` to update category label inside topic row
        return APIService.shared.getTopics(.latest(by: .default, ascending: false, page: 0))
            .receive(on: environment.mainQueue)
            .catchToEffect(TopicAction.topicsResponse)
        
    case .categoriesResponse(.failure(let failure)):
        state.toastMessage = "\(failure.error)"
    }
    return .none // Effect<TopicAction, Never>
}
