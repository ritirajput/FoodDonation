//
//  splash_screen.swift
//  fdkindMeal
//
//  Created by Admin on 2024-10-31.
//

import SwiftUI

struct splash_screen: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    var body: some View {
        VStack {
            VStack{
            Text("kindMeal")
                    .font(Font.custom("Baskerville-Bold",size: 30))
                    .foregroundColor(.black)
                    
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear{
                withAnimation(.easeIn(duration: 1.2)){
                    self.size = 0.9
                    self.opacity = 1.0
                }
            }
            
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                self.isActive = true
    }
}
        .padding()
    }
}

#Preview {
    splash_screen()
}
