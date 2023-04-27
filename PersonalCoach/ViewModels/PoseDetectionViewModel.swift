//
//  PoseDetectionViewModel.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 27.04.2023.
//

import Foundation
import SwiftUI
import AVFoundation
import Accelerate.vImage
import UIKit
import os

class PoseDetectionViewModel: ObservableObject {
    
    @Published var resultLabel = "..."
    @Published var isPaused = false
    @Published var showOverlay = true
    @Published var counter = 5
    @Published var overlayView = OverlayView(frame: UIScreen.main.bounds)
    
    private var poseEstimator: PoseEstimator?
    private var cameraFeedManager: CameraFeedManager!
    private let queue = DispatchQueue(label: "serial_queue")
    private var isRunning = false
    private var comparer: ComparisonManager?
    private var overlayTreshold: Float = 0.2
    private var evalTreshold: Float = 1.3
    private var overallScore: Float = 0
    private var framesCount: Int = 0
    private var correctFramesCount: Int = 0
    
    private var positionsPath: String?

    private var countdownTimer: Timer?
    
    init(workout: WorkoutPreview) {
        self.positionsPath = workout.localPositionsPath
        setupPoseComparer()
        setupOverlayView()
        initModel()
        configCameraCapture()
    }
    
    deinit {
        poseEstimator = nil
        cameraFeedManager = nil
        comparer = nil
    }
    
    
    private func setupPoseComparer() {
        if let path = positionsPath {
            do {
                self.comparer = try ComparisonManager(path: path)
            }
            catch {
            }
        }
    }
    
    private func setupOverlayView() {
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func configCameraCapture() {
        cameraFeedManager = CameraFeedManager()
        cameraFeedManager.startRunning()
        cameraFeedManager.delegate = self
    }
    
    private func initModel() {
        queue.async {
            do { self.poseEstimator = try PoseEstimator()}
            catch {
                print("model not inited")
            }
        }
    }
    
    func startCountdown() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            if counter > 0 {
                counter -= 1
            } else {
                timer.invalidate()
                withAnimation(.easeInOut(duration: 0.5)) {
                    showOverlay = false
                }
            }
        }
    }
    
    func quit() {
        countdownTimer?.invalidate()
        cameraFeedManager.stopRunning()
    }

    
    private func runModel(_ pixelBuffer: CVPixelBuffer) {
        guard !isRunning else { return }
        guard let estimator = poseEstimator else { return }
        guard let comparer = self.comparer else { return }
        queue.async {
            self.isRunning = true
            defer { self.isRunning = false }
            do {
                let (keypoints, score, _, positionsArray) = try estimator.detectPose(on: pixelBuffer)
                let (evalScore, evalFinished) = comparer.receive(positions: positionsArray)
                var deviatedLines = comparer.getDeviatedLines()
                DispatchQueue.main.async { [self] in
                    var newLabel = ""
                    if evalFinished {
                        if evalScore < self.evalTreshold {
                            deviatedLines = []
                            correctFramesCount += 1
                        }
                        framesCount += 1
                        resultLabel = "\(Int(round(Double(correctFramesCount) / Double(framesCount) * 100)))%"
                    }
                    let image = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))
                    if score < self.overlayTreshold {
                        overlayView.image = image
                        return
                    }
                    overlayView.draw(at: image, keypoints: keypoints, deviated: deviatedLines)
                }
            } catch {
                print("sdfgh")
            }
        }
    }
}

// MARK: - CameraFeedManagerDelegate Methods
extension PoseDetectionViewModel: CameraFeedManagerDelegate {
    func cameraFeedManager(_ cameraFeedManager: CameraFeedManager, didOutput pixelBuffer: CVPixelBuffer) {
        
        if !showOverlay {
            if !isPaused {
                self.runModel(pixelBuffer)
            }
        }
    }
}
