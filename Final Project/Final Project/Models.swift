// Models.swift
// Shared models and sample data for the potato dishes app

import SwiftUI
import Combine

// MARK: - Tag model
enum DishTag: String, CaseIterable, Identifiable, Codable {
    case baked, fried, casserole, snack, cooked, breakfast, dessert
    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }

    // Simple color mapping; you can change later
    var color: Color {
        switch self {
        case .baked: return .orange
        case .fried: return .yellow
        case .casserole: return .teal
        case .snack: return .blue
        case .cooked: return .purple
        case .breakfast: return .green
        case .dessert: return .pink
        }
    }
}

// MARK: - Dish model
struct Dish: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var shortDescription: String
    // Image name placeholder; replace with your asset names
    var imageName: String
    // Optional raw image data for user-added dishes
    var uiImageData: Data?
    var tags: [DishTag]
    // Free-form user-defined categories
    var customTags: [String]
    var link: String

    init(id: UUID = UUID(), name: String, shortDescription: String, imageName: String, uiImageData: Data? = nil, tags: [DishTag], customTags: [String] = [], link: String) {
        self.id = id
        self.name = name
        self.shortDescription = shortDescription
        self.imageName = imageName
        self.uiImageData = uiImageData
        self.tags = tags
        self.customTags = customTags
        self.link = link
    }
}

// MARK: - App Store for state (favorites, ratings, comments)
@MainActor
final class DishStore: ObservableObject {
    @Published var dishes: [Dish]

    // Favorites by dish id
    @Published private(set) var favorites: Set<UUID> = []

    // Ratings by dish id (0.0 ... 5.0, half-star increments ok)
    @Published private(set) var ratings: [UUID: Double] = [:]

    // Comments by dish id
    @Published private(set) var comments: [UUID: [String]] = [:]

    init(dishes: [Dish] = SampleData.dishes) {
        self.dishes = dishes
    }

    func isFavorite(_ dish: Dish) -> Bool {
        favorites.contains(dish.id)
    }

    func toggleFavorite(_ dish: Dish) {
        if favorites.contains(dish.id) {
            favorites.remove(dish.id)
        } else {
            favorites.insert(dish.id)
        }
    }

    func rating(for dish: Dish) -> Double {
        ratings[dish.id] ?? 0
    }

    func setRating(_ value: Double, for dish: Dish) {
        let clamped = min(max(0, value), 5)
        ratings[dish.id] = clamped
    }

    func addComment(_ text: String, for dish: Dish) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        comments[dish.id, default: []].append(trimmed)
    }

    func comments(for dish: Dish) -> [String] {
        comments[dish.id] ?? []
    }

    func dishes(with tag: DishTag) -> [Dish] {
        dishes.filter { $0.tags.contains(tag) }
    }
    
    func addDish(_ dish: Dish) {
        dishes.insert(dish, at: 0)
    }
}

// MARK: - Sample Data
enum SampleData {
    // Placeholder descriptions; you can edit later
    static let dishes: [Dish] = [
        Dish(name: "French Fries", shortDescription: "Crispy, golden potato strips fried to perfection.", imageName: "fries", tags: [.fried, .snack], link: "https://www.fifteenspatulas.com/the-secret-to-perfect-homemade-french-fries/"),
        Dish(name: "Mashed Potatoes", shortDescription: "Creamy and buttery mashed potatoes.", imageName: "mashed-potatoes", tags: [.cooked], link: "https://www.spendwithpennies.com/how-to-make-mashed-potatoes/"),
        Dish(name: "Baked Potatoes", shortDescription: "Fluffy baked potato with crispy skin.", imageName: "baked-potato", tags: [.baked], link: "https://www.loveandlemons.com/baked-potato/"),
        Dish(name: "Funeral Potatoes", shortDescription: "Cheesy potato casserole comfort dish.", imageName: "funeral-potatoes", tags: [.casserole, .baked], link: "https://tastesbetterfromscratch.com/funeral-potatoes/"),
        Dish(name: "Roasted Potatoes", shortDescription: "Herb-roasted, crispy-on-the-outside potatoes.", imageName: "roasted-potatoes", tags: [.baked], link: "https://www.spendwithpennies.com/simple-herb-oven-roasted-potatoes/"),
        Dish(name: "Scalloped Potatoes", shortDescription: "Layered potatoes baked in creamy sauce.", imageName: "scalloped-potatoes", tags: [.casserole, .baked], link: "https://iambaker.net/scalloped-potatoes/"),
        Dish(name: "Potato Chips", shortDescription: "Thin, crunchy potato slices.", imageName: "chips", tags: [.fried, .snack], link: "https://www.allrecipes.com/recipe/73135/homestyle-potato-chips/"),
        Dish(name: "Hash Browns", shortDescription: "Shredded potatoes pan-fried until crisp.", imageName: "hash-brown", tags: [.fried, .breakfast], link: "https://www.everydayfamilycooking.com/hash-browns/"),
        Dish(name: "Ice Cream Potato", shortDescription: "Not a real potato, but might just be better than the real thing.", imageName: "ice-cream-potato", tags: [.dessert], link: "https://spoonuniversity.com/school/northeastern/ice-cream-potato/")
    ]
}

