//
//  OnboardingView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 28.03.2023.
//

import SwiftUI

struct OnboardingView: View {
    
    @AppStorage("onboarding") var isOnboardingViewActive: Bool = true

    @State private var buttonWidth: Double = UIScreen.main.bounds.width - 80
    @State private var buttonOffset: CGFloat = 0
    @State private var isAnimating: Bool = false
    @State private var imageOffset: CGSize = .zero
    
    
    var body: some View {
        ZStack {
            Color("ColorGrey")
                .ignoresSafeArea(.all, edges: .all)
            
            VStack(spacing: 20) {
                // MARK: - HEADER
                
                Spacer()
                
                VStack(spacing: 0) {
                    Text("Empower.")
                        .font(.system(size: 50))
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                        .padding(.vertical, 10)
                
                    Text("""
                    Revive your fitness routine
                    with a personal coach.
                    """)
                        .font(.title3)
                        .fontWeight(.ultraLight)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                       
                } //: HEADER
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : -40)
                .animation(.easeOut(duration: 1), value: isAnimating)
                
                // MARK: - CENTER
                
                ZStack {
                    
                    CircleGroupView(ShapeColor: Color("ColorLightGrey"), ShapeOpacity: 0.5, ShapeOpacityInner: 0.9)
                        .offset(x: imageOffset.width * -1)
                        .blur(radius: abs(imageOffset.width / 5))
                        .animation(.easeOut(duration: 1), value: imageOffset)
                    
                    Image("character-1")
                        .resizable()
                        .scaledToFit()
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeOut(duration: 1), value: isAnimating)
                        .offset(x: imageOffset.width * 1.2, y: 0)
                        .rotationEffect(.degrees(Double(imageOffset.width / 20)))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    if abs(imageOffset.width) <= 150 {
                                        imageOffset = gesture.translation
                                    }
                                }
                                .onEnded { _ in
                                    imageOffset = .zero
                                }
                        ) //: GESTURE
                        .animation(.easeOut(duration: 1), value: imageOffset)
                } //: CENTER
                
                Spacer()

                // MARK: - FOOTER
                
                ZStack {
                    Capsule()
                        .fill(Color("ColorLightGrey").opacity(0.9))
                    
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .padding(8)
                    
                    Text("Get Started")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.ultraLight)
                        .foregroundColor(.black)
                        .offset(x: 20)
                    
                    // 3. Capsule
                    HStack {
                        Capsule()
                            .fill(Color("ColorGreen"))
                            .frame(width: buttonOffset + 80)
                        Spacer()
                    }
                    
                    // 4. Circle draggable
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color("ColorGreen"))
                            Circle()
                                .fill(.black.opacity(0.15))
                                .padding(8)
                            Image(systemName: "chevron.right.2")
                                .font(.system(size: 24, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80, alignment: .center)
                        .offset(x: buttonOffset )
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    if gesture.translation.width > 0  && buttonOffset <= buttonWidth - 80 {
                                        buttonOffset = gesture.translation.width
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation {
                                        if buttonOffset > buttonWidth / 2 {
                                            buttonOffset = buttonWidth - 80
                                            isOnboardingViewActive = false
                                        }
                                        else {
                                            buttonOffset = 0
                                        }
                                    }
                                }
                        ) //: GESTURE
                        
                        Spacer()
                    } //: HSTACK
                } //: FOOTER
                .frame(width: buttonWidth, height: 80, alignment: .center)
                .padding()
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 40)
                .animation(.easeOut(duration: 1), value: isAnimating)
                
                
            } //: VSTACK
        } //: STACK
        .onAppear(perform: {
            isAnimating = true
        })
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
