//
//  LibraryViewModel.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 25.04.2023.
//

import Foundation


class LibraryViewModel: ObservableObject {
    
    let firestoreManager = FirestoreManager()
    @Published var downloadingPreviews = true
    var workouts: [WorkoutPreview] = []
    
    
    func loadWorkoutPreviews() {
        var loadedWorkouts = 0
        firestoreManager.loadWorkouts { workouts, error in
            if let error = error {
                print("Error loading workouts: \(error)")
                return
            }
            guard let workouts = workouts else { return }
            let totalWorkouts = workouts.count
            for workout in workouts {
                let workoutPreview = WorkoutPreview(workout: workout)
                self.firestoreManager.loadImage(from: workoutPreview.coverURL) { image in
                    DispatchQueue.main.async {
                        guard let image = image else { return }
                        workoutPreview.coverImage = image
                        loadedWorkouts += 1
                        if loadedWorkouts == totalWorkouts {
                            self.downloadingPreviews = false
                        }
                    }
                }
                self.workouts.append(workoutPreview)
            }
        }
    }
}
