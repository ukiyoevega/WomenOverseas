//
//  Poster.swift
//  WMO
//
//  Created by weijia on 2022/5/26.
//

import Foundation

struct Poster: Decodable {
    let extras: String? // latest
    let description: String
    let uid: Int
    /*
    let primaryGroupId: Int
    let flairGroupId: Int
    */
    enum CodingKeys: String, CodingKey {
        case extras
        case description
        case uid = "user_id"
    }
}
