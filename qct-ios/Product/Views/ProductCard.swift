//
//  ProductCard.swift
//  qct-ios
//
//  Created by ivan on 15.11.2026.
//

import SwiftUI

struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: product.imageURL) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    case .failure: placeholder
                    case .empty: placeholder.overlay(ProgressView())
                    @unknown default: placeholder
                    }
                }
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .clipped()

                if product.hasDiscount, let percent = product.discountPercent, percent > 0 {
                    Text("-\(percent)%")
                        .font(.caption.bold())
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.red).foregroundStyle(.white)
                        .clipShape(Capsule())
                        .padding(10)
                }

                VStack {
                    Spacer()
                    HStack {
                        stockBadge
                        Spacer()
                        if product.freeShipping == true {
                            Text("Бесплатная доставка")
                                .font(.caption2.weight(.medium))
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(10)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(product.storeName).font(.caption).foregroundStyle(.secondary)
                    if let c = product.category {
                        Text("·").foregroundStyle(.secondary)
                        Text(c).font(.caption).foregroundStyle(.secondary)
                    }
                }

                Text(product.name).font(.headline).lineLimit(2)

                if let d = product.description {
                    Text(d).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                }

                if let r = product.rating, let rc = product.reviewsCount, rc > 0 {
                    HStack(spacing: 3) {
                        ForEach(0..<5, id: \.self) { i in
                            Image(systemName: Formatters.starName(index: i, rating: r))
                                .font(.caption2).foregroundStyle(.yellow)
                        }
                        Text(String(format: "%.1f", r)).font(.caption)
                        Text("(\(rc))").font(.caption).foregroundStyle(.secondary)
                    }
                }

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(product.effectivePrice + " ₽")
                        .font(.title3.bold())
                        .foregroundStyle(product.hasDiscount ? .red : .primary)
                    if product.hasDiscount, let old = product.oldPrice {
                        Text(old + " ₽")
                            .font(.caption).strikethrough().foregroundStyle(.secondary)
                    }
                }

                if let tags = product.tags, !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                    .background(Color.accentColor.opacity(0.12))
                                    .foregroundStyle(Color.accentColor)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .padding(12)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private var placeholder: some View {
        Color(.tertiarySystemFill)
            .overlay(Image(systemName: "photo").font(.largeTitle).foregroundStyle(.secondary))
    }

    private var stockBadge: some View {
        Group {
            if product.unlimitedStock {
                Label("В наличии", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
            } else if product.stock > 0 {
                Label("\(product.stock) шт.", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
            } else {
                Label("Нет в наличии", systemImage: "xmark.circle.fill").foregroundStyle(.red)
            }
        }
        .font(.caption2.weight(.semibold))
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}
