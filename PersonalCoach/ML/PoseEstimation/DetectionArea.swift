//
//  DetectionArea.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 25.04.2023.
//

import Foundation

struct DetectionArea {
    var left: CGFloat
    var top: CGFloat
    var right: CGFloat
    var bottom: CGFloat
    var width: CGFloat { right - left }
    var height: CGFloat { bottom - top }
    
    var rect: CGRect { .init(x: left, y: top, width: width, height: height) }
}
