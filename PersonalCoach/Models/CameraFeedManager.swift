//
//  CameraFeedManager.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 24.04.2023.
//

import Foundation
import AVFoundation
import Accelerate.vImage
import UIKit


protocol CameraFeedManagerDelegate: AnyObject {
  func cameraFeedManager(_ cameraFeedManager: CameraFeedManager, didOutput pixelBuffer: CVPixelBuffer)
}

final class CameraFeedManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
  weak var delegate: CameraFeedManagerDelegate?

  override init() {
    super.init()
    configureSession()
  }

  func startRunning() {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      self?.captureSession.startRunning()
    }
  }

  func stopRunning() {
    captureSession.stopRunning()
  }

  let captureSession = AVCaptureSession()

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

  var previewLayer: AVCaptureVideoPreviewLayer? {
    let layer = AVCaptureVideoPreviewLayer(session: captureSession)
    layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    return layer
  }
}
