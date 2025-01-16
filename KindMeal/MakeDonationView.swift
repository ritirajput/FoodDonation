//
//  MakeDonationView.swift
//  KindMeal
//
//  Created by Nabeel Shajahan on 2024-11-17.
//

import SwiftUI
import FirebaseDatabase
import MapKit
import CoreLocation

struct MakeDonationView: View {
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
                        Text("Make a Donation")
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

                        // Location Section
                        sectionTitleWithIcon(title: "Location", icon: "mappin.and.ellipse")
                        VStack {
                            HStack {
                                TextField("Search for location", text: $locationName)
                                    .padding()
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(10)
                                    .onChange(of: locationName) { _ in
                                        performLocationSearch()
                                    }

                                Button(action: performLocationSearch) {
                                    Image(systemName: "magnifyingglass")
                                        .padding()
                                        .background(Color.blue.opacity(0.8))
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal)

                            if !searchResults.isEmpty {
                                ScrollView {
                                    VStack(alignment: .leading) {
                                        ForEach(searchResults, id: \.self) { result in
                                            Button(action: {
                                                updateLocation(with: result)
                                            }) {
                                                Text(result.name ?? "Unknown location")
                                                    .padding()
                                                    .background(Color.white)
                                                    .cornerRadius(10)
                                                    .shadow(radius: 2)
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                                .frame(height: 150)
                            }

                            if let coordinate = locationCoordinate {
                                Text("Selected Location: \(locationName)")
                                    .foregroundColor(.black)
                                    .padding(.horizontal)
                            }

                            MapView(coordinate: $locationCoordinate)
                                .frame(height: 200)
                                .cornerRadius(10)
                                .padding()
                        }

                        // Contact Number
                        enhancedInputField(
                            title: "Contact Number",
                            icon: "phone.fill",
                            text: $contactNumber,
                            placeholder: "Enter your contact number",
                            keyboardType: .phonePad
                        )

                        // Confirm Donation Button
                        Button(action: submitDonation) {
                            Text("Confirm Donation")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)

                        // Discard Changes Button
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
        guard let locationCoordinate = locationCoordinate else {
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
            "location": ["latitude": locationCoordinate.latitude, "longitude": locationCoordinate.longitude],
            "timestamp": Int(Date().timeIntervalSince1970),
            "reservedBy": NSNull(),
            "closed": false
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

    private func performLocationSearch() {
        guard !locationName.isEmpty else { return }
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = locationName

        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let results = response?.mapItems {
                self.searchResults = results
            } else {
                self.searchResults = []
                errorMessage = "Failed to find location. Please try again."
                showAlert = true
            }
        }
    }

    private func updateLocation(with mapItem: MKMapItem) {
        locationCoordinate = mapItem.placemark.coordinate
        locationName = mapItem.name ?? "Unknown Location"
        searchResults = []
    }
}

// MapView Component
struct MapView: UIViewRepresentable {
    @Binding var coordinate: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        guard let coordinate = coordinate else { return }

        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        uiView.setRegion(region, animated: true)

        uiView.removeAnnotations(uiView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        uiView.addAnnotation(annotation)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let red = Double((rgbValue >> 16) & 0xFF) / 255.0
        let green = Double((rgbValue >> 8) & 0xFF) / 255.0
        let blue = Double(rgbValue & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
    }
}
