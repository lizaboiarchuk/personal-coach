//
//  ContentView.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 09.04.2023.
//

//import SwiftUI
//import AVFoundation
//import Accelerate.vImage
//import UIKit
//import os
//
//
//struct VideoDetectionView: View {
//    var body: some View {
//
//        ZStack {
//            VideoDetectionViewControllerRepresentable()
//                .aspectRatio(2408.0/1346.0 , contentMode: .fit)
//                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
//                .edgesIgnoringSafeArea(.all)
//                .scaleEffect(x: -1, y: 1)
//
////            ZStack {
////                VideoStreamerViewControllerRepresentable()
////                    .frame(width: 300, height: 170)
////                    .position(x: UIScreen.main.bounds.width * 0.60, y: UIScreen.main.bounds.height * 0.15)
////            }
//        }
//    }
//}
//
//
//struct VideoDetectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoDetectionView()
//    }
//}
//
//
//struct VideoDetectionViewControllerRepresentable: UIViewControllerRepresentable {
//    typealias UIViewControllerType = VideoDetectionViewController
//
//    func makeUIViewController(context: Context) -> VideoDetectionViewController {
//        return VideoDetectionViewController()
//    }
//
//    func updateUIViewController(_ uiViewController: VideoDetectionViewController, context: Context) {}
//}
//
//
//final class VideoDetectionViewController: UIViewController {
//    private var poseEstimator: PoseEstimator?
//    private var videoFeedManager: VideoFeedManager!
//    let queue = DispatchQueue(label: "serial_queue")
//    var isRunning = false
//    private var overlayView: OverlayView!
//    var r: [[Float32]] = []
//    var comparer = try ComparisonManager(path: "asdfg")
//
//
//    // MARK: View Handling Methods
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupOverlayView()
//        updateModel()
//        configVideoCapture()
//        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: videoFeedManager.avPlayer.currentItem)
//    }
//
//    @objc private func playerDidFinishPlaying(notification: Notification) {
//        print("Video finished")
//        print(r)
//    }
//
//    private func setupOverlayView() {
//        overlayView = OverlayView(frame: view.bounds)
//        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view.addSubview(overlayView)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        videoFeedManager.startVideo()
//
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        videoFeedManager.stopVideo()
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//    }
//
//    private func configVideoCapture() {
//        guard let videoURL = Bundle.main.url(forResource: "coach-3-mirror", withExtension: "mov") else {
//            fatalError("Failed to find video file.")
//        }
//        videoFeedManager = VideoFeedManager(url: videoURL)
//        videoFeedManager.delegate = self
//    }
//
//    private func updateModel() {
//        queue.async {
//            do {
//                self.poseEstimator = try PoseEstimator()
//            } catch {}
//        }
//    }
//}
//
//// MARK: - VideoFeedManagerDelegate Methods
//extension VideoDetectionViewController: VideoFeedManagerDelegate {
//    func videoFeedManager(_ videoFeedManager: VideoFeedManager, didOutput pixelBuffer: CVPixelBuffer) {
//            self.runModel(pixelBuffer)
//    }
//
//    private func runModel(_ pixelBuffer: CVPixelBuffer) {
//        guard !isRunning else { return }
//        guard let estimator = poseEstimator else { return }
//        queue.async {
//            self.isRunning = true
//            defer { self.isRunning = false }
//            do {
//                let (keypoints, score, points, positionsArray) = try estimator.detectPose(on: pixelBuffer)
//                self.r.append(points)
//                DispatchQueue.main.async {
//                    let image = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))
//                    if score < 0.2 {
//                        self.overlayView.image = image
//                        return
//                    }
//                    self.overlayView.draw(at: image, keypoints: keypoints, deviated: [])
//                }
//            } catch { return }
//        }
//    }
//}

