//
//  MakeDonationView.swift
//  KindMeal
//
//  Created by Nabeel Shajahan on 2024-11-17.
//

import SwiftUI
import FirebaseDatabase

struct MakeDonationView: View {
    @State private var mealType: String = "Veg"
    @State private var quantityType: String = "Small"
    @State private var selectedQuantity: Int = 1
    @State private var description: String = ""
    @State private var donationName: String = ""
    @State private var contactNumber: String = ""
    @State private var location: String = "Location will be added later"
    @State private var showToast: Bool = false
    @State private var navigateToMainView: Bool = false
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""

    private var databaseRef: DatabaseReference = Database.database().reference()
    private let mealTypes = ["Veg", "Non-Veg"]
    private let quantityTypes = ["Small", "Medium", "Large"]

    var body: some View {
        NavigationStack {
            ZStack {
                Image("background_donation")
                    .resizable()
                    .scaledToFit()
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 20) {
                        Text("Make a Donation")
                            .font(.custom("roboto_serif_regular", size: 32))
                            .foregroundColor(.black)
                            .bold()
                            .padding(.bottom, 20)

                        inputField(title: "Description", text: $description, placeholder: "Describe the meal contents")

                        inputField(title: "Donation Name", text: $donationName, placeholder: "Enter a name for the donation")

                        HStack {
                            Image(systemName: "leaf.circle")
                                .foregroundColor(.black)
                            Text("Meal Type")
                                .foregroundColor(.black)
                                .bold()
                                .italic()
                        }
                        Picker("Select Meal Type", selection: $mealType) {
                            ForEach(mealTypes, id: \.self) { type in
                                Text(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()

                        HStack {
                            Image(systemName: "tray.circle")
                                .foregroundColor(.black)
                            Text("Quantity Type")
                                .foregroundColor(.black)
                                .bold()
                                .italic()
                        }
                        Picker("Select Quantity Type", selection: $quantityType) {
                            ForEach(quantityTypes, id: \.self) { size in
                                Text(size)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()

                        Stepper(value: $selectedQuantity, in: 1...10) {
                            Text("Quantity: \(selectedQuantity)")
                                .foregroundColor(.black)
                                .bold()
                        }
                        .padding()

                        Text("Location (Coming Soon)")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        Text(location)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .disabled(true)

                        inputField(title: "Contact Number", text: $contactNumber, placeholder: "Enter your contact number", keyboardType: .phonePad)

                        Button(action: submitDonation) {
                            Text("Confirm Donation")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)

                        Button(action: discardChanges) {
                            Text("Discard Changes")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        Spacer()
                    }
                    .padding()
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
                .fullScreenCover(isPresented: $navigateToMainView) {
                    MainView()
                }

                if showToast {
                    withAnimation {
                        Text("Donation submitted successfully!")
                            .font(.headline)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                            .transition(.slide)
                    }
                }
            }
        }
    }

    private func inputField(title: String, text: Binding<String>, placeholder: String, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "pencil.circle")
                    .foregroundColor(.green)
                Text(title)
                    .foregroundColor(.black)
                    .bold()
                    .italic()
            }
            TextField(placeholder, text: text)
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
                .keyboardType(keyboardType)
        }
        .padding(.horizontal)
    }

    private func submitDonation() {
        guard !description.isEmpty else {
            errorMessage = "Description is required."
            showAlert = true
            return
        }
        guard !donationName.isEmpty else {
            errorMessage = "Donation name is required."
            showAlert = true
            return
        }
        guard !contactNumber.isEmpty else {
            errorMessage = "Contact number is required."
            showAlert = true
            return
        }
        guard !location.isEmpty else {
            errorMessage = "Location is required."
            showAlert = true
            return
        }

        let donationData: [String: Any] = [
            "description": description,
            "donationName": donationName,
            "mealType": mealType,
            "quantityType": quantityType,
            "quantity": selectedQuantity,
            "contactNumber": contactNumber,
            "location": location,
            "timestamp": Int(Date().timeIntervalSince1970)
        ]

        databaseRef.child("donations").childByAutoId().setValue(donationData) { error, _ in
            if let error = error {
                errorMessage = "Failed to submit donation: \(error.localizedDescription)"
                showAlert = true
            } else {
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showToast = false
                    navigateToMainView = true
                }
            }
        }
    }

    private func discardChanges() {
        navigateToMainView = true
    }
}

#Preview {
    MakeDonationView()
}

