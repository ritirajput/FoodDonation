import SwiftUI
import FirebaseDatabase

struct DonationDetailView: View {
    @State private var donation: Donation?
    @State private var errorMessage: ErrorMessage? = nil
    @State private var isLoading = true
    private let donationId: String
    private let databaseRef = Database.database().reference()
    
    init(donationId: String) {
        self.donationId = donationId
    }
    
    var body: some View {
        ZStack {
            Color(red: 229/255, green: 255/255, blue: 192/255)
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView("Loading...")
            } else if let donation = donation {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title
                        Text(donation.donationName)
                            .font(.custom("AvenirNext-Bold", size: 28))
                            .foregroundColor(Color(red: 22/255, green: 137/255, blue: 12/255))
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
        databaseRef.child("donations").child(donationId).observe(.value) { snapshot in
            guard let data = snapshot.value as? [String: Any] else {
                self.errorMessage = ErrorMessage(message: "Failed to load donation details.")
                self.isLoading = false
                return
            }

            // Parse donation data
            self.donation = Donation(id: donationId, data: data)
            self.isLoading = false
        } withCancel: { error in
            self.errorMessage = ErrorMessage(message: error.localizedDescription)
            self.isLoading = false
        }
    }
}
