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



struct WorkoutDetailsView: View {
    
    @ObservedObject var viewModel: LibraryCellViewModel
    
    init(model: LibraryCellViewModel) {
        viewModel = model    }
    
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
                                    
                                    if viewModel.currentState == .downloaded {
                                        Button(action: {
                                            viewModel.deleteWorkout()
                                        }) {
                                            Image(systemName: "trash.circle")
                                                .font(.system(size: 44))
                                                .foregroundColor(Color.white)
                                        }
                                        .buttonStyle(ColoredButtonStyle(color: Color("ColorDarkGreen")))
                                        .padding(.leading) //: DELETE BUTTON
                                    }
                                    else {
                                        EmptyView()
                                            .frame(width: 44, height: 44)
                                            .padding(.leading)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 5) {
                                        VStack {
                                            if viewModel.currentState == .downloading {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle())
                                                    .foregroundColor(.white)
                                            }
                                            Button(action: {
                                                viewModel.downloadWorkout()
                                            }) {
                                                Image(systemName: viewModel.currentState == .downloaded ? "checkmark.circle" : "arrow.down.circle")
                                                    .font(.system(size: 44))
                                                    .foregroundColor(Color.white)
                                            }
                                            .buttonStyle(ColoredButtonStyle(color: Color("ColorDarkGreen")))
                                            .disabled(viewModel.currentState == .downloaded || viewModel.currentState == .downloading)
                                            .onChange(of: viewModel.workout.isDownloaded) { newValue in
                                            } //: DOWNLOAD BUTTON
                                        }
                                        Button(action: {
                                            viewModel.navigateToPoseDetection = true
                                        }) {
                                            Image(systemName: "play.circle")
                                                .font(.system(size: 44))
                                                .foregroundColor(Color.white)
                                        }
                                        .buttonStyle(ColoredButtonStyle(color: Color("ColorDarkGreen")))
                                        .background(
                                            NavigationLink(destination: LazyView(PoseDetectionView(workout: viewModel.workout,
                                                                                                    
                                                                                                    onDismiss: {
                                                viewModel.navigateToPoseDetection = false
                                                self.toolbar(.visible, for: .tabBar)
                                            })), isActive: $viewModel.navigateToPoseDetection) {
                                                EmptyView()
                                            }
                                        )
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
        .tint(Color("ColorDarkGreen"))    }
}
