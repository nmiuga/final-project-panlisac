// DishDetailView.swift
// Detailed view with card layout, rating, favorite, comments, and tags

import SwiftUI

struct DishDetailView: View {
    @EnvironmentObject var store: DishStore
    let dish: Dish

    @State private var commentText: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Card container
                VStack(alignment: .leading, spacing: 12) {
                    // Image placeholder
                    Image(dish.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Title / Heading in accent color with custom font placeholder
                    Text(dish.name)
                        .font(.custom("YourCustomFontName-Bold", size: 28))
                        .foregroundColor(.accentColor)
                        .padding(.top, 4)

                    // Subheading
                    Text("Overview")
                        .font(.title3.weight(.semibold))

                    // Body text with line spacing
                    Text(dish.shortDescription)
                        .font(.body)
                        .lineSpacing(6)

                    // External link placeholder
                    Link("View recipe", destination: URL(string: "https://www.google.com")!)
                        .font(.body)
                        .foregroundColor(.blue)

                    // Rating control (supports half-stars)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Rating")
                            .font(.headline)
                        StarRatingView(rating: store.rating(for: dish)) { newValue in
                            store.setRating(newValue, for: dish)
                        }
                    }

                    // Favorite toggle
                    Button {
                        store.toggleFavorite(dish)
                    } label: {
                        Label(store.isFavorite(dish) ? "Added to Favorites" : "Add to Favorites", systemImage: store.isFavorite(dish) ? "heart.fill" : "heart")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)

                    // Tags
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Categories")
                            .font(.headline)
                        WrapHStack(spacing: 8) {
                            ForEach(dish.tags) { tag in
                                NavigationLink(destination: TagView(tag: tag).environmentObject(store)) {
                                    Text(tag.displayName)
                                        .font(.subheadline)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(tag.color.opacity(0.2))
                                        .foregroundColor(tag.color)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    // Comments
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Comments")
                            .font(.headline)

                        ForEach(store.comments(for: dish), id: \.self) { comment in
                            Text(comment)
                                .font(.body)
                                .padding(8)
                                .background(Color.secondary.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        HStack(alignment: .top, spacing: 8) {
                            TextEditor(text: $commentText)
                                .frame(minHeight: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary.opacity(0.4))
                                )
                            Button("Submit") {
                                store.addComment(commentText, for: dish)
                                commentText = ""
                            }
                            .buttonStyle(.bordered)
                            .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
            }
            .padding()
        }
        .navigationTitle(dish.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - StarRatingView (supports half-stars)
struct StarRatingView: View {
    var rating: Double // 0...5
    var onChange: (Double) -> Void

    private let maxRating = 5

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<maxRating, id: \.self) { index in
                let starIndex = Double(index)
                let fillAmount = rating - starIndex
                let imageName: String
                if fillAmount >= 1 {
                    imageName = "star.fill"
                } else if fillAmount >= 0.5 {
                    imageName = "star.leadinghalf.filled"
                } else if fillAmount > 0 {
                    // Show half for any fractional > 0; tweak if desired
                    imageName = "star.leadinghalf.filled"
                } else {
                    imageName = "star"
                }

                Image(systemName: imageName)
                    .foregroundStyle(.yellow)
                    .onTapGesture {
                        // Tapping sets to whole-star value
                        onChange(Double(index + 1))
                    }
                    .onLongPressGesture(minimumDuration: 0.01) {
                        // Long press toggles half-star for this position
                        let new = starIndex + 0.5
                        if rating == new { onChange(starIndex) } else { onChange(new) }
                    }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rating: \(rating, specifier: "%.1f") stars")
    }
}

// MARK: - WrapHStack helper to wrap tags
struct WrapHStack<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content

    init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        // Simple flow layout using flexible grid
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: spacing)], spacing: spacing) {
            content
        }
    }
}

#Preview {
    NavigationView {
        DishDetailView(dish: SampleData.dishes.first!)
            .environmentObject(DishStore())
    }
}
