//
//  WorkoutPreview.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 25.04.2023.
//

import Foundation
import UIKit

class WorkoutPreview {
    var description: String
    var tags: [String]
    var coverURL: String
    var coverImage: UIImage?
    var positions: String
    var author: String
    var video: String
    var name: String
    var uid: String
    
    var isDownloaded = false
    var localVideoPath: String?
    var localPositionsPath: String?
    
    
    init(workout: Workout) {
        self.description = workout.description
        self.tags = workout.tags
        self.positions = workout.positions
        self.author = workout.author
        self.video = workout.video
        self.name = workout.name
        self.coverURL = workout.cover
        self.uid = workout.uid
    }
}
