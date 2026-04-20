// TagView.swift
// Shows a filtered list of dishes for a selected tag

import SwiftUI

struct TagView: View {
    @EnvironmentObject var store: DishStore
    let tag: DishTag

    var body: some View {
        List(store.dishes(with: tag)) { dish in
            NavigationLink(destination: DishDetailView(dish: dish).environmentObject(store)) {
                HStack(spacing: 12) {
                    Image(dish.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dish.name)
                            .font(.headline)
                        Text(dish.shortDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("\(tag.displayName) Dishes")
    }
}

#Preview {
    NavigationView {
        TagView(tag: .baked)
            .environmentObject(DishStore())
    }
}
