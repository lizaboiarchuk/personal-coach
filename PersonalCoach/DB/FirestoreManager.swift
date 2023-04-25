//
//  DB.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 25.04.2023.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreManager {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    func loadWorkouts(completion: @escaping ([Workout]?, Error?) -> Void) {
        db.collection("workouts-collection").getDocuments() { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let querySnapshot = querySnapshot else {
                completion(nil, NSError(domain: "FirestoreManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Couldn't get query snapshot"]))
                return
                
            }
            let workouts = querySnapshot.documents.compactMap { document -> Workout? in
                return try? document.data(as: Workout.self)
            }
            completion(workouts, nil)
        }
    }
    
    func loadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        let storageRef = storage.reference(forURL: url)
        storageRef.getData(maxSize: 1 * 2048 * 2048) { data, error in
            if let error = error {
                print("Error downloading image from Firebase Storage: \(error)")
                completion(nil)
            } else if let data = data {
                completion(UIImage(data: data))
            } else {
                completion(nil)
            }
        }
    }
    
    func downloadAndSaveFile(from url: String, fileName: String, completion: @escaping (String?) -> Void) {
        let storageRef = storage.reference(forURL: url)
        storageRef.getData(maxSize: 10 * 1024 * 1024 * 1000) { data, error in
            if let error = error {
                print("Error downloading file: \(error)")
                completion(nil)
            } else {
                guard let data = data else {
                    print("Error: no data returned from download task")
                    completion(nil)
                    return
                }
                let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationUrl = documentsUrl.appendingPathComponent(fileName)
                do {
                    try data.write(to: destinationUrl, options: .atomic)
                    completion(destinationUrl.path)
                } catch {
                    print("Error saving file: \(error)")
                    completion(nil)
                }
            }
        }
    }

    
    
}
