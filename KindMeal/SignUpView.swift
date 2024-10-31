//
//  SignUpView.swift
//  KindMeal
//
//  Created by Nabeel Shajahan on 2024-10-30.
//

import SwiftUI
import Firebase
import FirebaseAuth


struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            Text("Create an Account")
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

            Button(action: signUp) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.top, 20)

            Text(errorMessage).foregroundColor(.red)

            Spacer()
        }
        .padding()
    }

    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}


#Preview {
    SignUpView()
}
