//
//  LibraryCellView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 28.03.2023.
//

import SwiftUI

struct LibraryCellView: View {
    
    let workout: WorkoutPreview
    let delegate: DownloaderDelegate
    
    private enum wState {
        case notDownloaded
        case downloading
        case downloaded
    }
    
    @State private var currentState: wState = .notDownloaded
    
    var body: some View {
        
        HStack(alignment: .center) {
            
            CoverImageView(image: workout.coverImage)
            .frame(width: 60, height: 60) // Adjust the frame size as needed
        
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.headline)
                    .fontWeight(.light)
                    .foregroundColor(.black)

                Text("Author: \(workout.author)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } //: VSTACK
            .padding(.leading)

            Spacer()

            // MARK: BUTTONS
            HStack(spacing: 10) {
                
                ZStack {
                    if currentState == .downloading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.darkGray)))
                    }
                    else {
                        
                        Button(action: {
                            
                            self.currentState = .downloading
                            self.delegate.downloadWorkout(videoStoragePath: self.workout.video,
                                                          positionsStoragePath: self.workout.positions,
                                                          videoFileName: "\(workout.uid).mp4",
                                                          positionsFileName: "\(workout.uid).json") { localVideoPath, localPositionsPath in
                                if let lvp = localVideoPath, let lpp = localPositionsPath {
                                    self.workout.localVideoPath = lvp
                                    self.workout.localPositionsPath = lpp
                                    self.workout.isDownloaded = true
                                    self.currentState = .downloaded
                                } else {
                                    self.currentState = .notDownloaded
                                    
                                }
                            }
                            
                        }) {
                            Image(systemName: self.currentState == .downloaded ? "checkmark.circle.fill" : "icloud.and.arrow.down")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .tint(Color("ColorDarkGreen"))
                            
                        }
                        .disabled(self.currentState == .downloaded)
                        .onChange(of: workout.isDownloaded) { newValue in
                            if newValue {
                                
                            } else {
                            }
                        }
                    }
                }

                Button(action: {
                    print("Play button tapped")
                }) {
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .tint(Color("ColorDarkGreen"))
                }
            } //: HSTACK
        }
        .padding(.vertical)
        .padding(.horizontal)
        .background(Color("ColorLightGrey2"))
        .cornerRadius(10)
    }
}


//struct LibraryCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            Color("ColorGrey")
//                .ignoresSafeArea(.all, edges: .all)
//            LibraryCellView(title: "Light morning workout", author: "Author")
//        }
//    }
//}
