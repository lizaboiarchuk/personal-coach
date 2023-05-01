//
//  Aligner.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 24.04.2023.
//

import Foundation
import Accelerate

// PositionComparer class for comparing a sequence of body joint positions to a target sequence using DTW
class PositionComparer {
    
    // MARK: - Private properties
    
    // Joint deviation threshold used for determining which joint positions have deviated too much from the target sequence
    private enum Configuration {
        static let jointDeviationTreshold: Float = 0.03
    }
    
    // Length of the waiting window used for aligning the user sequence with the target sequence
    private let waitingWindowLen: Int
    
    // Length of the coach buffer used for holding the target sequence while aligning with the user sequence
    private let coachBufferLen: Int
    
    // Number of joint positions to compare when computing the distance metric between the aligned sequences
    private let comparingNumber: Int
    
    // The target sequence of body joint positions to compare the user's sequence to
    private let targetSequence: [[[Float]]]
    
    // The user's sequence of body joint positions received from input
    private var userSequence: [[[Float]]] = []
    
    // The current waiting window of user joint positions being aligned with the target sequence
    private var waitingWindow: [[[Float]]] = []
    
    // The indices of the user joint positions in the waiting window
    private var waitingWindowIndexes: [Int] = []
    
    // The joint positions in the target sequence that have been aligned with the user sequence
    private var matchedCoachPositions: [[[Float]]] = []
    
    // The joint positions in the user sequence that have been aligned with the target sequence
    private var matchedUserPositions: [[[Float]]] = []
    
    // The indices of the matched joint positions in the target sequence
    private var matchedCoachIndexes: [Int] = []
    
    // The indices of the matched joint positions in the user sequence
    private var matchedUserIndexes: [Int] = []
    
    // The distances between the aligned sequences
    private var distances: [Float] = []
    
    // The current count of joint positions received from the user
    private var userCounter: Int = 0
    
    // The current count of joint positions in the target sequence
    private var coachCounter: Int = 0
    
    // The current count of frames (i.e. time steps) processed
    private var frameCounter: Int = 0
    
    // The last computed distance between the aligned sequences
    private var lastDistance: Float = -1
    
    // Whether the coach sequence has ended
    private var coachEnded: Bool = false
    
    // The current buffer of joint positions in the target sequence used for aligning with the user sequence
    private var coachBuffer: [[[Float]]] = []
    
    // The indices of the joint positions in the coach buffer
    private var coachBufferIndexes: [Int] = []
    
    // MARK: - init
    
    /**
     Initializes a new PositionComparer object.
     
     - Parameters:
     - targetSequence: The target sequence of body joint positions to compare the user's sequence to.
     - waitingWindowLen: The length of the waiting window used for aligning the user sequence with the target sequence.
     - coachBufferLen: The length of the coach buffer used for
     holding the target sequence while aligning with the user sequence.
     - comparingNumber: The number of joint positions to compare when computing the distance metric between the aligned sequences.
     */
    init(targetSequence: [[[Float]]], waitingWindowLen: Int = 15, coachBufferLen: Int = 15, comparingNumber: Int = 15) {
        self.waitingWindowLen = waitingWindowLen
        self.coachBufferLen = coachBufferLen
        self.comparingNumber = comparingNumber
        self.targetSequence = targetSequence
    }
    
    // MARK: - Public Methods
    
    /**
     Resets the internal state of the PositionComparer object for a new comparison.
     */
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
    
    /**
     Receives a new sequence of body joint positions from the user and returns the current distance between the aligned sequences.
     
     - Parameters:
     - positions: The sequence of body joint positions received from the user.
     
     - Returns:
     A tuple containing the current distance between the aligned sequences and a boolean indicating whether the coach sequence has ended.
     */
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
    
    /**
     Returns the indices of any body joint positions that deviate from the target sequence by more than the joint deviation threshold.
     
     - Returns:
     An array of indices of body joint positions that have deviated too much from the target sequence.
     */
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
