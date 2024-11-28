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
        ZStack {
            Color(red: 229/255, green: 255/255, blue: 192/255)
                .ignoresSafeArea()

            VStack {
                Image("Connecting Hearts Through Meals. (1)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.top, 20)

                VStack(spacing: 20) {
                    Text("Reset Password")
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

                    Button(action: resetPassword) {
                        Text("Send Reset Link")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }

                    if !message.isEmpty {
                        Text(message)
                            .foregroundColor(message == "Password reset email sent!" ? .green : .red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                .background(Color(red: 245/255, green: 255/255, blue: 250/255))
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal, 30)

                Spacer()
            }
            .padding()
        }
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
