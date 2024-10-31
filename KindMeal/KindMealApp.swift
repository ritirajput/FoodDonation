//
//  KindMealApp.swift
//  KindMeal
//
//  Created by Nabeel Shajahan on 2024-10-29.
//

import SwiftUI
import Firebase

@main
struct KindMealApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
#Preview {
    
}
