//
//  DB.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 25.04.2023.
//

// Importing required frameworks
import Foundation
import Firebase // Firebase framework for Firestore and Storage services
import FirebaseFirestore // Cloud Firestore client library
import FirebaseFirestoreSwift // Firebase Firestore Swift library for mapping data

/// A class to manage Firestore and Storage services
final class FirestoreManager {
    
    // MARK: - Private properties
    
    /// Configuration constants for Firestore and Storage services
    private enum Configuration {
        static let collectionName = "workouts-collection" // Firestore collection name
        static let imageMaxSize: Int64 = 2048 * 2048 // Maximum size of image file
        static let fileMaxSixe: Int64 = 1024 * 1024 * 1024 // Maximum size of file
    }
    
    /// A reference to Firestore instance
    private let db = Firestore.firestore()
    
    /// A reference to Firebase Storage instance
    private let storage = Storage.storage()
    
    
    // MARK: - Public Methods
    
    /// A method to load workouts from Firestore
    ///
    /// - Parameters:
    ///   - completion: A closure to be called upon successful retrieval of workouts or error
    ///
    /// - Returns: Void
    func loadWorkouts(completion: @escaping ([Workout]?, Error?) -> Void) {
        // Retrieving documents from Firestore collection
        db.collection(Configuration.collectionName).getDocuments() { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let querySnapshot = querySnapshot else {
                completion(nil, NSError(domain: "FirestoreManager", code: 1))
                return
            }
            // Mapping documents to Workout model using FirebaseFirestoreSwift library
            let workouts = querySnapshot.documents.compactMap { document -> Workout? in
                return try? document.data(as: Workout.self)
            }
            completion(workouts, nil)
        }
    }
    
    /// A method to load image from Firebase Storage
    ///
    /// - Parameters:
    ///   - url: URL of the image to be loaded
    ///   - completion: A closure to be called upon successful retrieval of image or error
    ///
    /// - Returns: Void
    func loadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        // Creating a reference to Firebase Storage using URL
        let storageRef = storage.reference(forURL: url)
        // Retrieving image data from Firebase Storage
        storageRef.getData(maxSize: Configuration.imageMaxSize) { data, error in
            if let _ = error {
                completion(nil)
            } else if let data = data {
                completion(UIImage(data: data))
            } else {
                completion(nil)
            }
        }
    }

    
    
    func loadFile(from url: String, fileName: String, completion: @escaping (String?) -> Void) {
        let storageRef = storage.reference(forURL: url)
        storageRef.getData(maxSize: 10 * 1024 * 1024 * 1000) { data, error in
            if let error = error {
                completion(nil)
            } else {
                guard let data = data else {
                    completion(nil)
                    return
                }
                let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationUrl = documentsUrl.appendingPathComponent(fileName)
                do {
                    try data.write(to: destinationUrl, options: .atomic)
                    completion(destinationUrl.path)
                } catch {
                    completion(nil)
                }
            }
        }
    }
}
