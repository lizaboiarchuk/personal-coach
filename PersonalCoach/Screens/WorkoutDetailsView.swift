//
//  WorkoutDetailsView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 29.03.2023.
//

import SwiftUI

struct  WorkoutDetailsView: View {
    
    @State private var showCameraView = false
    
    let workout: WorkoutPreview
    let delegate: DownloaderDelegate


    var body: some View {
        
        ZStack {
            
            Color("ColorGrey")
                .ignoresSafeArea(.all, edges: .all)
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    CoverImageView(image: workout.coverImage)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.9)
                    .clipped()
                    .overlay(
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    HStack(spacing: 5) {
                                        Button(action: {
                                        }) {
                                            Image(systemName: "arrow.down.circle.fill")
                                                .font(.system(size: 44))
                                                .background(Color.white)
                                                .clipShape(Circle())
                                            
                                        }
                                        Button(action: {
                                            showCameraView = true
                                        }) {
                                            Image(systemName: "play.circle.fill")
                                                .font(.system(size: 44))
                                                .background(Color.white)
                                                .clipShape(Circle())
                                        }
                                        NavigationLink(destination: PoseDetectionView(), isActive: $showCameraView) {
                                            EmptyView()
                                        }
                                        .hidden()
                                        
                                        
                                        
                                    } //: HSTACK
                                    .padding()
                                } //: HSTACK
                            } //: VSTACK
                        )
                    
                    VStack(alignment: .leading, spacing: 5) {
                        
                        Text(workout.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color("ColorDarkGreen"))
                        
                        
                        Text("Author: \(workout.author)")
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
                            Text(workout.description)
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

//struct WorkoutDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
////        WorkoutDetailsView(itemIndex: 1,
////                           workoutTitle: "Light morning workout",
////                           workoutAuthor: "Madfit")
//    }
//}
