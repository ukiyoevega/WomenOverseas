//
//  BookmarkCore.swift
//  WMO
//
//  Created by weijia on 2022/6/23.
//

import ComposableArchitecture
import Foundation

// MARK: - Bookmark

struct BookmarkState: Equatable {
  var bookmarks: [Bookmark] = []
  var bookmarkContent: [Int: [StringWithAttributes]] = [:]
  var toastMessage: String?
  var categories: [CategoryList.Category] = []
  var currentPage: Int = 0
  var reachEnd = false
  
  mutating func reset() {
    currentPage = 0
    bookmarks = []
    reachEnd = false
    bookmarkContent = [:]
  }
}

struct RemoveBookmarkResponse: Decodable {
  let success: String
  let topic_bookmarked: Bool
  var id: Int?
}

enum BookmarkAction {
  case loadList(onStart: Bool)
  case dismissToast
  case bookmarkResponse(Result<BookmarkResponse, Failure>)
  
  case remove(id: Int)
  case removeRresponse(Result<RemoveBookmarkResponse, Failure>)
  
  case togglePin(id: Int)
  case toggleRresponse(Result<[String: String], Failure>)
  
  case loadCategories
  case categoriesResponse(Result<[CategoryList.Category], Failure>)
}

let bookmarkReducer = AnyReducer<BookmarkState, BookmarkAction, ProfileEnvironment> { state, action, environment in
  let username = UserDefaults.standard.string(forKey: "com.womenoverseas.username")?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
  
  switch action {
  case .remove(let id):
    let effect: EffectPublisher<RemoveBookmarkResponse, Failure> = APIService.generateDataTaskPublisher(endpoint: EndPoint.Bookmarks.delete(id: id))
    return effect
      .receive(on: environment.mainQueue)
      .map({ response in
        var mapped = response
        mapped.id = id
        return mapped
      })
      .catchToEffect(BookmarkAction.removeRresponse)
    
  case .togglePin(let id):
    let effect: EffectPublisher<[String: String], Failure> = APIService.generateDataTaskPublisher(endpoint: EndPoint.Bookmarks.togglePin(id: id))
    return effect
      .receive(on: environment.mainQueue)
      .map({ response in
        var mapped = response
        mapped["id"] = "\(id)"
        return mapped
      })
      .catchToEffect(BookmarkAction.toggleRresponse)
    
  case .removeRresponse(.success(let resp)):
    if !resp.topic_bookmarked, let removedId = resp.id {
      state.bookmarks = state.bookmarks.filter { $0.id != removedId }
      state.bookmarkContent.removeValue(forKey: removedId)
      state.toastMessage = "移除成功"
    }
    
  case .removeRresponse(.failure(let failure)):
    state.toastMessage = "\(failure.error)"
    
  case .toggleRresponse(.success(let resp)):
    if let idString = resp["id"], let id = Int(idString), let index = state.bookmarks.firstIndex(where: { $0.id == id }) {
      var bookmark = state.bookmarks[index]
      bookmark.pinned = !(bookmark.pinned ?? false)
      state.bookmarks[index] = bookmark
    }
    state.toastMessage = "操作成功"
    
  case .toggleRresponse(.failure(let failure)):
    state.toastMessage = "\(failure.error)"
    
  case .dismissToast:
    state.toastMessage = nil
    
  case .bookmarkResponse(.success(let resp)):
    state.currentPage += 1
    state.bookmarks.append(contentsOf: resp.bookmarkList?.bookmarks ?? [])
    resp.bookmarkList?.bookmarks.forEach { bookmark in
      if let data = bookmark.excerpt.data(using: .unicode),
         let attributedString = try? NSAttributedString(data: data,
                                                        options: [.documentType: NSAttributedString.DocumentType.html],
                                                        documentAttributes: nil) {
        state.bookmarkContent[bookmark.id] = attributedString.stringsWithAttributes
      }
    }
    if resp.bookmarkList?.loadMoreKey == nil || resp.bookmarkList?.bookmarks.isEmpty == true || resp.bookmarkList == nil {
      state.reachEnd = true
    }
    
  case .bookmarkResponse(.failure(let failure)):
    state.toastMessage = "\(failure.error)"
    
  case .loadList(let onStart):
    if onStart {
      state.reset()
    }
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
