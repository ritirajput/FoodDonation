import SwiftUI
import FirebaseDatabase
import MapKit

struct DonationDetailView: View {
    @State private var donation: DonationDetail?
    @State private var errorMessage: DetailErrorMessage? = nil
    @State private var isLoading = true
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        latitudinalMeters: 500,
        longitudinalMeters: 500
    )
    @State private var showMap = false

    private let donationId: String
    private let databaseRef = Database.database().reference()

    init(donationId: String) {
        self.donationId = donationId
    }

    var body: some View {
        ZStack {
            Color(red: 229 / 255, green: 255 / 255, blue: 192 / 255)
                .ignoresSafeArea()

            if isLoading {
                ProgressView("Loading...")
            } else if let donation = donation {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title
                        Text(donation.donationName)
                            .font(.custom("AvenirNext-Bold", size: 28))
                            .foregroundColor(Color(red: 22 / 255, green: 137 / 255, blue: 12 / 255))
                            .shadow(radius: 2)

                        // Description
                        if let description = donation.description {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.gray)
                        }

                        // Meal Type
                        Text("Meal Type: \(donation.mealType)")
                            .font(.headline)
                            .foregroundColor(.gray)

                        // Quantity
                        Text("Quantity: \(donation.quantity) \(donation.quantityType)")
                            .font(.headline)
                            .foregroundColor(.gray)

                        // Contact
                        Text("Contact: \(donation.contactNumber)")
                            .font(.headline)
                            .foregroundColor(.gray)

                        // Map
                        if showMap {
                            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: false)
                                .frame(height: 300)
                                .cornerRadius(10)
                        }

                        Button(action: deleteDonation) {
                            Text("Delete Donation")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Donation Details")
                .navigationBarTitleDisplayMode(.inline)
                .alert(item: $errorMessage) { error in
                    Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
                }
            } else {
                Text("No details available.")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            fetchDonationDetails()
        }
    }

    private func fetchDonationDetails() {
        databaseRef.child("donations").child(donationId).observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: Any] else {
                self.errorMessage = DetailErrorMessage(message: "Failed to load donation details.")
                self.isLoading = false
                return
            }

            // Parse donation data
            self.donation = DonationDetail(id: donationId, data: data)

            // Fetch location coordinates if available
            if let locationData = data["location"] as? [String: Any],
               let latitude = locationData["latitude"] as? CLLocationDegrees,
               let longitude = locationData["longitude"] as? CLLocationDegrees {
                let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let newRegion = MKCoordinateRegion(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
                self.region = newRegion
                self.showMap = true
            }

            self.isLoading = false
        } withCancel: { error in
            self.errorMessage = DetailErrorMessage(message: error.localizedDescription)
            self.isLoading = false
        }
    }

    private func deleteDonation() {
        databaseRef.child("donations").child(donationId).removeValue { error, _ in
            if let error = error {
                self.errorMessage = DetailErrorMessage(message: error.localizedDescription)
            } else {
                self.errorMessage = DetailErrorMessage(message: "Donation deleted successfully.")
            }
        }
    }
}

struct DonationDetail: Identifiable {
    let id: String
    let donationName: String
    let description: String?
    let mealType: String
    let quantity: Int
    let quantityType: String
    let contactNumber: String

    init(id: String, data: [String: Any]) {
        self.id = id
        self.donationName = data["donationName"] as? String ?? "Unknown"
        self.description = data["description"] as? String
        self.mealType = data["mealType"] as? String ?? "Unknown"
        self.quantity = data["quantity"] as? Int ?? 0
        self.quantityType = data["quantityType"] as? String ?? "Unknown"
        self.contactNumber = data["contactNumber"] as? String ?? "Unknown"
    }
}

struct DetailErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}
