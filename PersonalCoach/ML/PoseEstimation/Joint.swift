//
//  BodyPart.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 25.04.2023.
//

import Foundation

enum Joint: String, CaseIterable {
    case nose = "nose"
    case leftEye = "left eye"
    case rightEye = "right eye"
    case leftEar = "left ear"
    case rightEar = "right ear"
    case leftShoulder = "left shoulder"
    case rightShoulder = "right shoulder"
    case leftElbow = "left elbow"
    case rightElbow = "right elbow"
    case leftWrist = "left wrist"
    case rightWrist = "right wrist"
    case leftHip = "left hip"
    case rightHip = "right hip"
    case leftKnee = "left knee"
    case rightKnee = "right knee"
    case leftAnkle = "left ankle"
    case rightAnkle = "right ankle"
    
    var position: Int {
        return Joint.allCases.firstIndex(of: self) ?? 0
    }
}

struct KeyPoint {
    var bodyPart: Joint = .nose
    var coordinate: CGPoint = .zero
    var score: Float32 = 0.0
}

struct TorsoBodyDist {
    var maxTorsoYDistance: CGFloat
    var maxTorsoXDistance: CGFloat
    var maxBodyYDistance: CGFloat
    var maxBodyXDistance: CGFloat
}
