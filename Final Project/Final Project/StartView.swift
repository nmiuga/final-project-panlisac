//
//  StartView.swift
//  Final Project
//
//  Created by Lisa Pan on 4/26/26.
//

import SwiftUI

import SwiftUI

struct StartView: View {

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brown
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Image
                    Image("potato")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                    // Photo creds: https://pixabay.com/vectors/potatoes-thumbs-up-potato-3098852/
                    
                    // Text
                    Text("Welcome to Potatoland!!")
                        .font(.custom("Pacifico Regular", size: 40))
                        .bold()
                    Text("Find Your Perfect Potato Dish Today!")
                        .font(.title3)
                    
                    // Button
                    VStack {
                        NavigationLink("Get Started") {
                            ContentView()
                        }
                        .padding()
                        .background(Color(red: 237/255, green: 234/255, blue: 222/255))
                        .foregroundColor(.black)
                        .cornerRadius(50)
                        .padding([.top], 20)
                    }
                }
            }
            //.padding(.horizontal)
        }
    }
}

#Preview {
    StartView()
}
