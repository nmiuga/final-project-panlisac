//
//  ContentView.swift
//  Final Project
//
//  Created by Lisa Pan on 4/13/26.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var store = DishStore()

    var body: some View {
        NavigationView {
            ZStack {
                Color.brown
                    .ignoresSafeArea()
                
                List(store.dishes) { dish in
                    NavigationLink(destination: DishDetailView(dish: dish).environmentObject(store)) {
                        HStack(spacing: 12) {
                            Image(dish.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(dish.name)
                                        .font(.headline)
                                    if store.isFavorite(dish) {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                            .accessibilityLabel("Favorited")
                                    }
                                }

                                Text(dish.shortDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Color(red: 237/255, green: 234/255, blue: 222/255))
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .navigationTitle("Potato Dishes")
            }
        }
    }
}

#Preview {
    ContentView()
}
