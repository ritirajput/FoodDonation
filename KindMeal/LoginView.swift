//
//  LoginView.swift
//  KindMeal
//
//  Created by Nabeel Shajahan on 2024-10-30.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isAuthenticated = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 229/255, green: 255/255, blue: 192/255)
                    .ignoresSafeArea()

                VStack {
                    Image("Connecting Hearts Through Meals. (1)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(.top, 20)

                    VStack(spacing: 20) {
                        Text("Login")
                            .font(.title)
                            .bold()
                            .foregroundColor(Color(red: 34/255, green: 139/255, blue: 34/255))

                        TextField("Email", text: $email)
                            .padding()
                            .background(Color(red: 240/255, green: 255/255, blue: 240/255))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.green, lineWidth: 1)
                            )
                            .textInputAutocapitalization(.none)
                            .keyboardType(.emailAddress)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(red: 240/255, green: 255/255, blue: 240/255))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.green, lineWidth: 1)
                            )

                        Button(action: signIn) {
                            Text("Login")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                        }

                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }

                        NavigationLink("Forgot Password?", destination: ForgotPasswordView())
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color(red: 245/255, green: 255/255, blue: 250/255))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(.horizontal, 30)

                    Spacer()

                    NavigationLink(destination: SignUpView()) {
                        Text("Don't have an account? Sign Up")
                            .foregroundColor(.blue)
                            .font(.footnote)
                            .padding(.top, 20)
                    }
                }
                .padding()
            }
            .fullScreenCover(isPresented: $isAuthenticated) {
                MainView()
            }
        }
    }

    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.isAuthenticated = true
            }
        }
    }
}

#Preview {
    LoginView()
}
