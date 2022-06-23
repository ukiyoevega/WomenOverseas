//
//  BookmarkCore.swift
//  WMO
//
//  Created by weijia on 2022/6/23.
//

import ComposableArchitecture

// MARK: - Bookmark

struct BookmarkState: Equatable {
    var bookmarks: [Bookmark] = []
    var bookmarkContent: [[StringWithAttributes]] = []
    var toastMessage: String?
    var categories: [CategoryList.Category] = []
    var currentPage: Int = 0
    var reachEnd = false

    mutating func reset() {
        currentPage = 0
        bookmarks = []
        reachEnd = false
        bookmarkContent = []
    }
}

enum BookmarkAction {
    case loadList
    case dismissToast
    case bookmarkResponse(Result<BookmarkResponse, Failure>)

    case loadCategories
    case categoriesResponse(Result<[CategoryList.Category], Failure>)
}

let bookmarkReducer = Reducer<BookmarkState, BookmarkAction, ProfileEnvironment> { state, action, environment in
    let username = UserDefaults.standard.string(forKey: "com.womenoverseas.username")?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""

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
        if resp.bookmarkList.loadMoreKey == nil {
            state.reachEnd = true
        }

    case .bookmarkResponse(.failure(let failure)):
        state.toastMessage = "\(failure.error)"

    case .loadList:
        return APIService.shared.bookmark(.list(username: username, page: state.currentPage))
            .receive(on: environment.mainQueue)
            .catchToEffect(BookmarkAction.bookmarkResponse)

    case .loadCategories:
        state.reset()
        return APIService.shared.getCategories(.list(includeSubcategories: true))
            .receive(on: environment.mainQueue)
            .catchToEffect(BookmarkAction.categoriesResponse)

    case .categoriesResponse(.success(let categories)):
        state.categories = categories
        return APIService.shared.bookmark(.list(username: username, page: state.currentPage))
            .receive(on: environment.mainQueue)
            .catchToEffect(BookmarkAction.bookmarkResponse)

    case .categoriesResponse(.failure(let failure)):
        state.toastMessage = "\(failure.error)"
    }
    return .none
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
