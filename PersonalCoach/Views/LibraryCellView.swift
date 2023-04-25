//
//  LibraryCellView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 28.03.2023.
//

import SwiftUI

struct LibraryCellView: View {
    
    var workout: WorkoutPreview

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
                Button(action: {
                    
                    
                    
                    
                    
                    
                    
                    print("Download button tapped")
                }) {
                    Image(systemName: "icloud.and.arrow.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .tint(Color("ColorDarkGreen"))
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
