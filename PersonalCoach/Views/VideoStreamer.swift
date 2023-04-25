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

// MARK: - View
struct VideoStreamerView: View {
    var body: some View {
        ZStack {
        }
    }
}

struct VideoStreamerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoStreamerView()
    }
}

// MARK: - ViewControllerRepresentable
struct VideoStreamerViewControllerRepresentable: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = VideoStreamerViewController
    
    var videoPath: String?
    
    func makeUIViewController(context: Context) -> VideoStreamerViewController {
        print(videoPath)
        let viewController = VideoStreamerViewController()
        viewController.videoPath = videoPath
        return viewController
    }

//    func updateUIViewController(_ uiViewController: VideoStreamerViewController, context: Context) {}
//
//    class Coordinator {
//        var shouldStartVideo: Bool = false
//        let videoFeedManager: VideoFeedManager
//
//        init(videoFeedManager: VideoFeedManager) {
//            self.videoFeedManager = videoFeedManager
//        }
//
//        @objc func startVideo() {
//            if shouldStartVideo {
//                videoFeedManager.startVideo()
//                shouldStartVideo = false
//            }
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//
//
//
//        let videoFeedManager = VideoFeedManager(url: Bundle.main.url(forResource: "coach_1_ex", withExtension: "mp4")!)
//        let coordinator = Coordinator(videoFeedManager: videoFeedManager)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 6, execute: coordinator.startVideo)
//        coordinator.shouldStartVideo = true
//        return coordinator
//    }
}


// MARK: - ViewController
final class VideoStreamerViewController: UIViewController {
    
    private var videoFeedManager: VideoFeedManager!
    private var playerLayer: AVPlayerLayer!
    private var shouldStartVideo: Bool = false
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
        shouldStartVideo = true
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

        print(self.videoPath)
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.videoFeedManager.startVideo()
        }
    }
}

// MARK: - VideoFeedManagerDelegate Methods
extension VideoStreamerViewController: VideoFeedManagerDelegate {
    func videoFeedManager(_ videoFeedManager: VideoFeedManager, didOutput pixelBuffer: CVPixelBuffer) {}
}

