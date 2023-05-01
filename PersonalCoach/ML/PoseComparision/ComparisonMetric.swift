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


// Calculates the cosine distance between two vectors, which is a measure of their similarity.
// The formula used to calculate the cosine distance is:
// 1 - dotProduct(vector1, vector2) / (norm(vector1) * norm(vector2))
func cosineDist(_ vector1: (Float, Float), _ vector2: (Float, Float)) -> Float {
    let dotProd = dotProduct(vector1, vector2)
        let norm1 = norm(vector1)
    let norm2 = norm(vector2)
        let denominator = norm1 * norm2
        let numerator = dotProd
        return 1 - numerator / denominator
}


// Uses the Accelerate framework's vDSP_dotpr function to efficiently calculate the dot product.
func dotProduct(_ a: (Float, Float), _ b: (Float, Float)) -> Float {
    var result: Float = 0
    
    // Call vDSP_dotpr to calculate the dot product of the two vectors.
    vDSP_dotpr([a.0, a.1], 1, [b.0, b.1], 1, &result, 2)
    
    return result
}

// Uses the Accelerate framework's vDSP_svesq function to efficiently calculate the sum of squares of the vector's elements.
func norm(_ a: (Float, Float)) -> Float {
    var result: Float = 0
    
    // Call vDSP_svesq to calculate the sum of squares of the vector's elements.
    vDSP_svesq([a.0, a.1], 1, &result, 2)
    
    // Return the square root of the sum of squares as the magnitude (norm) of the vector.
    return sqrt(result)
}
