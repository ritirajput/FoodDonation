//
//  MainView.swift
//  KindMeal
//
//  Created by Nabeel Shajahan on 2024-10-30.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @State private var showingDonationForm = false
    @State private var navigateToLoginView = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to KindMeal")
                    .font(.title)
                    .padding()

                Button(action: {
                    showingDonationForm = true
                }) {
                    Text("Make a Donation")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                NavigationLink(destination: DonationHistoryView()) {
                    Text("View Donation History")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                Spacer()

                // Logout Button
                Button(action: logoutUser) {
                    Text("Logout")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .sheet(isPresented: $showingDonationForm) {
                MakeDonationView()
            }
            .navigationTitle("Dashboard")
            .fullScreenCover(isPresented: $navigateToLoginView) {
                LoginView()
            }
        }
    }

    // Logout Function
    private func logoutUser() {
        do {
            try Auth.auth().signOut()
            navigateToLoginView = true
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

#Preview {
    MainView()
}
