//
//  ContentView.swift
//  fdkindMeal
//
//  Created by Admin on 2024-10-31.
//

import SwiftUI

struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isShowingSignUP = false
    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    @State private var isAuthenticated = false
    @State private var userEmail = ""
    
    var body: some View {
        NavigationView{
           
                VStack{
                    Text("Kind Meal")
                        .font(.largeTitle)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .padding(.bottom, 40)
                    TextField("Email",text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal,40)
                    SecureField("Password",text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal,40)
                        .padding(.vertical, 20)
                   
                    
                    Button(action : {
                        isShowingSignUP = true
                    }){
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                            .frame(width: 240 , height: 60)
                            .background(Color.white)
                            .cornerRadius(15.0)
                            .overlay(RoundedRectangle(cornerRadius: 15.0)
                                .stroke(Color.blue,lineWidth:2))
                    }
                }
                .padding()
                .alert(isPresented: $isShowingAlert){
                    Alert(title: Text("Error"), message: Text(alertMessage),dismissButton: .default(Text("OK")))
                }
                .sheet(isPresented: $isShowingSignUP){
                    signup(isPresented: $isShowingSignUP)
                }
                
            }//elsefinish
        }
    }
    
   
#Preview {
    ContentView()
}
