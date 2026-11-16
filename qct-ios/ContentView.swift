//
//  ContentView.swift
//  qct-ios
//

import Foundation
import SwiftUI

struct ContentView: View {
    @State private var products: [Product] = []
    @State private var errorText: String?
    @State private var isLoading = false

    // Панель
    @State private var searchText = ""
    @State private var selectedFilter: Filter = .all
    @State private var sort: SortOption = .default

    private let url = ApiClient.adminProductsURL

    enum Filter: Hashable {
        case all
        case onSale
        case inStock
        case category(String)
    }

    enum SortOption: String, CaseIterable, Identifiable {
        case `default` = "По умолчанию"
        case priceAsc = "Цена ↑"
        case priceDesc = "Цена ↓"
        case rating = "По рейтингу"
        var id: String { rawValue }
    }

    // MARK: - Computed

    private var categories: [String] {
        Array(Set(products.compactMap(\.category))).sorted()
    }

    private var filteredProducts: [Product] {
        var result = products

        switch selectedFilter {
        case .all: break
        case .onSale: result = result.filter(\.hasDiscount)
        case .inStock: result = result.filter { $0.unlimitedStock || $0.stock > 0 }
        case .category(let cat): result = result.filter { $0.category == cat }
        }

        let q = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        if !q.isEmpty {
            result = result.filter { p in
                p.name.lowercased().contains(q)
                || p.storeName.lowercased().contains(q)
                || (p.category ?? "").lowercased().contains(q)
                || (p.tags ?? []).contains { $0.lowercased().contains(q) }
            }
        }

        switch sort {
        case .default: break
        case .priceAsc:
            result.sort { (Double($0.effectivePrice) ?? 0) < (Double($1.effectivePrice) ?? 0) }
        case .priceDesc:
            result.sort { (Double($0.effectivePrice) ?? 0) > (Double($1.effectivePrice) ?? 0) }
        case .rating:
            result.sort { ($0.rating ?? 0) > ($1.rating ?? 0) }
        }

        return result
    }

    private var hasActiveFilters: Bool {
        selectedFilter != .all || !searchText.isEmpty || sort != .default
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar

                Divider()

                content
            }
            .navigationTitle("Товары (\(filteredProducts.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Сортировка", selection: $sort) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
        }
        .task { await load() }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        VStack(spacing: 10) {
            // Поиск
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Поиск: название, магазин, тег…", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Чипсы
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    chip("Все", isSelected: selectedFilter == .all) {
                        selectedFilter = .all
                    }
                    chip("Со скидкой", isSelected: selectedFilter == .onSale, icon: "tag.fill") {
                        selectedFilter = .onSale
                    }
                    chip("В наличии", isSelected: selectedFilter == .inStock, icon: "checkmark.circle.fill") {
                        selectedFilter = .inStock
                    }
                    if !categories.isEmpty {
                        Divider().frame(height: 20)
                        ForEach(categories, id: \.self) { cat in
                            chip(cat, isSelected: selectedFilter == .category(cat)) {
                                selectedFilter = .category(cat)
                            }
                        }
                    }
                }
                .padding(.horizontal, 2)
            }

            // Сводка
            HStack {
                Text("Найдено: \(filteredProducts.count) из \(products.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if hasActiveFilters {
                    Button("Сбросить") {
                        withAnimation(.snappy) {
                            searchText = ""
                            selectedFilter = .all
                            sort = .default
                        }
                    }
                    .font(.caption.weight(.medium))
                }
                Spacer()
                Text(sort.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    private func chip(_ title: String, isSelected: Bool, icon: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: {
            withAnimation(.snappy) { action() }
        }) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon).font(.caption2)
                }
                Text(title).font(.caption.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if isLoading {
            Spacer()
            ProgressView("Загрузка...")
            Spacer()
        } else if let errorText {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.orange)
                Text(errorText)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                Button("Повторить") { Task { await load() } }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            Spacer()
        } else if filteredProducts.isEmpty {
            Spacer()
            ContentUnavailableView(
                hasActiveFilters ? "Ничего не найдено" : "Нет товаров",
                systemImage: hasActiveFilters ? "magnifyingglass" : "tray",
                description: hasActiveFilters ? Text("Попробуйте изменить фильтры или запрос") : nil
            )
            Spacer()
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredProducts) { product in
                        NavigationLink {
                            ProductDetailView(product: product)
                        } label: {
                            ProductCard(product: product)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .refreshable { await load() }
            .scrollDismissesKeyboard(.immediately)
        }
    }

    // MARK: - Load

    private func load() async {
        isLoading = true
        errorText = nil
        defer { isLoading = false }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ProductsResponse.self, from: data)
            products = response.content
        } catch {
            errorText = "Ошибка: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ContentView()
}
