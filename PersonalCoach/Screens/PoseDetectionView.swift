//
//  ContentView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 09.04.2023.
//

import SwiftUI
import AVFoundation
import Accelerate.vImage
import UIKit
import os


// MARK: - View
struct PoseDetectionView: View {
    @ObservedObject var viewModel = PoseDetectionViewModel()
    
    @State private var showOverlay = true
    @State private var counter = 5
    
    var localPositionsPath: String?
    var localVideoPath: String?

    var body: some View {
        ZStack {
            ZStack {
                PoseDetectionViewControllerRepresentable(resultLabel: $viewModel.resultLabel, isPaused: $showOverlay, positionsPath: localPositionsPath)
                    .aspectRatio(3.0/4.0, contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    .edgesIgnoringSafeArea(.all)
                    .scaleEffect(x: -1, y: 1)

                ZStack {
                    VideoStreamerViewControllerRepresentable(videoPath: localVideoPath)
                        .frame(width: 300, height: 170)
                        .position(x: UIScreen.main.bounds.width * 0.60, y: UIScreen.main.bounds.height * 0.15)
                    VStack {
                        Text(viewModel.resultLabel)
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .position(x: UIScreen.main.bounds.width * 0.60, y: UIScreen.main.bounds.height * 0.35)
                }//:ZSTACK
            } //:ZSTACK
            if showOverlay {
                Color.gray.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        Text("\(counter)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
            }
        }
        .onAppear {
            startCountdown()
        }
    }
    
    
    func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
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
}

struct PoseDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        PoseDetectionView()
    }
}


// MARK: - ViewModel
class PoseDetectionViewModel: ObservableObject {
    @Published var resultLabel = "..."
}

// MARK: - ViewControllerRepresentable
struct PoseDetectionViewControllerRepresentable: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = PoseDetectionViewController
    
    @Binding var resultLabel: String
    @Binding var isPaused: Bool
    var positionsPath: String?

    func makeUIViewController(context: Context) -> PoseDetectionViewController {
        let viewController = PoseDetectionViewController()
        viewController.resultLabelBinding = $resultLabel
        viewController.isPaused = isPaused
        viewController.positionsPath = positionsPath
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: PoseDetectionViewController, context: Context) {
        uiViewController.isPaused = isPaused
    }
}

// MARK: - ViewController
final class PoseDetectionViewController: UIViewController {
    
    @Published var resultLabel = "..."
    
    private var poseEstimator: PoseEstimator?
    private var cameraFeedManager: CameraFeedManager!
    private let queue = DispatchQueue(label: "serial_queue")
    private var isRunning = false
    private var overlayView: OverlayView!
    private var comparer: ComparisonManager?
    private var overlayTreshold: Float = 0.2
    private var evalTreshold: Float = 1.3
    var resultLabelBinding: Binding<String>?
    var isPaused: Bool = true
    var positionsPath: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPoseComparer()
        setupOverlayView()
        initModel()
        configCameraCapture()
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
        overlayView = OverlayView(frame: view.bounds)
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(overlayView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraFeedManager?.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraFeedManager?.stopRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func configCameraCapture() {
        cameraFeedManager = CameraFeedManager()
        cameraFeedManager.startRunning()
        cameraFeedManager.delegate = self
    }
    
    private func initModel() {
        queue.async {
            do { self.poseEstimator = try PoseEstimator()}
            catch {}
        }
    }
}


  // MARK: - CameraFeedManagerDelegate Methods
extension PoseDetectionViewController: CameraFeedManagerDelegate {
    func cameraFeedManager(_ cameraFeedManager: CameraFeedManager, didOutput pixelBuffer: CVPixelBuffer) {
        if !isPaused {
            self.runModel(pixelBuffer)
        }
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
                    var newLabel = "... \(evalScore)"
                    if evalFinished {
                        newLabel = evalScore < self.evalTreshold ? "Good! \(evalScore)" : "Bad! \(evalScore)"
                        if evalScore < self.evalTreshold { deviatedLines = [] }
                    }
                    self.resultLabelBinding?.wrappedValue = newLabel
                    let image = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))
                    if score < self.overlayTreshold {
                        self.overlayView.image = image
                        return
                    }
                    self.overlayView.draw(at: image, keypoints: keypoints, deviated: deviatedLines)
                }
            } catch {}
        }
    }
}


