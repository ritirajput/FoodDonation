//
//  ForgotPasswordView.swift
//  KindMeal
//
//  Created by Nabeel Shajahan on 2024-10-30.
//

import SwiftUI
import Firebase
import FirebaseAuth


struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var message = ""

    var body: some View {
        VStack {
            Text("Reset Password")
                .font(.title)
                .padding()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal)

            Button(action: resetPassword) {
                Text("Send Reset Link")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.top, 20)

            Text(message)
                .foregroundColor(.green)
                .padding()

            Spacer()
        }
        .padding()
    }

    func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.message = error.localizedDescription
            } else {
                self.message = "Password reset email sent!"
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
}
