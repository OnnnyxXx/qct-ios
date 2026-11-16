//
//  ProductDetailView.swift
//  qct-ios
//
//  Created by ivan on 15.11.2026.
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: product.imageURL) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    case .failure: placeholder
                    case .empty: placeholder.overlay(ProgressView())
                    @unknown default: placeholder
                    }
                }
                .frame(height: 280)
                .frame(maxWidth: .infinity)
                .clipped()

                VStack(alignment: .leading, spacing: 16) {
                    header
                    priceBlock
                    ratingBlock
                    Divider()
                    section("Наличие", rows: [
                        ("На складе", product.unlimitedStock ? "Без ограничений" : "\(product.stock) шт."),
                        ("Статус", product.status ?? "—"),
                        ("Видимость", product.visibility ?? "—"),
                        ("Состояние", product.condition ?? "—")
                    ])
                    if let specs = product.specifications, !specs.isEmpty {
                        section("Характеристики", rows: specs.map { ($0.key, $0.value) })
                    }
                    section("Доставка", rows: [
                        ("Бесплатная доставка", product.freeShipping == true ? "Да" : "Нет"),
                        ("Вес отправки", Formatters.double(product.shippingWeight, unit: " кг")),
                        ("Габариты (Ш×В×Д)", Formatters.dimensions(width: product.shippingWidth, height: product.shippingHeight, length: product.shippingLength)),
                        ("Вес товара", Formatters.double(product.weight, unit: " кг"))
                    ])
                    section("Гарантии и возврат", rows: [
                        ("Гарантия", product.warrantyMonths.map { "\($0) мес." } ?? "—"),
                        ("Возврат", product.returnable == true ? "Возможен" : "Нет")
                    ])
                    section("Идентификация", rows: [
                        ("SKU", product.sku ?? "—"),
                        ("Штрихкод", product.barcode ?? "—"),
                        ("ID", "\(product.id)"),
                        ("ID магазина", "\(product.storeId)")
                    ])
                    section("Статистика", rows: [
                        ("Просмотры", "\(product.viewsCount ?? 0)"),
                        ("Покупки", "\(product.purchasesCount ?? 0)"),
                        ("В избранном", "\(product.favoritesCount ?? 0)"),
                        ("Отзывы", "\(product.reviewsCount ?? 0)")
                    ])
                    section("Даты", rows: [
                        ("Создан", Formatters.date(product.createdAt)),
                        ("Обновлён", Formatters.date(product.updatedAt)),
                        ("Опубликован", Formatters.date(product.publishedAt))
                    ])
                    if product.onSale {
                        section("Период скидки", rows: [
                            ("Начало", Formatters.date(product.discountStart)),
                            ("Окончание", Formatters.date(product.discountEnd))
                        ])
                    }
                    tagsBlock
                    galleryBlock
                }
                .padding()
            }
        }
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var placeholder: some View {
        Color(.tertiarySystemFill)
            .overlay(Image(systemName: "photo").font(.system(size: 48)).foregroundStyle(.secondary))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(product.storeName).font(.caption).foregroundStyle(.secondary)
                if let c = product.category {
                    Text("·").foregroundStyle(.secondary)
                    Text(c).font(.caption).foregroundStyle(.secondary)
                }
            }
            Text(product.name).font(.title2.bold())
            if let d = product.description {
                Text(d).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }

    private var priceBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(product.effectivePrice + " ₽")
                    .font(.title.bold())
                    .foregroundStyle(product.hasDiscount ? .red : .primary)
                if product.hasDiscount, let old = product.oldPrice {
                    Text(old + " ₽").strikethrough().foregroundStyle(.secondary)
                }
                if let percent = product.discountPercent, percent > 0 {
                    Text("-\(percent)%")
                        .font(.caption.bold())
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color.red.opacity(0.15)).foregroundStyle(.red)
                        .clipShape(Capsule())
                }
            }
            if product.hasDiscount, let savings = product.discountSavings, savings > 0 {
                Text("Экономия: \(savings) ₽").font(.caption).foregroundStyle(.green)
            }
        }
    }

    @ViewBuilder
    private var ratingBlock: some View {
        if let r = product.rating, let rc = product.reviewsCount, rc > 0 {
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { i in
                    Image(systemName: Formatters.starName(index: i, rating: r))
                        .foregroundStyle(.yellow)
                }
                Text(String(format: "%.1f", r)).font(.subheadline.weight(.medium))
                Text("(\(rc) отзывов)").font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var tagsBlock: some View {
        if let tags = product.tags, !tags.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Теги").font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Color.accentColor.opacity(0.12))
                                .foregroundStyle(Color.accentColor)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var galleryBlock: some View {
        if let images = product.images, !images.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Галерея").font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(images, id: \.self) { img in
                            AsyncImage(url: URL(string: img)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.15)
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
        }
    }

    private func section(_ title: String, rows: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    HStack(alignment: .top) {
                        Text(row.0).font(.subheadline).foregroundStyle(.secondary)
                        Spacer()
                        Text(row.1).font(.subheadline).multilineTextAlignment(.trailing)
                    }
                    .padding(.vertical, 8).padding(.horizontal, 12)
                    if index < rows.count - 1 {
                        Divider().padding(.leading, 12)
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

