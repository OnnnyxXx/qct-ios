//
//  ProductDTO.swift
//  qct-ios
//
//  Created by ivan on 15.11.2026.
//

import Foundation

struct Specification: Decodable, Hashable {
    let key: String
    let value: String
}

struct Product: Identifiable, Decodable {
    let id: Int
    let storeId: Int
    let storeName: String
    let name: String
    let description: String?
    let price: String
    let oldPrice: String?
    let stock: Int
    let unlimitedStock: Bool
    let category: String?
    let imageUrl: String?
    let images: [String]?
    let specifications: [Specification]?
    let tags: [String]?
    let discountPercent: Int?
    let discountedPrice: String?
    let discountSavings: Int?
    let onSale: Bool
    let discountStart: String?
    let discountEnd: String?
    let status: String?
    let visibility: String?
    let condition: String?
    let viewsCount: Int?
    let purchasesCount: Int?
    let rating: Double?
    let reviewsCount: Int?
    let favoritesCount: Int?
    let weight: Double?
    let sku: String?
    let barcode: String?
    let freeShipping: Bool?
    let shippingWeight: Double?
    let shippingWidth: Double?
    let shippingHeight: Double?
    let shippingLength: Double?
    let warrantyMonths: Int?
    let returnable: Bool?
    let createdAt: String?
    let updatedAt: String?
    let publishedAt: String?

    var effectivePrice: String { discountedPrice ?? price }
    var imageURL: URL? { imageUrl.flatMap(URL.init(string:)) }

    var hasDiscount: Bool {
        guard onSale,
              let discounted = discountedPrice,
              let p = Double(price),
              let d = Double(discounted) else { return false }
        return d < p
    }
}
