//
//  sign_in.swift
//  fdkindMeal
//
//  Created by Admin on 2024-11-28.
//

import SwiftUI

struct sign_in: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack{
            
Text("kindMeal")
.font(Font.custom("Baskerville-Bold",size: 30))
.foregroundColor(.black)
        TextField("Email",text: $email)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
        SecureField("Password",text: $password)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            Button("Forget password"){
                
            }.padding()
        Button("Sign In"){
            
        }.padding()
            
    }.padding()
    }
}

#Preview {
    sign_in()
}
