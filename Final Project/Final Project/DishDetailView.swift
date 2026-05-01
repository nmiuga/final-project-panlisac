// DishDetailView.swift
// Detailed view with card layout, rating, favorite, comments, and tags

import SwiftUI

struct DishDetailView: View {
    @EnvironmentObject var store: DishStore
    let dish: Dish

    @State private var commentText: String = ""

    var body: some View {
        ZStack {
            Color.brown
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Card container
                    VStack(alignment: .leading, spacing: 12) {
                        // Image (prefer user-uploaded image if available)
                        Group {
                            if let data = dish.uiImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(dish.imageName)
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // Title / Heading in accent color with custom font placeholder
                        Text(dish.name)
                            .font(.custom("Pacifico Regular", size: 28))
                            .foregroundColor(.accentColor)
                            .padding(.top, 4)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            // Subheading
                            Text("Overview")
                                .font(.title3.weight(.semibold))

                            // Body text with line spacing
                            Text(dish.shortDescription)
                                .font(.body)
                                .lineSpacing(6)
                        }
                        .padding([.vertical], 10)
                        
                        // External link placeholder
                        Link("View recipe", destination: URL(string: dish.link)!)
                            .font(.body)
                            .foregroundColor(.teal)

                        // Rating control (supports half-stars)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Rating")
                                .font(.headline)
                                .padding([.top], 10)
                            VStack(alignment: .leading, spacing: 15) {
                                // Ratings
                                StarRatingView(rating: store.rating(for: dish)) { newValue in
                                    store.setRating(newValue, for: dish)
                                }
                                
                                // Favorite toggle
                                Button {
                                    store.toggleFavorite(dish)
                                } label: {
                                    Label(store.isFavorite(dish) ? "Added to Favorites" : "Add to Favorites", systemImage: store.isFavorite(dish) ? "heart.fill" : "heart")
                                        .font(.headline)
                                }
                                .buttonStyle(.borderedProminent)
                                .shadow(color: .gray, radius: 4)
                            }
                        }
                        
                        // Tags
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Categories")
                                .font(.headline)
                                .padding([.top], 10)
                            HStack(spacing: 10) {
                                // Enum-backed tags (navigate to TagView)
                                ForEach(dish.tags) { tag in
                                    NavigationLink(destination: TagView(tag: tag).environmentObject(store)) {
                                        Text(tag.displayName)
                                            .font(.subheadline)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(tag.color.opacity(0.2))
                                            .foregroundColor(.black)
                                            .clipShape(Capsule())
                                    }
                                }
                                // Custom string tags (non-navigable)
                                ForEach(dish.customTags, id: \.self) { custom in
                                    Text(custom)
                                        .font(.subheadline)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.gray.opacity(0.15))
                                        .foregroundColor(.black)
                                        .clipShape(Capsule())
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
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
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
                            .fill(Color(red: 237/255, green: 234/255, blue: 222/255))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical)
            }
            .navigationTitle(dish.name)
            .navigationBarTitleDisplayMode(.inline)
            
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
        .listRowBackground(Color.clear)
    }
}

// MARK: - StarRatingView (supports half-stars)
struct StarRatingView: View {
    var rating: Double // 0...5
    var onChange: (Double) -> Void

    private let maxRating = 5
    private var indices: [Int] { Array(0..<maxRating) }

    private func imageName(for index: Int) -> String {
        let starIndex = Double(index)
        let fillAmount = rating - starIndex
        if fillAmount >= 1 {
            return "star.fill"
        } else if fillAmount >= 0.5 {
            return "star.leadinghalf.filled"
        } else if fillAmount > 0 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            SwiftUI.ForEach(0..<maxRating, id: \.self) { (index: Int) in
                Image(systemName: imageName(for: index))
                    .foregroundStyle(.yellow)
                    .onTapGesture {
                        // Tapping sets to whole-star value
                        onChange(Double(index + 1))
                    }
                    .onLongPressGesture(minimumDuration: 0.01) {
                        // Long press toggles half-star for this position
                        let starIndex = Double(index)
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
