//
//  Tag.swift
//  WMO
//
//  Created by weijia on 2022/5/27.
//

import Foundation

struct Tag: Decodable, Equatable {
    let id: String
    let text: String
    let name: String
    let description: String?
    let count: Int
    let pmCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, text, name, description, count
        case pmCount = "pm_count"
    }
}
