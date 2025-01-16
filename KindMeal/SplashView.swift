//
//  SplashView.swift
//  KindMeal
//
//  Created by Admin on 2025-01-08.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            LoginView()
        } else {
            ZStack {
                Color(red: 229/255, green: 255/255, blue: 192/255)
                    .ignoresSafeArea()

                GeometryReader { geometry in
                    Image("Connecting Hearts Through Meals.")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
