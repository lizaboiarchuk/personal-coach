//
//  Workout.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 25.04.2023.
//

import Foundation

struct Workout: Codable {
    var description: String
    var tags: [String]
    var cover: String
    var positions: String
    var author: String
    var video: String
    var name: String
}
