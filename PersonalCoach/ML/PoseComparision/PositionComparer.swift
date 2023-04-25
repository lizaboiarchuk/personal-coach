//
//  Aligner.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 24.04.2023.
//

import Foundation
import Accelerate

class PositionComparer {
    
    // MARK: - Private properties
    
    private enum Configuration {
        static let jointDeviationTreshold: Float = 0.03
    }
    
    private let waitingWindowLen: Int
    private let coachBufferLen: Int
    private let comparingNumber: Int
    private let targetSequence: [[[Float]]]
    private var userSequence: [[[Float]]] = []
    private var waitingWindow: [[[Float]]] = []
    private var waitingWindowIndexes: [Int] = []
    private var matchedCoachPositions: [[[Float]]] = []
    private var matchedUserPositions: [[[Float]]] = []
    private var matchedCoachIndexes: [Int] = []
    private var matchedUserIndexes: [Int] = []
    private var distances: [Float] = []
    private var userCounter: Int = 0
    private var coachCounter: Int = 0
    private var frameCounter: Int = 0
    private var lastDistance: Float = -1
    private var coachEnded: Bool = false
    private var coachBuffer: [[[Float]]] = []
    private var coachBufferIndexes: [Int] = []

    // MARK: - init
    init(targetSequence: [[[Float]]], waitingWindowLen: Int = 15, coachBufferLen: Int = 15, comparingNumber: Int = 15) {
        self.waitingWindowLen = waitingWindowLen
        self.coachBufferLen = coachBufferLen
        self.comparingNumber = comparingNumber
        self.targetSequence = targetSequence
    }
    
    // MARK: - Public Methods
    func prepare() {
        userSequence = []
        waitingWindow = []
        waitingWindowIndexes = []
        matchedCoachPositions = []
        matchedUserPositions = []
        matchedCoachIndexes = []
        matchedUserIndexes = []
        distances = []
        userCounter = 0
        coachCounter = 0
        frameCounter = 0
        lastDistance = -1
        coachEnded = false
        coachBuffer = Array(targetSequence[0..<coachBufferLen])
        coachBufferIndexes = Array(0..<coachBufferLen)
        coachCounter = coachBufferLen
    }
    
    
    func receive(positions: [[Float]]) -> (Float, Bool) {
        if coachEnded { return (0.0, false) }
        if waitingWindow.count < waitingWindowLen {
            waitingWindow.append(positions)
            waitingWindowIndexes.append(userCounter)
            userCounter += 1
            return (lastDistance, false)
        }
        let (_, alligned) = fastdtw(waitingWindow, coachBuffer, dist: compareBodies)
        let positionMatch = Int(alligned.filter { $0.1 == 0 }.map { $0.0 }.min()!)
        matchedCoachIndexes.append(coachBufferIndexes[0])
        matchedCoachPositions.append(coachBuffer[0])
        matchedUserIndexes.append(waitingWindowIndexes[positionMatch])
        matchedUserPositions.append(waitingWindow[positionMatch])
        
        let (distance, _) = fastdtw(Array(matchedCoachPositions.suffix(comparingNumber)),
                                    Array(matchedUserPositions.suffix(comparingNumber)),
                                    dist: compareBodies)
        distances.append(distance)
        lastDistance = distance
        coachBuffer.removeFirst()
        coachBuffer.append(targetSequence[coachCounter])
        coachBufferIndexes.removeFirst()
        coachBufferIndexes.append(coachCounter)
        coachCounter += 1
        waitingWindow.removeSubrange(0...(positionMatch))
        waitingWindow.append(positions)
        waitingWindowIndexes.removeSubrange(0...(positionMatch))
        waitingWindowIndexes.append(userCounter)
        userCounter += 1
        if coachCounter == targetSequence.count { coachEnded = true }
        return (distance, true)
    }


    func getDeviatedLines() -> [Int] {
        guard let keypoints1 = matchedCoachPositions.last else { return [] }
        guard let keypoints2 = matchedUserPositions.last else { return [] }
        var deviated: [Int] = []
        var dist: Float = 0
        for (i, vec) in VECTORS.enumerated() {
            let vector1 = (keypoints1[vec.1.position][0] - keypoints1[vec.0.position][0], keypoints1[vec.1.position][1] - keypoints1[vec.0.position][1])
            let vector2 = (keypoints2[vec.1.position][0] - keypoints2[vec.0.position][0], keypoints2[vec.1.position][1] - keypoints2[vec.0.position][1])
            let cosineDist = 1 - dotProduct(vector1, vector2) / (norm(vector1) * norm(vector2))
            dist = pow(cosineDist, 2)
            if dist > Configuration.jointDeviationTreshold {
                deviated.append(i)
            }
        }
        return deviated
    }
}

