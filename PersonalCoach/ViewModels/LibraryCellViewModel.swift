//
//  LibraryCellViewModel.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 26.04.2023.
//

import Combine
import SwiftUI

class LibraryCellViewModel: ObservableObject {
    @Published var currentState: WorkoutDownloadState = .notDownloaded
    let workout: WorkoutPreview
    let delegate: DownloaderDelegate

    init(workout: WorkoutPreview, delegate: DownloaderDelegate) {
        self.workout = workout
        self.delegate = delegate
        
        let fileManager = FileManager.default
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        if fileManager.fileExists(atPath: documentsUrl.appendingPathComponent("\(workout.uid).mp4").path) && fileManager.fileExists(atPath: documentsUrl.appendingPathComponent("\(workout.uid).json").path) {
            self.currentState = .downloaded
            workout.isDownloaded = true
            workout.localPositionsPath = documentsUrl.appendingPathComponent("\(workout.uid).json").path
            workout.localVideoPath = documentsUrl.appendingPathComponent("\(workout.uid).mp4").path
        } else {
            self.currentState = .notDownloaded
        }
    }
    
    func downloadWorkout() {
        self.currentState = .downloading
        self.delegate.downloadWorkout(videoStoragePath: self.workout.video,
                                      positionsStoragePath: self.workout.positions,
                                      videoFileName: "\(workout.uid).mp4",
                                      positionsFileName: "\(workout.uid).json") { localVideoPath, localPositionsPath in
            if let lvp = localVideoPath, let lpp = localPositionsPath {
                self.workout.localVideoPath = lvp
                self.workout.localPositionsPath = lpp
                print(type(of: lvp))
                self.workout.isDownloaded = true
                self.currentState = .downloaded
            } else {
                self.currentState = .notDownloaded
            }
        }
    }

    func playWorkout() {
        print("Play button tapped")
    }
}
