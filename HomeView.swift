//
//  HomeView.swift
//  fdkindMeal
//
//  Created by Admin on 2024-11-28.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct HomeView: View {
    var body: some View {
        VStack{
            Text("Welcome to home page : ")
                .font(.largeTitle)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .padding()
            Text("Logged by : \(userEmail)")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .padding()
            
            Button(action: signOut){
                Text("Sing OUT")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 240 , height: 60)
                    .background(Color.red)
                    .cornerRadius(15.0)
            }
        }
    }
    private func signOut(){
        do {
            try Auth.auth().signOut()
            ContentView()
        }
           catch { print("already logged out") }
        
    }
