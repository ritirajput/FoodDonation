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
            VStack {
                Text("Login to KindMeal")
                    .font(.title)
                    .padding()

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: signIn) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 20)

                Text(errorMessage).foregroundColor(.red)
                
                NavigationLink("Forgot Password?", destination: ForgotPasswordView())
                    .padding(.top, 10)

                Spacer()

                NavigationLink(destination: SignUpView()) {
                    Text("Don't have an account? Sign Up")
                }
            }
            .padding()
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
