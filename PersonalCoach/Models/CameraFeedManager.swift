// Importing required frameworks
import Foundation
import AVFoundation
import Accelerate.vImage
import UIKit

/// A protocol to be implemented by objects that want to receive the camera pixel buffer output
protocol CameraFeedManagerDelegate: AnyObject {
    func cameraFeedManager(_ cameraFeedManager: CameraFeedManager, didOutput pixelBuffer: CVPixelBuffer)
}

/// A class to manage camera feed from the device's front camera
final class CameraFeedManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - Public Properties
    
    /// A weak reference to the delegate object that will receive the camera pixel buffer output
    weak var delegate: CameraFeedManagerDelegate?
    
    /// A capture session instance
    let captureSession = AVCaptureSession()
    

    // MARK: - Initialization
    
    override init() {
        super.init()
        configureSession()
    }
    
    
    // MARK: - Public Methods
    
    /// Starts running the camera capture session in the background
    ///
    /// - Parameters: None
    ///
    /// - Returns: Void
    func startRunning() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    /// Stops running the camera capture session
    ///
    /// - Parameters: None
    ///
    /// - Returns: Void
    func stopRunning() {
        captureSession.stopRunning()
    }
    
    /// A preview layer that can be added to a view to display the camera feed
    ///
    /// - Parameters: None
    ///
    /// - Returns: AVCaptureVideoPreviewLayer instance
    var previewLayer: AVCaptureVideoPreviewLayer? {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        return layer
    }
    
    
    // MARK: - Private Methods
    
    /// Configures the AVCaptureSession with video output settings and device input
    ///
    /// - Parameters: None
    ///
    /// - Returns: Void
    private func configureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .front)
        
        guard let backCamera = deviceDiscoverySession.devices.first else {
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            captureSession.addInput(input)
        } catch {
            return
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [
            (kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value: kCVPixelFormatType_32BGRA)
        ]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        let dataOutputQueue = DispatchQueue(
            label: "com.camerafeedmanager.dataOutputQueue",
            qos: .userInitiated,
            attributes: [],
            autoreleaseFrequency: .workItem)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            videoOutput.connection(with: .video)?.videoOrientation = .portrait
        }
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
    }
    
    /// A delegate method that outputs the camera pixel buffer to the delegate object
    ///
    /// - Parameters:
    ///   - output: AVCaptureOutput instance
    ///   - sampleBuffer: CMSampleBuffer instance
    ///   - connection: AVCaptureConnection instance
    ///
    /// - Returns: Void
    func captureOutput(
        _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        delegate?.cameraFeedManager(self, didOutput: pixelBuffer)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
    }
}

