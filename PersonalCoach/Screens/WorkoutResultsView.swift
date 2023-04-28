//
//  WorkoutResultsView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 28.04.2023.
//

import SwiftUI

struct WorkoutResultsView: View {
    
    var finalScore: String
    var onDismiss: (() -> Void)?
    
    @Environment(\.presentationMode) var presentationMode
    
    
    @State private var textAnimating = false
    @State private var imageAnimating = false
    @State private var showTabBar = false
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                
                Color("ColorGrey")
                    .ignoresSafeArea(.all, edges: .all)
                
                VStack {
                    Spacer()
                    VStack {
                        Text("Great Job! You rocked that✌🏻🚀\n")
                        Text("Your score for passed workout is...\n\(finalScore)")
                            .font(.title3)
                            .fontWeight(.ultraLight)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    
                    }
                    .animation(.easeOut(duration: 1))
                    
                    Spacer()
                    Button(action: {
                        showTabBar = true
                        onDismiss?()
                        withAnimation {
                        }
                    }) {
                        Text("Back to library")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.light)
                            .padding(.horizontal, 30)
                            .foregroundColor(Color("ColorGreen"))
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    .tint(Color("ColorLightGrey"))

      
                    Spacer()
                    Image("character-2")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 400)
                        .rotationEffect(Angle.degrees(imageAnimating ? 20 : 0), anchor: .center)
                        .scaleEffect(imageAnimating ? 1.2 : 1.0)
                        .onAppear() {
                            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: true)) {
                                self.imageAnimating = true
                            }
                        }

                }

            }
        }
        .toolbar(showTabBar ? .visible : .hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)

    }
}




struct WorkoutResultsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutResultsView(finalScore: "100%")
    }
}
