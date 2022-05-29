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

struct Failure: Error, Equatable {}


struct APIService {
    // TODO: test code
    lazy var getTopics: (String) -> Effect<TopicListResponse, Failure> = {
        return { paramPlaceholder in
            let latest = EndPoint.Topics.latest(by: .default, ascending: false)
            let path = latest.path
            var components = URLComponents(string: "https://womenoverseas.com" + path)!
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.setValue(APIService.shared.apiKey, forHTTPHeaderField: "user-api-key")
            
            return URLSession.shared.dataTaskPublisher(for: urlRequest)
              .map { data, _ in data }
              .decode(type: TopicListResponse.self, decoder: JSONDecoder())
              .map({ response in response })
              .mapError { error in
                  print("error \(error)")
                  return Failure() // TODO: error handling
              }
              .eraseToEffect()
        }
    }()
    
    lazy var getCategories: (String) -> Effect<[CategoryList.Category], Failure> = {
        return { paramPlaceholder in
            var components = URLComponents(string: "https://womenoverseas.com" + EndPoint.Category.list.path)!
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.setValue(APIService.shared.apiKey, forHTTPHeaderField: "user-api-key")
            
            return URLSession.shared.dataTaskPublisher(for: urlRequest)
              .map { data, _ in data }
              .decode(type: CategoriesResponse.self, decoder: JSONDecoder())
              .map({ response in response.categoryList.categories })
              .mapError { error in
                  print("error \(error)")
                  return Failure() // TODO: error handling
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
