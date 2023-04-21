//
//  APIService.swift
//  WMO
//
//  Created by weijia on 2022/4/22.
//

import Foundation
import ComposableArchitecture
import WebKit
import Combine

enum APIError: Error {
  case noResponse
  case jsonDecodingError(error: Error)
  case networkError(error: Error)
  case invalidParams(params: [String : Any])
}

struct Failure: Error {
  let error: Error
}

struct APIService {

  init() {
    self.jsonDecoder = JSONDecoder()
    self.jsonDecoder.dateDecodingStrategy = .iso8601
  }

  func getAllTopics(of category: CategoryList.Category) async throws -> [TopicListResponse] {
    let pages = Int(ceil(Double(category.topicCount ?? 0) / 30))
    var res: [TopicListResponse] = Array(repeating: TopicListResponse(users: nil, topicList: nil),
                                         count: pages)
    try await withThrowingTaskGroup(of: (Int, TopicListResponse).self, body: { group in
      for page in 0..<pages {
        group.addTask {
          let topic = try await self.getTopics(endpoint: EndPoint.Topics.category(slug: category.slug, id: category.id, page: page))
          return (page, topic)
        }
        while let result = await group.nextResult() {
          switch result {
          case .failure(let error):
            throw error
          case .success(let (index, listResponse)):
            res[index] = listResponse
          }
        }
      }
    })
    return res
  }

  private func getTopics(endpoint: RESTful) async throws -> TopicListResponse {
    do {
      let (data, _) = try await URLSession.shared.data(for: APIService.generateRequest(endpoint: endpoint))
      let topicResponse = try jsonDecoder.decode(TopicListResponse.self, from: data)
      return topicResponse
    } catch(let error) {
      throw APIError.networkError(error: error)
    }
  }

  private static func generateRequest(endpoint: RESTful) -> URLRequest {
    var components = URLComponents(string: "https://womenoverseas.com" + endpoint.path)!
    components.queryItems = endpoint.params.map { param in
      URLQueryItem(name: param.key, value: "\(param.value)")
    }
    var urlRequest = URLRequest(url: components.url!) // TODO: remove force unwrap
    urlRequest.httpMethod = endpoint.method.rawValue
    urlRequest.setValue(APIService.shared.apiKey, forHTTPHeaderField: "user-api-key")
    return urlRequest
  }

  // TODO: test code. decoder reuse issue
  
  public static func removeCache() {
    WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
      WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records, completionHandler: {
        print("Deleted: \(records.map(\.displayName))")
      })
    }
  }

  static func generateDataTaskPublisher<ResponseType: Decodable>(endpoint: RESTful) -> Effect<ResponseType, Failure> {
    return URLSession.shared.dataTaskPublisher(for: generateRequest(endpoint: endpoint))
      .map { data, _ in data }
      .decode(type: ResponseType.self, decoder: JSONDecoder())
      .mapError { error in
        print("🥹 ERROR \(error)")
        return Failure(error: error)
      }
      .eraseToEffect()
  }
  
  lazy var getUserActions: (EndPoint.Topics) -> Effect<UserActionResponse, Failure> = {
    return { endpoint in APIService.generateDataTaskPublisher(endpoint: endpoint) }
  }()
  
  lazy var bookmark: (EndPoint.Bookmarks) -> Effect<BookmarkResponse, Failure> = {
    return { endpoint in APIService.generateDataTaskPublisher(endpoint: endpoint) }
  }()
  
  lazy var updateUser: (EndPoint.User) -> Effect<UserResponse, Failure> = {
    return { endpoint in APIService.generateDataTaskPublisher(endpoint: endpoint) }
  }()
  
  lazy var getUser: (EndPoint.User) -> Effect<UserResponse, Failure> = {
    return { endpoint in APIService.generateDataTaskPublisher(endpoint: endpoint) }
  }()
  
  lazy var getUserSummary: (EndPoint.User) -> Effect<UserSummaryResponse, Failure> = {
    return { endpoint in APIService.generateDataTaskPublisher(endpoint: endpoint) }
  }()
  
  lazy var getTopics: (EndPoint.Topics) -> Effect<TopicListResponse, Failure> = {
    return { endpoint in APIService.generateDataTaskPublisher(endpoint: endpoint) }
  }()
  
  lazy var getTags: (EndPoint.Tag) -> Effect<TagsResponse, Failure> = {
    return { endpoint in APIService.generateDataTaskPublisher(endpoint: endpoint) }
  }()
  
  lazy var getNotifications: (EndPoint.Noti) -> Effect<NotificationResponse, Failure> = {
    return { endpoint in APIService.generateDataTaskPublisher(endpoint: endpoint) }
  }()
  
  lazy var getCategories: (EndPoint.Category) -> Effect<[CategoryList.Category], Failure> = {
    return { endpoint in
      return URLSession.shared.dataTaskPublisher(for: APIService.generateRequest(endpoint: endpoint))
        .map { data, _ in data }
        .decode(type: CategoriesResponse.self, decoder: JSONDecoder())
        .map({ response in response.categoryList.categories })
        .mapError { error in
          print("🥹 ERROR \(error)")
          return Failure(error: error)
        }
        .eraseToEffect()
    }
  }()
  
  let baseURL = URL(string: "https://www.womenoverseas.com")!
  var apiKey: String {
    get {
      UserDefaults.standard.string(forKey: "com.womenoverseas.apiKey") ?? ""
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "com.womenoverseas.apiKey")
      
    }
  }
  static var shared = APIService()
  private let jsonDecoder: JSONDecoder
}
