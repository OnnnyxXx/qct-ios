//
//  ApiClient.swift
//  qct-ios
//
//  Created by ivan on 15.11.2026.
//

import Foundation

enum ApiClient {
    
    static let baseURL = URL(string: "http://127.0.0.1:8080")!

    /// Продукты для админки (с пагинацией)
    static var adminProductsURL: URL {
        var components = URLComponents(url: baseURL.appendingPathComponent("admin/v1/admin/products"),
                                       resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "page", value: "0"),
            URLQueryItem(name: "size", value: "20")
        ]
        return components.url!
    }
}
