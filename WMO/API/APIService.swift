//
//  APIService.swift
//  WMO
//
//  Created by weijia on 2022/4/22.
//

import Foundation
import ComposableArchitecture

enum APIError: Error {
    case noResponse
    case jsonDecodingError(error: Error)
    case networkError(error: Error)
}

struct Failure: Error {
    let error: Error
}


struct APIService {
    // TODO: test code. decoder reuse issue

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

    private static func generateDataTaskPublisher<ResponseType: Decodable>(endpoint: RESTful) -> Effect<ResponseType, Failure> {
        return URLSession.shared.dataTaskPublisher(for: generateRequest(endpoint: endpoint))
          .map { data, _ in data }
          .decode(type: ResponseType.self, decoder: JSONDecoder())
          .mapError { error in
              print("🥹 ERROR \(error)")
              return Failure(error: error)
          }
          .eraseToEffect()
    }

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
    let decoder = JSONDecoder()
    
    func GET<T: Codable>(endpoint: RESTful,
                                params: [String: String]?,
                                completionHandler: @escaping (Result<T, APIError>) -> Void) {
        let queryURL = baseURL.appendingPathComponent(endpoint.path)
        var components = URLComponents(url: queryURL, resolvingAgainstBaseURL: true)!
        components.queryItems = [
           URLQueryItem(name: "api_key", value: apiKey),
           URLQueryItem(name: "language", value: Locale.preferredLanguages[0])
        ]
        if let params = params {
            for (_, value) in params.enumerated() {
                components.queryItems?.append(URLQueryItem(name: value.key, value: value.value))
            }
        }
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(.failure(.noResponse))
                }
                return
            }
            guard error == nil else {
                DispatchQueue.main.async {
                    completionHandler(.failure(.networkError(error: error!)))
                }
                return
            }
            do {
                let object = try self.decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(.success(object))
                }
            } catch let error {
                DispatchQueue.main.async {
                    #if DEBUG
                    print("JSON Decoding Error: \(error)")
                    #endif
                    completionHandler(.failure(.jsonDecodingError(error: error)))
                }
            }
        }
        task.resume()
    }
    
}
