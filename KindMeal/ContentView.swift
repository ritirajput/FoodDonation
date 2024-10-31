//
//  ContentView.swift
//  KindMeal
//
//  Created by Nabeel Shajahan on 2024-10-29.
//

import SwiftUI

struct ContentView: View {
    @State private var isActive = false

    var body: some View {
        VStack {
            if isActive {
                LoginView()
            } else {
                SplashView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
