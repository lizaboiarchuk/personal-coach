//
//  VideoStreamerViewModel.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 27.04.2023.
//

import SwiftUI
import AVFoundation

// MARK: - ViewModel
class VideoStreamerViewModel: ObservableObject {
    private var videoFeedManager: VideoFeedManager!
    private(set) var videoPath: String?
    private(set) var playerLayer: AVPlayerLayer!
    
    init(videoPath: String?) {
        guard videoPath != nil else { fatalError("Failed to find downloaded video file.") }
        self.videoPath = videoPath
        configVideoCapture()
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: videoFeedManager.avPlayer.currentItem)
    }
    
    @objc private func playerDidFinishPlaying(notification: Notification) {
        videoFeedManager.avPlayer.seek(to: .zero)
        videoFeedManager.avPlayer.play()
    }
    
    func startVideo() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.videoFeedManager.startVideo()
        }
    }
    
    func stopStreaming() {
        videoFeedManager.avPlayer.pause()
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    func resumeStreaming() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to activate audio session: \(error)")
        }
        videoFeedManager.avPlayer.play()
    }
    
    private func configVideoCapture() {
        guard let vp = self.videoPath else { fatalError("Failed to find downloaded video file.") }
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: vp)  {
            fatalError("Failed to find downloaded video file.")
        }
        let videoURL = URL(fileURLWithPath: vp)
        
        videoFeedManager = VideoFeedManager(url: videoURL)
        playerLayer = AVPlayerLayer(player: videoFeedManager.avPlayer)
        playerLayer.videoGravity = .resizeAspectFill
    }
    
    func quit() {
        stopStreaming()
        NotificationCenter.default.removeObserver(self)
        playerLayer.removeFromSuperlayer()
        videoFeedManager.avPlayer.replaceCurrentItem(with: nil)
        
        // Stop the audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
        
        videoFeedManager = nil
    }
}

