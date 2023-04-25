//
//  OverlayView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 25.04.2023.
//

import Foundation
import UIKit


class OverlayView: UIImageView {
    
    // MARK: - Private properties
    private enum Configuration {
        static let dot = (radius: CGFloat(10), color: UIColor.orange)
        static let line = (width: CGFloat(5.0), color: UIColor.green)
        static let deviatedLine = (width: CGFloat(5.0), color: UIColor.red)
        
    }
    
    private enum PoseDrawError: Error {
        case poseDrawError
    }
    
    private struct Strokes {
        var dots: [CGPoint]
        var lines: [Line]
    }
    
    private struct Line {
        let from: CGPoint
        let to: CGPoint
    }
    
    private var context: CGContext!
    
    
    // MARK: - Public methods
    
    func draw(at image: UIImage, keypoints: [KeyPoint], deviated: [Int]) {
        if context == nil {
            UIGraphicsBeginImageContext(image.size)
            guard let context = UIGraphicsGetCurrentContext() else {
                fatalError("Draw failed.")
            }
            self.context = context
        }
        guard let strokes = strokes(from: keypoints) else { return }
        image.draw(at: .zero)
        context.setLineWidth(Configuration.dot.radius)
        drawDots(at: context, dots: strokes.dots)
        drawLines(at: context, lines: strokes.lines, deviated: deviated)
        context.setStrokeColor(UIColor.blue.cgColor)
        context.strokePath()
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { fatalError() }
        self.image = newImage
        
    }
    
}
    
    // MARK: - Private methods
    
private extension OverlayView {

    private func drawDots(at context: CGContext, dots: [CGPoint]) {
        for i in 5..<dots.count {
            let dot = dots[i]
            let dotRect = CGRect(
                x: dot.x - Configuration.dot.radius / 2, y: dot.y - Configuration.dot.radius / 2,
                width: Configuration.dot.radius, height: Configuration.dot.radius)
            let path = CGPath(
                roundedRect: dotRect, cornerWidth: Configuration.dot.radius, cornerHeight: Configuration.dot.radius,
                transform: nil)
            context.setFillColor(Configuration.dot.color.cgColor)
            context.addPath(path)
            context.fillPath()
        }
    }
    
    
    private func drawDot(at context: CGContext, dot: CGPoint, color: CGColor) {
        context.setStrokeColor(color)
        let dotRect = CGRect(
          x: dot.x - Configuration.dot.radius / 2, y: dot.y - Configuration.dot.radius / 2,
          width: Configuration.dot.radius, height: Configuration.dot.radius)
        let path = CGPath(
          roundedRect: dotRect, cornerWidth: Configuration.dot.radius, cornerHeight: Configuration.dot.radius,
          transform: nil)
        context.addPath(path)
    }


    private func drawLines(at context: CGContext, lines: [Line], deviated: [Int]) {
        for (i, line) in lines.enumerated() {
            if deviated.contains(i) {
                drawDot(at: context, dot: line.from, color: Configuration.deviatedLine.color.cgColor)
                drawDot(at: context, dot: line.to, color: Configuration.deviatedLine.color.cgColor)
                context.setStrokeColor(Configuration.deviatedLine.color.cgColor)
            } else {
                context.setStrokeColor(Configuration.line.color.cgColor)
            }
            context.setLineWidth(deviated.contains(i) ? Configuration.line.width : Configuration.deviatedLine.width)
            context.move(to: CGPoint(x: line.from.x, y: line.from.y))
            context.addLine(to: CGPoint(x: line.to.x, y: line.to.y))
            context.strokePath()
        }
    }


    private func strokes(from keyPoints: [KeyPoint]) -> Strokes? {
        var strokes = Strokes(dots: [], lines: [])
        var bodyPartToDotMap: [Joint: CGPoint] = [:]
        for (index, part) in Joint.allCases.enumerated() {
          let position = CGPoint(
            x: keyPoints[index].coordinate.x,
            y: keyPoints[index].coordinate.y)
          bodyPartToDotMap[part] = position
          strokes.dots.append(position)
        }
        do {
            try strokes.lines = VECTORS.map { map throws -> Line in
                guard let from = bodyPartToDotMap[map.0], let to = bodyPartToDotMap[map.1] else {
                    throw PoseDrawError.poseDrawError
                }
                return Line(from: from, to: to)
            }
        } catch _ { return nil }
        return strokes
    }
}
