//
//  DonationHistoryView.swift
//  KindMeal
//
//  Created by Nabeel Shajahan on 2024-10-31.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct DonationHistoryView: View {
    @State private var donations: [Donation] = []
    @State private var filteredDonations: [Donation] = []
    @State private var selectedTab: String = "Open"
    @State private var errorMessage: ErrorMessage?

    private let tabs = ["Open", "Reserved", "Closed"]
    private var databaseRef: DatabaseReference = Database.database().reference()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 229/255, green: 255/255, blue: 192/255)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Donation History")
                        .font(.custom("AvenirNext-Bold", size: 28))
                        .foregroundColor(Color(red: 22/255, green: 137/255, blue: 12/255))
                        .shadow(radius: 2)

                    HStack {
                        ForEach(tabs, id: \.self) { tab in
                            Button(action: {
                                self.selectedTab = tab
                                filterDonations(for: tab)
                            }) {
                                Text(tab)
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(selectedTab == tab ? Color.green.opacity(0.8) : Color.white)
                                    .foregroundColor(selectedTab == tab ? .white : .gray)
                                    .cornerRadius(10)
                                    .shadow(radius: selectedTab == tab ? 5 : 0)
                            }
                        }
                    }
                    .padding(.horizontal)

                    if filteredDonations.isEmpty {
                        VStack {
                            Image(systemName: "tray")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                                .padding(.bottom, 10)
                            Text("No \(selectedTab.lowercased()) donations to display.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding()
                        }
                    } else {
                        ScrollView {
                            ForEach(filteredDonations) { donation in
                                DonationCard(donation: donation)
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                            }
                        }
                    }

                    Spacer()
                }
                .onAppear {
                    fetchAllDonations()
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .alert(item: $errorMessage) { error in
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func fetchAllDonations() {
        databaseRef.child("donations").observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: Any] else {
                self.donations = []
                self.filteredDonations = []
                return
            }

            self.donations = data.compactMap { key, value in
                if let donationData = value as? [String: Any] {
                    return Donation(id: key, data: donationData)
                }
                return nil
            }

            filterDonations(for: self.selectedTab)
        } withCancel: { error in
            self.errorMessage = ErrorMessage(message: error.localizedDescription)
        }
    }

    private func filterDonations(for tab: String) {
        switch tab {
        case "Open":
            self.filteredDonations = donations.filter { $0.isOpen }
        case "Reserved":
            self.filteredDonations = donations.filter { $0.isReserved }
        case "Closed":
            self.filteredDonations = donations.filter { $0.isClosed }
        default:
            break
        }
    }
}

struct DonationCard: View {
    let donation: Donation

    var body: some View {
        NavigationLink(destination: DonationDetailView(donationId: donation.id)) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(donation.donationName)
                        .font(.headline)
                        .foregroundColor(.black)
                    Spacer()
                    Text(donation.derivedStatus)
                        .font(.subheadline)
                }

                Text("Meal Type: \(donation.mealType)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("Quantity: \(donation.quantity) \(donation.quantityType)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("Contact: \(donation.contactNumber)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
}

struct Donation: Identifiable {
    let id: String
    let donationName: String
    let mealType: String
    let quantity: Int
    let quantityType: String
    let contactNumber: String
    let description: String?
    let location: [String: Double]?
    let timestamp: Int
    let reservedBy: String?
    let closed: Bool

    var isOpen: Bool { reservedBy == nil && !closed }
    var isReserved: Bool { reservedBy != nil && !closed }
    var isClosed: Bool { closed }

    var derivedStatus: String {
        if isOpen { return "Open" }
        if isReserved { return "Reserved" }
        return "Closed" }

    init?(id: String, data: [String: Any]) {
        guard
            let donationName = data["donationName"] as? String,
            let mealType = data["mealType"] as? String,
            let quantity = data["quantity"] as? Int,
            let quantityType = data["quantityType"] as? String,
            let contactNumber = data["contactNumber"] as? String,
            let timestamp = data["timestamp"] as? Int
        else {
            return nil
        }

        self.id = id
        self.donationName = donationName
        self.mealType = mealType
        self.quantity = quantity
        self.quantityType = quantityType
        self.contactNumber = contactNumber
        self.description = data["description"] as? String
        self.location = data["location"] as? [String: Double]
        self.timestamp = timestamp
        self.reservedBy = data["reservedBy"] as? String
        self.closed = data["closed"] as? Bool ?? false
    }
}

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}
