//
//  VideoStreamer.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 24.04.2023.
//

import SwiftUI
import AVFoundation
import Accelerate.vImage
import UIKit
import os


// MARK: - ViewControllerRepresentable
struct VideoStreamerViewControllerRepresentable: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = VideoStreamerViewController
    
    var workout: WorkoutPreview
    
    func makeUIViewController(context: Context) -> VideoStreamerViewController {
        let viewController = VideoStreamerViewController()
        viewController.videoPath = workout.localVideoPath
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: VideoStreamerViewController, context: Context) {
    }
}

// MARK: - ViewController
final class VideoStreamerViewController: UIViewController {
    
    private var videoFeedManager: VideoFeedManager!
    private var playerLayer: AVPlayerLayer!
    var videoPath: String?
    
    // MARK: View Handling Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configVideoCapture()
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: videoFeedManager.avPlayer.currentItem)
    }
    
    @objc private func playerDidFinishPlaying(notification: Notification) {
        videoFeedManager.avPlayer.seek(to: .zero)
        videoFeedManager.avPlayer.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.videoFeedManager.startVideo()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoFeedManager.stopVideo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = view.layer.bounds
    }
    
    private func configVideoCapture() {
        guard let vp = self.videoPath else { fatalError("Failed to find downloaded video file.") }
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: vp)  {
            fatalError("Failed to find downloaded video file.")
        }
        let videoURL = URL(fileURLWithPath: vp)
        
        videoFeedManager = VideoFeedManager(url: videoURL)
        videoFeedManager.delegate = self
        
        playerLayer = AVPlayerLayer(player: videoFeedManager.avPlayer)
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)
    }
}

// MARK: - VideoFeedManagerDelegate Methods
extension VideoStreamerViewController: VideoFeedManagerDelegate {
    func videoFeedManager(_ videoFeedManager: VideoFeedManager, didOutput pixelBuffer: CVPixelBuffer) {}
}

