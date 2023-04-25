//
//  DTW.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 15.04.2023.
//

import Foundation

func fastdtw(_ x: [[[Float]]], _ y: [[[Float]]], dist: (_ a: [[Float]], _ b: [[Float]]) -> Float) -> (Float, [(Int, Int)]) {
    let xCount = x.count
    let yCount = y.count
    
    let costBuffer = UnsafeMutableBufferPointer<Float>.allocate(capacity: xCount * yCount)
    defer { costBuffer.deallocate() }
    costBuffer.assign(repeating: Float.infinity)
    
    let pathBuffer = UnsafeMutableBufferPointer<(Int, Int)>.allocate(capacity: (xCount + yCount))
    defer { pathBuffer.deallocate() }
    pathBuffer.assign(repeating: (-1, -1))
    
    costBuffer[0] = dist(x[0], y[0])
    pathBuffer[0] = (0, 0)

    for j in 1..<yCount {
        costBuffer[j] = costBuffer[j-1] + dist(x[0], y[j])
        pathBuffer[j] = (0, j-1)
    }

    for i in 1..<xCount {
        costBuffer[i * yCount] = costBuffer[(i-1) * yCount] + dist(x[i], y[0])
        pathBuffer[i] = (i-1, 0)
    }

    for i in 1..<xCount {
        for j in 1..<yCount {
            let candidates = [costBuffer[(i-1) * yCount + j], costBuffer[i * yCount + (j-1)], costBuffer[(i-1) * yCount + (j-1)]]
            let minIdx = candidates.enumerated().min(by: { $0.1 < $1.1 })!.offset
            costBuffer[i * yCount + j] = candidates[minIdx] + dist(x[i], y[j])
            switch minIdx {
            case 0:
                pathBuffer[i + j] = (i - 1, j)
            case 1:
                pathBuffer[i + j] = (i, j - 1)
            default:
                pathBuffer[i + j] = (i - 1, j - 1)
            }
        }
    }
    var i = xCount - 1
    var j = yCount - 1
    var wp: [(Int, Int)] = []
    while i > 0 || j > 0 {
        wp.append((i, j))
        let min_idx: Int
        if i == 0 {
            min_idx = 2
        } else if j == 0 {
            min_idx = 1
        } else {
            min_idx = [costBuffer[(i - 1) * yCount + (j - 1)], costBuffer[(i - 1) * yCount + j], costBuffer[i * yCount + (j - 1)]].minIndex()!
        }
        if min_idx == 1 {
            i = i - 1
        } else if min_idx == 2 {
            j = j - 1
        } else {
            i = i - 1
            j = j - 1
        }
    }
    wp.append((0, 0))
    wp.reverse()
    return (costBuffer[(xCount-1) * yCount + (yCount-1)], wp)
}
