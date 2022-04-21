//
//  APIRequest.swift
//  WMO
//
//  Created by weijia on 2022/4/22.
//

import Foundation
import CryptoKit

private let domain = "https://womenoverseas.com"

enum AppError: Error {
    case asn1ParsingFailed
    case x509CertificateFailed
    case invalidURL(path: String)
    case decryptAPIKeyFailed(error: Error?)
    
}

enum Method: String {
    case GET
    case POST
    case PUT
    case DELETE
}

protocol APIRequest {
    var path: String { get }
    var method: Method { get }
    var parameters: [String: String] { get }
}

extension APIRequest {
    var baseURL: URL? {
        return URL(string: domain)
    }
    
    func absoluteURL() throws -> URL? {
        let buildUrl = baseURL.flatMap { URL(string: $0.absoluteString + path) }
        guard let url = buildUrl, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw AppError.invalidURL(path: path)
        }
        if (!parameters.isEmpty) {
            components.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
        }
        let percentEncodedQuery = query(parameters)
        components.percentEncodedQuery = percentEncodedQuery
        return components.url
        
//        var request = URLRequest(url: components.url!)
//        request.httpMethod = method.rawValue
//
//
//        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "accept")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
//        return request.url
    }
    
    private func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []

        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    private func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        let arrayEncoding: ArrayEncoding = .brackets

        /// The encoding to use for `Bool` parameters.
        let boolEncoding: BoolEncoding = .numeric

        var components: [(String, String)] = []
        switch value {
        case let dictionary as [String: Any]:
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        case let array as [Any]:
            for value in array {
                components += queryComponents(fromKey: arrayEncoding.encode(key: key), value: value)
            }
        case let number as NSNumber:
            if number.isBool {
                components.append((escape(key), escape(boolEncoding.encode(value: number.boolValue))))
            } else {
                components.append((escape(key), escape("\(number)")))
            }
        case let bool as Bool:
            components.append((escape(key), escape(boolEncoding.encode(value: bool))))
        default:
            components.append((escape(key), escape("\(value)")))
        }
        return components
    }
    
    public func escape(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? string
    }
}



