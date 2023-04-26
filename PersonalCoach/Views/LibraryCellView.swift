//
//  LibraryCellView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 28.03.2023.
//

import SwiftUI

struct LibraryCellView: View {
    @ObservedObject var viewModel: LibraryCellViewModel
    
    init(model: LibraryCellViewModel) {
        viewModel = model
    }
    
    var body: some View {
        
        HStack(alignment: .center) {
            
            CoverImageView(image: viewModel.workout.coverImage)
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.workout.name)
                    .font(.headline)
                    .fontWeight(.light)
                    .foregroundColor(.black)
                
                Text("Author: \(viewModel.workout.author)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } //: VSTACK
            .padding(.leading)
            
            Spacer()
            
            // MARK: BUTTONS
            HStack(spacing: 10) {
                
                ZStack {
                    if viewModel.currentState == .downloading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.darkGray)))
                    }
                    else {
                        
                        Button(action: {
                            viewModel.downloadWorkout()
                        }) {
                            Image(systemName: viewModel.currentState == .downloaded ? "checkmark.circle.fill" : "icloud.and.arrow.down")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .tint(Color("ColorDarkGreen"))
                            
                        }
                        .disabled(viewModel.currentState == .downloaded)
                        .onChange(of: viewModel.workout.isDownloaded) { newValue in
                        }
                    }
                }
                
                Button(action: {
                    viewModel.navigateToPoseDetection = true
                }) {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .tint(Color("ColorDarkGreen"))
                    NavigationLink(destination: PoseDetectionView(workout: viewModel.workout), isActive: $viewModel.navigateToPoseDetection) {
                        EmptyView()
                    }
                    .hidden()
                }
            } //: HSTACK
        }
        .padding(.vertical)
        .padding(.horizontal)
        .background(Color("ColorLightGrey2"))
        .cornerRadius(10)
    }
}
