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

extension LibraryViewModel: DownloaderDelegate {
    
    
    func downloadWorkout(videoStoragePath: String, positionsStoragePath: String, videoFileName: String, positionsFileName: String, completion: @escaping (String?, String?) -> Void) {
        
        var savedVideoPath: String?
        var savedPositionsPath: String?
        
        DispatchQueue.global(qos: .background).async {
            let group = DispatchGroup()
            group.enter()
            self.firestoreManager.downloadAndSaveFile(from: videoStoragePath, fileName: videoFileName) { path in
                if let path = path {
                    savedVideoPath = path
                }
                else {
                    print("Error downloading and saving workout video")

                }
                group.leave()
            }
            group.enter()
            self.firestoreManager.downloadAndSaveFile(from: positionsStoragePath, fileName: positionsFileName) { path in
                if let path = path {
                    savedPositionsPath = path
                }
                else {
                    print("Error downloading and saving workout positions data")
                }
                group.leave()
            }
            group.notify(queue: .main) {
                if let lvp = savedVideoPath, let lpp = savedPositionsPath {
                    completion(lvp, lpp)
                } else {
                    completion(nil, nil)
                }
            }
        }
    }
}
