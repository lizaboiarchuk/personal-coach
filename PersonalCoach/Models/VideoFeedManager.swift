//
//  VideoFeedManager.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 24.04.2023.
//

import AVFoundation
import UIKit

protocol VideoFeedManagerDelegate: AnyObject {
    func videoFeedManager(_ videoFeedManager: VideoFeedManager, didOutput pixelBuffer: CVPixelBuffer)
}

class VideoFeedManager: NSObject {
    var avPlayer: AVPlayer!
    private var videoOutput: AVPlayerItemVideoOutput!
    private var displayLink: CADisplayLink!    
    weak var delegate: VideoFeedManagerDelegate?

    init(url: URL) {
        super.init()
        setupAVPlayer(with: url)
        setupDisplayLink()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)


    }
    @objc private func applicationWillResignActive() {
        stopVideo()
    }
    @objc private func applicationDidBecomeActive() {
        startVideo()
    }
    
    deinit {
           NotificationCenter.default.removeObserver(self)
       }

    private func setupAVPlayer(with url: URL) {
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        avPlayer = AVPlayer(playerItem: item)

        let videoTrack = asset.tracks(withMediaType: .video).first!
        let videoSize = videoTrack.naturalSize
        let videoAspectRatio = videoSize.width / videoSize.height

        let pixelBufferWidth = videoSize.width
        let pixelBufferHeight = round(pixelBufferWidth / videoAspectRatio)

        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: pixelBufferWidth,
            kCVPixelBufferHeightKey as String: pixelBufferHeight,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttributes)
        item.add(videoOutput)
    }


    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidRefresh(link:)))
        displayLink.add(to: .current, forMode: .default)
        displayLink.isPaused = true
    }

    @objc private func displayLinkDidRefresh(link: CADisplayLink) {
        let itemTime = videoOutput.itemTime(forHostTime: CACurrentMediaTime())
        if videoOutput.hasNewPixelBuffer(forItemTime: itemTime), let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil) {
            delegate?.videoFeedManager(self, didOutput: pixelBuffer)
        }
    }

    func startVideo() {
        displayLink.isPaused = false
        avPlayer.play()
    }

    func stopVideo() {
        displayLink.isPaused = true
        avPlayer.pause()
    }
    
    
}
