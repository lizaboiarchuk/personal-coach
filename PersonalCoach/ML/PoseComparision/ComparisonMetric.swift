//
//  ComparisonMetric.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 25.04.2023.
//

import Foundation
import Accelerate


func compareBodies(_ keypoints1: [[Float]], _ keypoints2: [[Float]]) -> Float {
    var dist: Float = 0
    for vec in VECTORS {
        let vector1 = (keypoints1[vec.1.position][0] - keypoints1[vec.0.position][0], keypoints1[vec.1.position][1] - keypoints1[vec.0.position][1])
        let vector2 = (keypoints2[vec.1.position][0] - keypoints2[vec.0.position][0], keypoints2[vec.1.position][1] - keypoints2[vec.0.position][1])
        let cosineDist = 1 - dotProduct(vector1, vector2) / (norm(vector1) * norm(vector2))
        dist += pow(cosineDist, 2)
    }
    return dist / Float(VECTORS.count)
}

func dotProduct(_ a: (Float, Float), _ b: (Float, Float)) -> Float {
    var result: Float = 0
    vDSP_dotpr([a.0, a.1], 1, [b.0, b.1], 1, &result, 2)
    return result
}


func norm(_ a: (Float, Float)) -> Float {
    var result: Float = 0
    vDSP_svesq([a.0, a.1], 1, &result, 2)
    return sqrt(result)
}
