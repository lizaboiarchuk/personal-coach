/**
 The VideoFeedManager class is responsible for managing the video playback and outputting the frames to the delegate.
 
 To use the VideoFeedManager, create an instance of the class and provide the URL of the video. You can then start and stop the video playback as needed.
 
 The VideoFeedManagerDelegate protocol provides a way to receive the pixel buffer frames as they are outputted by the video player.
 
 Author: Yelyzaveta Boiarchuk
 Date: 24.04.2023
 
 */
import AVFoundation
import UIKit
protocol VideoFeedManagerDelegate: AnyObject {
    /**
     Notifies the delegate that a new pixel buffer frame is available.
     
     - Parameters:
     - videoFeedManager: The VideoFeedManager instance that produced the pixel buffer.
     - pixelBuffer: The new pixel buffer frame.
     */
    func videoFeedManager(_ videoFeedManager: VideoFeedManager, didOutput pixelBuffer: CVPixelBuffer)
}

class VideoFeedManager: NSObject {
    var avPlayer: AVPlayer!
    private var videoOutput: AVPlayerItemVideoOutput!
    private var displayLink: CADisplayLink!
    weak var delegate: VideoFeedManagerDelegate?
    
    /**
     Initializes a new instance of the VideoFeedManager class.
     
     - Parameters:
     - url: The URL of the video to play.
     */
    init(url: URL) {
        super.init()
        setupAVPlayer(with: url)
        setupDisplayLink()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    /**
     Starts the video playback and outputting of frames to the delegate.
     */
    func startVideo() {
        displayLink.isPaused = false
        avPlayer.play()
    }
    
    /**
     Stops the video playback and outputting of frames to the delegate.
     */
    func stopVideo() {
        displayLink.isPaused = true
        avPlayer.pause()
    }
    
    /**
     Cleans up resources when the instance of the class is no longer needed.
     */
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    
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
    
    // MARK: - Notification
    /**
     Pauses the video playback when the application is about to resign the active state.
     */
    @objc private func applicationWillResignActive() {
        stopVideo()
    }
    
    /**
     Resumes the video playback when the application becomes active again.
     */
    @objc private func applicationDidBecomeActive() {
        startVideo()
    }
    
    // MARK: - Selector Methods
    
    /**
     Called by the display link when a new frame is available for output.
     
     - Parameters:
     - link: The display link.
     */
    @objc private func displayLinkDidRefresh(link: CADisplayLink) {
        let itemTime = videoOutput.itemTime(forHostTime: CACurrentMediaTime())
        if videoOutput.hasNewPixelBuffer(forItemTime: itemTime), let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil) {
            delegate?.videoFeedManager(self, didOutput: pixelBuffer)
        }
    }
}

