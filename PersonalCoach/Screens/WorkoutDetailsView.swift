//
//  WorkoutDetailsView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 29.03.2023.
//

import SwiftUI

struct  WorkoutDetailsView: View {
    
    @State private var showCameraView = false
    
    
    let itemIndex: Int
    let workoutTitle: String
    let workoutAuthor: String
    let workoutDescription: String = """
\tA light morning workout is the perfect way to kick-start your day and gently awaken your body. This routine focuses on low-impact exercises, incorporating gentle stretches and easy-to-follow movements that target all major muscle groups. Begin with a brief warm-up to increase blood flow and loosen up the muscles. \n\tFollow this with a combination of dynamic stretches, bodyweight exercises, and balance training to improve flexibility and overall body strength. Aim to spend 15-20 minutes on this routine, giving your body the chance to gradually awaken and prepare for the day ahead. Remember to listen to your body, and modify any movements as needed to accommodate your personal fitness level. Finish off your session with a cool-down sequence, including deep breathing exercises and static stretches, to leave you feeling refreshed and energized for the day ahead.
"""
    let workoutImage: String = "sample-icon.png"
    
    var body: some View {
        
        ZStack {
            Color("ColorGrey")
                .ignoresSafeArea(.all, edges: .all)
            
            ScrollView {

                VStack(alignment: .leading, spacing: 10) {
                    
                    if let uiImage = UIImage(named: workoutImage) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
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
                    }
                    else { Text("Image not found") }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        
                        Text(workoutTitle)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color("ColorDarkGreen"))
                            
                        
                        Text("Author: \(workoutAuthor)")
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
                            Text(workoutDescription)
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

struct WorkoutDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDetailsView(itemIndex: 1,
                           workoutTitle: "Light morning workout",
                           workoutAuthor: "Madfit")
    }
}
