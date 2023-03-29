//
//  HomeView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 28.03.2023.
//

import SwiftUI

struct HomeView: View {
    
    @AppStorage("onboarding") var isOnboardingViewActive: Bool = false
    @State private var isNavigationLinkActive = false
    @State private var isAnimating: Bool = false
    
    var body: some View {
        
        NavigationView {
            ZStack {
                // Add the image as the bottom-most layer
                Color("ColorGrey")
                    .ignoresSafeArea(.all, edges: .all)
                Image("start-background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .offset(y: isAnimating ? 35 : -35)
                    .animation(
                        Animation
                            .easeInOut(duration: 4)
                            .repeatForever()
                        ,value: isAnimating
                    )
                
                // Add other views or elements on top of the image
                VStack {
                    Text("""
                Get your own AI-powered personal
                workout coach with our app!
                """)
                    .font(.title3)
                    .fontWeight(.ultraLight)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 30)
                    
                    // MARK: - FOOTER
                                        
                    Button(action: {
                        withAnimation {
                            isNavigationLinkActive = true
                        }
                    }) {
                        Text("Let's go!")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.light)
                            .padding(.horizontal, 30)
                            .foregroundColor(Color("ColorGreen"))
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    .tint(Color("ColorLightGrey"))
                    
                    NavigationLink(destination: LibraryView(), isActive: $isNavigationLinkActive) {
                        EmptyView()
                    }
                    .hidden()
                    
                } //: VSTACK
            } //: ZSTACK
            .onAppear(perform: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    isAnimating = true
                })
            })
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
