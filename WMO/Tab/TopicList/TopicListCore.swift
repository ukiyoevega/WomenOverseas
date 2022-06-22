//
//  TopicListAction.swift
//  WMO
//
//  Created by weijia on 2022/5/28.
//

import ComposableArchitecture
import Combine

// MARK: - Bookmark

struct BookmarkState: Equatable {
    var bookmarks: [Bookmark] = []
    var bookmarkContent: [[StringWithAttributes]] = []
    var toastMessage: String?
    var categories: [CategoryList.Category] = []
    var currentPage: Int = 0
}

enum BookmarkAction {
    case loadList
    case dismissToast
    case bookmarkResponse(Result<BookmarkResponse, Failure>)

    case loadCategories
    case categoriesResponse(Result<[CategoryList.Category], Failure>)
}

let bookmarkReducer = Reducer<BookmarkState, BookmarkAction, ProfileEnvironment> { state, action, environment in
    switch action {
    case .dismissToast:
        state.toastMessage = nil

    case .bookmarkResponse(.success(let resp)):
        state.currentPage += 1
        state.bookmarks.append(contentsOf: resp.bookmarkList.bookmarks)
        state.bookmarkContent.append(contentsOf: resp.bookmarkList.bookmarks.map({ bookmark in
            if let data = bookmark.excerpt.data(using: .unicode),
               let attributedString = try? NSAttributedString(data: data,
                                                              options: [.documentType: NSAttributedString.DocumentType.html],
                                                              documentAttributes: nil) {
                return attributedString.stringsWithAttributes
            }
            return []
        }))

    case .bookmarkResponse(.failure(let failure)):
        state.toastMessage = "\(failure.error)"

    case .loadList:
        break

    case .loadCategories:
        state.currentPage = 0
        return APIService.shared.getCategories(.list(includeSubcategories: true))
            .receive(on: environment.mainQueue)
            .catchToEffect(BookmarkAction.categoriesResponse)

    case .categoriesResponse(.success(let categories)):
        state.categories = categories
        let username = UserDefaults.standard.string(forKey: "com.womenoverseas.username")?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        return APIService.shared.bookmark(.list(username: username, page: state.currentPage))
            .receive(on: environment.mainQueue)
            .catchToEffect(BookmarkAction.bookmarkResponse)

    case .categoriesResponse(.failure(let failure)):
        state.toastMessage = "\(failure.error)"
    }
    return .none
}

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
}

struct TopicEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue> = .main
}

let topicReducer = Reducer<TopicState, TopicAction, TopicEnvironment> { state, action, environment in
    switch action {
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

struct StringWithAttributes: Hashable, Identifiable {
    let id = UUID()
    let string: String
    let attrs: [NSAttributedString.Key: Any]

    static func == (lhs: StringWithAttributes, rhs: StringWithAttributes) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension NSAttributedString {
    var stringsWithAttributes: [StringWithAttributes] {
        var attributes = [StringWithAttributes]()
         enumerateAttributes(in: NSRange(location: 0, length: length), options: []) { (attrs, range, _) in
             let string = attributedSubstring(from: range).string
            attributes.append(StringWithAttributes(string: string, attrs: attrs))
         }
        return attributes
    }
}
