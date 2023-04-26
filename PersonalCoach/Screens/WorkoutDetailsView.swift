//
//  WorkoutDetailsView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 29.03.2023.
//

import SwiftUI

struct ColoredButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(color)
            .clipShape(Circle())
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}



struct  WorkoutDetailsView: View {
    
    @State private var showCameraView = false
    @ObservedObject var viewModel: LibraryCellViewModel
        
    
    init(model: LibraryCellViewModel) {
        viewModel = model
    }
    
    var body: some View {
        
        ZStack {
            
            Color("ColorGrey")
                .ignoresSafeArea(.all, edges: .all)
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    CoverImageView(image: viewModel.workout.coverImage)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.9)
                        .clipped()
                        .overlay(
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    HStack(spacing: 5) {
                                        Button(action: {
                                            viewModel.downloadWorkout()
                                        }) {
                                            Image(systemName: viewModel.currentState == .downloaded ? "checkmark.circle" : "icloud.and.arrow.down")
                                                .font(.system(size: 44))
                                                .foregroundColor(Color.white)
                                        }
                                        .buttonStyle(ColoredButtonStyle(color: Color("ColorDarkGreen")))
                                        .disabled(viewModel.currentState == .downloaded)
                                        .onChange(of: viewModel.workout.isDownloaded) { newValue in
                                            // ...
                                        } //: DOWNLOAD BUTTON

                                        Button(action: {
                                            showCameraView = true
                                        }) {
                                            Image(systemName: "play.circle")
                                                .font(.system(size: 44))
                                                .foregroundColor(Color.white)
                                        }
                                        .buttonStyle(ColoredButtonStyle(color: Color("ColorDarkGreen")))

                                        NavigationLink(destination: PoseDetectionView(workout: viewModel.workout), isActive: $showCameraView) {
                                            EmptyView()
                                        } //: PLAY BUTTON
                                        .hidden()
                                    } //: HSTACK
                                    .padding()
                                } //: HSTACK
                            } //: VSTACK
                        )
                    
                    VStack(alignment: .leading, spacing: 5) {
                        
                        Text(viewModel.workout.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color("ColorDarkGreen"))
                        
                        
                        Text("Author: \(viewModel.workout.author)")
                            .font(.subheadline)
                            .fontWeight(.light)
                            .foregroundColor(.gray)
                            .padding(.bottom, 20)
                            .foregroundColor(.black)
                        
                        
                        VStack {
                            Text("Description")
                                .font(.body)
                                .fontWeight(.medium)
                                .padding(.top)
                                .foregroundColor(.black)
                            Text(viewModel.workout.description)
                                .font(.body)
                                .fontWeight(.ultraLight)
                                .padding(.top, 1)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                        } //: VSTACK
                    } //: VSTACK
                    .padding()
                    Spacer()
                    
                    Spacer()
                } //: VSTACK
                
            } //: SCROLLVIEW
            .edgesIgnoringSafeArea(.top)
            
        } //: ZTACK
        .tint(Color("ColorDarkGreen"))
    }
}
