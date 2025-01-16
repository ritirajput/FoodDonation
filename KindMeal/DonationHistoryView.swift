//
//  DonationHistoryView.swift
//  KindMeal
//
//Created by Admin on 2025-01-08.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct DonationHistoryView: View {
    @State private var selectedTab: String = "Open"
    @State private var donations: [Donation] = []
    @State private var errorMessage: ErrorMessage? = nil

    private let tabs = ["Open", "Reserved", "Closed"]
    private let databaseRef = Database.database().reference()

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

                    if donations.isEmpty {
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
                            ForEach(donations) { donation in
                                NavigationLink(destination: EditOpenEntry()){DonationCard(donation: donation)
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                                }.buttonStyle(PlainButtonStyle())
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
            self.donations = donations.filter { $0.isOpen }
        case "Reserved":
            self.donations = donations.filter { $0.isReserved }
        case "Closed":
            self.donations = donations.filter { $0.isClosed }
        default:
            break
        }
    }
}

struct DonationCard: View {
    let donation: Donation

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(donation.donationName)
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                Text(donation.derivedStatus)
                    .font(.subheadline)
                    .foregroundColor(donation.statusColor)
                    Image(systemName: "trash.fill")
                        .foregroundColor(.black)
                        .padding(5)
                
            }
            HStack{
                VStack(alignment: .leading, spacing: 10){
                    Text("Meal Type: \(donation.mealType)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Quantity: \(donation.quantity) \(donation.quantityType)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    if let location = donation.locationName {
                        Text("Location: \(location)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Text("Contact: \(donation.contactNumber)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }.padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            
    }
}
    


struct Donation: Identifiable {
    let id: String
    let donationName: String
    let mealType: String
    let quantity: Int
    let quantityType: String
    let contactNumber: String
    //let status: String
    let locationName: String?
    let isOpen: Bool
    let isReserved: Bool
    let isClosed: Bool
    let derivedStatus: String
    let statusColor: Color

    init(id: String, data: [String: Any]) {
        self.id = id
        self.donationName = data["donationName"] as? String ?? "N/A"
        self.mealType = data["mealType"] as? String ?? "N/A"
        self.quantity = data["quantity"] as? Int ?? 0
        self.quantityType = data["quantityType"] as? String ?? "N/A"
        self.contactNumber = data["contactNumber"] as? String ?? "N/A"
        self.locationName = data["location"] as? String

        self.isOpen = true
        self.isReserved = false
        self.isClosed = false

        self.derivedStatus = isOpen ? "Open" : isReserved ? "Reserved" : "Closed"
        self.statusColor = isOpen ? .green : isReserved ? .orange : .red
    }
}

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}
