//
//  signup.swift
//  fdkindMeal
//
//  Created by Admin on 2024-11-28.
//

import SwiftUI

struct signup: View {
    @Binding var isPresented: Bool
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    var body: some View {
        VStack{
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .padding(.bottom,40)
            TextField("Email",text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal,40)
            SecureField("Password",text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal,40)
            Button("Sign up"){
                
            }.padding()
            Button(action : {
                isPresented = false
            }){
                Text("Back")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
                    .frame(width: 240 , height: 60)
                    .background(Color.white)
                    .cornerRadius(15.0)
                    .overlay(RoundedRectangle(cornerRadius: 15.0)
                        .stroke(Color.red,lineWidth:2))
            }
        }
        .padding()
        
        .alert(isPresented: $isShowingAlert){
            Alert(title: Text("Error"), message: Text(alertMessage),dismissButton: .default(Text("OK")))
        }
    }
    
    
}

struct SignUpView_Preview : PreviewProvider{
    @State static var isPresented = true
    static var previews: some View{
        signup(isPresented: $isPresented)
    }
}
