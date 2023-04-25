//
//  DownloaderDelegate.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 25.04.2023.
//

import Foundation

protocol DownloaderDelegate {
    
    func downloadWorkout(videoStoragePath: String, positionsStoragePath: String, videoFileName: String, positionsFileName: String, completion: @escaping (String?, String?) -> Void)
}
