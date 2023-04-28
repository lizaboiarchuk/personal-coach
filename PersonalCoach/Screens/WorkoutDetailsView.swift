//
//  WorkoutDetailsView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 29.03.2023.
//

import SwiftUI


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
                                            Image(systemName: "trash.circle.fill")
                                                .font(.system(size: 44))
                                                .foregroundColor(Color("ColorGrey"))
                                        }
                                        .clipShape(Circle())
                                        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 20)
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
                                                Image(systemName: viewModel.currentState == .downloaded ? "checkmark.circle.fill" : "arrow.down.circle.fill")
                                                    .font(.system(size: 44))
                                                    .foregroundColor(Color("ColorGrey"))
                                            }
                                            .clipShape(Circle())
                                            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 20)
                                            .disabled(viewModel.currentState == .downloaded || viewModel.currentState == .downloading)
                                            .onChange(of: viewModel.workout.isDownloaded) { newValue in
                                            } //: DOWNLOAD BUTTON
                                        }
                                        Button(action: {
                                            viewModel.navigateToPoseDetection = true
                                        }) {
                                            Image(systemName: "play.circle.fill")
                                                .font(.system(size: 44))
                                                .foregroundColor(Color("ColorGrey"))
                                        }
                                        .clipShape(Circle())
                                        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 20)
                                        .background(
                                            NavigationLink(destination: LazyView(PoseDetectionView(workout: viewModel.workout, onDismiss: {
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
                            .fontWeight(.light)
                            .foregroundColor(Color("ColorDarkGreen"))
                        
                        
                        Text("Author: \(viewModel.workout.author)")
                            .font(.subheadline)
                            .fontWeight(.light)
                            .foregroundColor(.gray)
                            .padding(.bottom, 5)
                            .foregroundColor(.black)
                        
                        Text("Tags: " + viewModel.workout.tags.joined(separator: ", "))
                            .font(.subheadline)
                            .fontWeight(.light)
                            .foregroundColor(.gray)
                            .padding(.bottom, 20)
                            .foregroundColor(.black)
                        
                        
                        VStack {
                            Text("Description")
                                .font(.body)
                                .fontWeight(.light)
                                .padding(.top)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(viewModel.workout.description)
                                .font(.body)
                                .fontWeight(.ultraLight)
                                .padding(.top, 1)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.black)
                        } //: VSTACK
                    } //: VSTACK
                    .padding()
                    Spacer()
                    
                    Spacer()
                } //: VSTACK
                
            } //: SCROLLVIEW
            .edgesIgnoringSafeArea(.top)
            .background(Color("ColorGrey")) // Set the background color explicitly
            .navigationBarTitleDisplayMode(.inline)
            //            .navigationBarHidden(true)
            
        } //: ZTACK
        .tint(Color("ColorDarkGreen"))    }
}



struct WorkoutDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let wp = WorkoutPreview(workout: Workout(
            description: "  A light morning workout is the perfect way to kick-start your day and gently awaken your body. This routine focuses on low-impact exercises, incorporating gentle stretches and easy-to-follow movements that target all major muscle groups. Begin with a brief warm-up to increase blood flow and loosen up the muscles. \n\tFollow this with a combination of dynamic stretches, bodyweight exercises, and balance training to improve flexibility and overall body strength. Aim to spend 15-20 minutes on this routine, giving your body the chance to gradually awaken and prepare for the day ahead. Remember to listen to your body, and modify any movements as needed to accommodate your personal fitness level. Finish off your session with a cool-down sequence, including deep breathing exercises and static stretches, to leave you feeling refreshed and energized for the day ahead.",
            tags: ["morming", "thigs", "light"],
            cover: "",
            positions: "",
            author: "author",
            video: "",
            name: "Workoooooout",
            uid: ""))
  
        WorkoutDetailsView(model: LibraryCellViewModel(workout: wp, delegate: LibraryViewModel()))
    }
}
