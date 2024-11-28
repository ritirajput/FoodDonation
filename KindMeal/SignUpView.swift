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
            // Background color
            Color(red: 229/255, green: 255/255, blue: 192/255)
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    // Logo
                    Image("Connecting Hearts Through Meals. (1)") // Replace with the correct logo name in Assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .padding(.top, 20)
                    
                    // Title
                    Text("Create Your Account")
                        .font(.title)
                        .bold()
                        .foregroundColor(.green)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    
                    // Username Field
                    customInputField(title: "Username", placeholder: "Enter your username", text: $username)
                    
                    // Email Field
                    customInputField(title: "Email", placeholder: "Enter your email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    // Password Field
                    customSecureField(title: "Password", placeholder: "Enter your password", text: $password)
                    
                    // Confirm Password Field
                    customSecureField(title: "Confirm Password", placeholder: "Re-enter your password", text: $confirmPassword)
                    
                    // Phone Number Field
                    customInputField(title: "Phone Number", placeholder: "Enter your phone number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    
                    // Gender Picker
                    VStack(alignment: .leading) {
                        Text("Gender")
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            .font(.headline)
                        Picker("Select Gender", selection: $selectedGender) {
                            ForEach(genders, id: \.self) { gender in
                                Text(gender)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.green, lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                    .padding(.top, 10)
                    
                    // Register Button
                    Button(action: signUpUser) {
                        Text("Register")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Error Message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    // Spacer for layout
                    Spacer()
                    
                    // Navigation Link to Login
                    NavigationLink(destination: LoginView(), isActive: $navigateToLoginView) {
                        Text("Already have an account? Log In")
                            .foregroundColor(.blue)
                            .font(.footnote)
                            .padding(.top, 20)
                    }
                }
                .padding()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    // Function to create reusable input fields
    private func customInputField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(.black)
                .padding(.horizontal)
                .font(.headline)
            TextField(placeholder, text: text)
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.green, lineWidth: 1)
                )
                .padding(.horizontal)
        }
        .padding(.top, 10)
    }
    
    // Function to create reusable secure fields
    private func customSecureField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(.black)
                .padding(.horizontal)
                .font(.headline)
            SecureField(placeholder, text: text)
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.green, lineWidth: 1)
                )
                .padding(.horizontal)
        }
        .padding(.top, 10)
    }
    
    // Sign-Up Functionality
    private func signUpUser() {
        // Validate input fields
        guard !username.isEmpty else {
            errorMessage = "Username is required"
            showAlert = true
            return
        }
        guard !email.isEmpty else {
            errorMessage = "Email is required"
            showAlert = true
            return
        }
        guard email.isValidEmail() else {
            errorMessage = "Invalid email format. Please enter a valid email."
            showAlert = true
            return
        }
        guard !password.isEmpty else {
            errorMessage = "Password is required"
            showAlert = true
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showAlert = true
            return
        }
        guard !phoneNumber.isEmpty else {
            errorMessage = "Phone number is required"
            showAlert = true
            return
        }
        guard phoneNumber.isValidPhone() else {
            errorMessage = "Invalid phone number. Must be 10 digits."
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
        let emailFormat = "(?:[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64})"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }

    func isValidPhone() -> Bool {
        let phoneRegex = "^[0-9]{10}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: self)
    }
}

#Preview {
    SignUpView()
}
