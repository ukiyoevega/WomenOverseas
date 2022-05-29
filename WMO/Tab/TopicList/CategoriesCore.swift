//
//  CategoriesCore.swift
//  WMO
//
//  Created by weijia on 2022/5/28.
//

import ComposableArchitecture

// TODO: remove
struct CategoryState: Equatable {
    var categories: [CategoryList.Category] = []
}

enum CategoryAction {
    case refresh
    case categoriesResponse(Result<[CategoryList.Category], Failure>)
}

struct CategoryEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue> = .main
}

let categoryReducer = Reducer<CategoryState, CategoryAction, CategoryEnvironment> { state, action, environment in
    switch action {
    case .refresh:
        state.categories.removeAll()
        return APIService.shared.getCategories()
            .receive(on: environment.mainQueue)
            .catchToEffect(CategoryAction.categoriesResponse)
    case .categoriesResponse(.success(let categories)):
        state.categories = categories
    case .categoriesResponse(.failure):
        break
    }
    return .none // Effect<CategoryAction, Never>
}
