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

public struct APIService {
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
