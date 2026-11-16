//
//  ProductsResponse.swift
//  qct-ios
//
//  Created by ivan on 15.11.2026.
//

import Foundation

struct ProductsResponse: Decodable {
    let content: [Product]
    let totalElements: Int?
    let totalPages: Int?
}

