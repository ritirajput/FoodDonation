//
//  MainView.swift
//  KindMeal
//
//  Created by Nabeel Shajahan on 2024-10-30.
//

import SwiftUI

struct MainView: View {
    @State private var showingDonationForm = false

    var body: some View {
        NavigationView {
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
            }
            .sheet(isPresented: $showingDonationForm) {
                MakeDonationView()
            }
            .navigationTitle("Dashboard")
        }
    }
}


#Preview {
    MainView()
}
