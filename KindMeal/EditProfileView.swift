//
//  EditProfileView.swift
//  KindMeal
//
//  Created by Nabeel Shajahan on 2024-11-25.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showImagePicker = false
    @State private var inputImage: UIImage? = nil
    @State private var username = ""
    @State private var phoneNumber = ""
    @State private var email = Auth.auth().currentUser?.email ?? ""
    @State private var profileImageUrl = ""
    @State private var phoneNumberError: String?
    @State private var errorMessage = ""
    @State private var showAlert = false
    @State private var navigateToMainPage = false
    @State private var navigateToLoginView = false

    private let databaseRef = Database.database().reference()
    private let storageRef = Storage.storage().reference()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 229/255, green: 255/255, blue: 192/255)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        if let inputImage = inputImage {
                            Image(uiImage: inputImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                .shadow(radius: 5)
                        } else if !profileImageUrl.isEmpty {
                            AsyncImage(url: URL(string: profileImageUrl)) { image in
                                image.resizable()
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .shadow(radius: 5)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                .shadow(radius: 5)
                        }
                    }
                    .sheet(isPresented: $showImagePicker, onDismiss: processImage) {
                        ImagePicker(image: $inputImage)
                    }

                    Text("Tap to change profile picture")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    VStack(spacing: 16) {
                        inputField(title: "Username", text: $username, placeholder: "Enter your username")

                        inputField(title: "Phone Number", text: $phoneNumber, placeholder: "Enter your phone number", keyboardType: .phonePad)
                            .onChange(of: phoneNumber) { newValue in
                                phoneNumberError = validatePhoneNumber(newValue)
                            }
                        if let phoneNumberError = phoneNumberError {
                            Text(phoneNumberError)
                                .foregroundColor(.red)
                                .font(.caption)
                        }

                        TextField("Email", text: $email)
                            .disabled(true)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal)

                    Spacer()

                    Button(action: saveProfile) {
                        Text("Save Changes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)

                    Button(action: logoutUser) {
                        Text("Logout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)

                    NavigationLink(destination: MainView(), isActive: $navigateToMainPage) {
                        EmptyView()
                    }
                    NavigationLink(destination: LoginView(), isActive: $navigateToLoginView) {
                        EmptyView()
                    }
                }
                .padding()
                .navigationTitle("Edit Profile")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                        }
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
                .onAppear(perform: fetchUserData)
            }
        }
    }

    private func processImage() {
        guard let selectedImage = inputImage else {
            return
        }
        uploadProfileImage(selectedImage) { url in
            guard let url = url else {
                self.errorMessage = "Failed to upload profile image."
                self.showAlert = true
                return
            }
            self.profileImageUrl = url.absoluteString
        }
    }

    private func inputField(title: String, text: Binding<String>, placeholder: String, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color(red: 22/255, green: 137/255, blue: 12/255)) // Matching theme
            TextField(placeholder, text: text)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .keyboardType(keyboardType)
        }
    }

    private func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        databaseRef.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: Any] else { return }
            self.username = data["username"] as? String ?? ""
            self.phoneNumber = data["phoneNumber"] as? String ?? ""
            self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        }
    }

    private func saveProfile() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated."
            self.showAlert = true
            return
        }

        var userData: [String: Any] = [
            "username": username,
            "phoneNumber": phoneNumber
        ]

        if let inputImage = inputImage {
            uploadProfileImage(inputImage) { url in
                guard let url = url else {
                    self.errorMessage = "Failed to upload profile image."
                    self.showAlert = true
                    return
                }

                userData["profileImageUrl"] = url.absoluteString
                self.updateUserData(userId: userId, data: userData)
            }
        } else {
            updateUserData(userId: userId, data: userData)
        }
    }

    private func updateUserData(userId: String, data: [String: Any]) {
        databaseRef.child("users").child(userId).updateChildValues(data) { error, _ in
            if let error = error {
                self.errorMessage = "Failed to save profile data: \(error.localizedDescription)"
                self.showAlert = true
            } else {
                self.navigateToMainPage = true
            }
        }
    }

    private func uploadProfileImage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let userId = Auth.auth().currentUser?.uid ?? UUID().uuidString
        let storagePath = storageRef.child("profile_images/\(userId).jpg")

        storagePath.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                self.errorMessage = "Failed to upload image: \(error.localizedDescription)"
                self.showAlert = true
                completion(nil)
                return
            }

            storagePath.downloadURL { url, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch image URL: \(error.localizedDescription)"
                    self.showAlert = true
                    completion(nil)
                }
                completion(url)
            }
        }
    }

    private func logoutUser() {
        do {
            try Auth.auth().signOut()
            navigateToLoginView = true
        } catch {
            errorMessage = "Failed to log out: \(error.localizedDescription)"
            showAlert = true
        }
    }

    private func validatePhoneNumber(_ phoneNumber: String) -> String? {
        let phoneRegex = "^[0-9+\\-() ]{10,15}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: phoneNumber) ? nil : "Invalid phone number"
    }
}
