//
//  CoverImageView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 25.04.2023.
//

import Foundation
import SwiftUI
import UIKit

struct CoverImageView: View {
    
    var image: UIImage? = nil
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    Image("photo.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .clipped()
        }
    }
}
