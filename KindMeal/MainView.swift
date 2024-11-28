//
//  MainView.swift
//  KindMeal
//
//  Created by Nabeel Shajahan on 2024-10-30.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage

struct MainView: View {
    @State private var showingDonationForm = false
    @State private var navigateToEditProfile = false
    @State private var navigateToLoginView = false
    @State private var profileImageUrl: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 229/255, green: 255/255, blue: 192/255)
                    .ignoresSafeArea()

                VStack(spacing: 10) {
                    Text("Welcome to KindMeal")
                        .font(.custom("AvenirNext-Bold", size: 34))
                        .foregroundColor(Color(red: 22/255, green: 137/255, blue: 12/255)) // Equivalent to #16890C
                        .shadow(radius: 2)
                        .multilineTextAlignment(.center)
                        .padding(.top, 25)

                    Button(action: {
                        navigateToEditProfile = true
                    }) {
                        if let url = URL(string: profileImageUrl), !profileImageUrl.isEmpty {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            } placeholder: {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.blue)
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.top, 25)
                    .onAppear(perform: fetchProfileImage)

                    Spacer()

                    Button(action: {
                        showingDonationForm = true
                    }) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.white)
                            Text("Make a Donation")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal)

                    Image("Connecting Hearts Through Meals. (1)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 320, height: 320)
                        .padding(.vertical, 1)

                    NavigationLink(destination: DonationHistoryView()) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.white)
                            Text("View Donation History")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [Color.green, Color.teal], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .sheet(isPresented: $showingDonationForm) {
                    MakeDonationView()
                }
                .fullScreenCover(isPresented: $navigateToEditProfile) {
                    EditProfileView()
                }
                .fullScreenCover(isPresented: $navigateToLoginView) {
                    LoginView()
                }
            }
        }
    }

    private func fetchProfileImage() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")

        storageRef.downloadURL { url, error in
            if let error = error {
                print("Failed to fetch profile image: \(error.localizedDescription)")
                self.profileImageUrl = "" // No image available
            } else if let url = url {
                self.profileImageUrl = url.absoluteString
            }
        }
    }

    private func logoutUser() {
        do {
            try Auth.auth().signOut()
            navigateToLoginView = true
        } catch {
            print("Failed to log out: \(error.localizedDescription)")
        }
    }
}

#Preview {
    MainView()
}
