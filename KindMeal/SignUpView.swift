//
//  SignUpView.swift
//  KindMeal
//
//  Created by Nabeel Shajahan on 2024-10-30.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct SignUpView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var phoneNumber: String = ""
    @State private var selectedGender: String = "Select Gender"
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var navigateToLoginView: Bool = false

    private let genders = ["Male", "Female", "Other"]
    private var databaseRef: DatabaseReference = Database.database().reference()

    var body: some View {
        ZStack {
            Image("background_signup")
                .resizable()
                .scaledToFit()
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack {
                    Text("Create Your Account")
                        .font(.custom("roboto_serif_regular", size: 32))
                        .foregroundColor(.black)
                        .padding(.bottom, 20)

                    Text("Username")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    TextField("Enter your username", text: $username)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    Text("Email")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    TextField("Enter your email", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.horizontal)

                    Text("Password")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    SecureField("Enter your password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    Text("Confirm Password")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    SecureField("Re-enter your password", text: $confirmPassword)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    Text("Phone Number")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    TextField("Enter your phone number", text: $phoneNumber)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .keyboardType(.phonePad)
                        .padding(.horizontal)

                    Text("Gender")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    Picker("Select Gender", selection: $selectedGender) {
                        ForEach(genders, id: \.self) { gender in
                            Text(gender)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    Button(action: signUpUser) {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    Text(errorMessage).foregroundColor(.red)
                    Spacer()

                    NavigationLink(destination: LoginView(), isActive: $navigateToLoginView) {
                        EmptyView()
                    }
                }
                .padding()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func signUpUser() {
        // Validate input fields
        guard !username.isEmpty else {
            errorMessage = "Username is required"
            showAlert = true
            return
        }
        guard email.isValidEmail() else {
            errorMessage = "Invalid email format"
            showAlert = true
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showAlert = true
            return
        }
        guard phoneNumber.isValidPhone() else {
            errorMessage = "Invalid phone number"
            showAlert = true
            return
        }
        guard selectedGender != "Select Gender" else {
            errorMessage = "Please select a gender"
            showAlert = true
            return
        }

        // Create user with Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
                return
            }

            guard let uid = authResult?.user.uid else { return }

            // Prepare user data
            let userData: [String: Any] = [
                "username": username,
                "email": email,
                "phoneNumber": phoneNumber,
                "gender": selectedGender,
                "role": "user"
            ]

            // Save user data to Firebase Realtime Database
            databaseRef.child("users").child(uid).setValue(userData) { error, _ in
                if let error = error {
                    errorMessage = "Failed to save user data: \(error.localizedDescription)"
                    showAlert = true
                } else {
                    errorMessage = "Registration successful!"
                    navigateToLoginView = true
                }
            }
        }
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }

    func isValidPhone() -> Bool {
        let phoneRegex = "^[0-9]{10}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: self)
    }
}

