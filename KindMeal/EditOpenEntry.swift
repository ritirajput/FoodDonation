//
//  EditOpenEntry.swift
//  KindMeal
//
//  Created by Admin on 2025-01-08.
//

import SwiftUI
import FirebaseDatabase
import MapKit
import CoreLocation

struct EditOpenEntry: View {
    @State private var mealType: String = "Veg"
    @State private var quantityType: String = "Small"
    @State private var selectedQuantity: Int = 1
    @State private var description: String = ""
    @State private var donationName: String = ""
    @State private var contactNumber: String = ""
    @State private var locationName: String = ""
    @State private var locationCoordinate: CLLocationCoordinate2D? = nil
    @State private var searchResults: [MKMapItem] = []
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
                Color(red: 229/255, green: 255/255, blue: 192/255)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        Text("Edit Your Donation")
                            .font(.custom("AvenirNext-Bold", size: 32))
                            .foregroundColor(.black)
                            .bold()
                            .padding(.bottom, 20)
                        
                        // Description
                        enhancedInputField(
                            title: "Description",
                            icon: "doc.text.fill",
                            text: $description,
                            placeholder: "Describe the meal contents"
                        )
                        
                        // Donation Name
                        enhancedInputField(
                            title: "Donation Name",
                            icon: "gift.fill",
                            text: $donationName,
                            placeholder: "Enter a name for the donation"
                        )
                        
                        // Meal Type
                        sectionTitleWithIcon(title: "Meal Type", icon: "leaf.fill")
                        Picker("Select Meal Type", selection: $mealType) {
                            ForEach(mealTypes, id: \.self) { type in
                                Text(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        
                        // Quantity Type
                        sectionTitleWithIcon(title: "Quantity Type", icon: "tray.2.fill")
                        Picker("Select Quantity Type", selection: $quantityType) {
                            ForEach(quantityTypes, id: \.self) { size in
                                Text(size)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        
                        // Quantity Stepper
                        Stepper(value: $selectedQuantity, in: 1...10) {
                            Text("Quantity: \(selectedQuantity)")
                                .foregroundColor(.black)
                                .bold()
                        }
                        .padding()
                        
                        //Contact Number
                        enhancedInputField(
                            title: "Contact Number",
                            icon: "phone.fill",
                            text: $contactNumber,
                            placeholder: "Enter your contact number",
                            keyboardType: .phonePad
                        )
                        
                        //Confirm Donation Button
                        Button(action: updateDonation) {
                            Text("Update Donation")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        //Discard Changes Button
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
    
    private func enhancedInputField(title: String, icon: String, text: Binding<String>, placeholder: String, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                    .bold()
            }
            TextField(placeholder, text: text)
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
                .keyboardType(keyboardType)
        }
        .padding(.horizontal)
    }
    
    private func sectionTitleWithIcon(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .bold()
        }
        .padding(.horizontal)
    }
    
    private func discardChanges() {
        navigateToMainView = true
    }
    
    private func updateDonation() {
        // guard !description.isEmpty else {
        //     errorMessage = "Description is empty."
        //     showAlert = true
        //     return
        // }
        // guard !donationName.isEmpty else {
        //     errorMessage = "Donation name is empty."
        //     showAlert = true
        //     return
        // }
        // guard !contactNumber.isEmpty else {
        //     errorMessage = "Contact number is empty."
        //     showAlert = true
        //     return
        // }
        
        
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
            navigateToMainView = true
        }
    }
}

            
               
     
