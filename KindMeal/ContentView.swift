//
//  ContentView.swift
//  KindMeal
//
// Created by Admin on 2025-01-08.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isActive = false
    @State private var isAuthenticated = false

    var body: some View {
        VStack {
            if isActive {
                if isAuthenticated {
                    MainView()
                } else {
                    LoginView()
                }
            } else {
                SplashView()
            }
        }
        .onAppear {
            checkAuthState()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }

    private func checkAuthState() {
        if Auth.auth().currentUser != nil {
            isAuthenticated = true
        } else {
            isAuthenticated = false
        }
    }
}

#Preview {
    ContentView()
}
