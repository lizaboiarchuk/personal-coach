////
////  PoseEstimator.swift
////  PersonalCoach
////
////  Created by Yelyzaveta Boiarchuk on 09.04.2023.
////

import Accelerate
import Foundation
import TensorFlowLite


final class PoseEstimator {
    
    // MARK: - Private Properties
    
    private enum Configuration {
        static let modelFileName = "movenet_thunder" // Name of the model file.
        static let defaultThreadCount = 16 // Default number of threads to use for inference.
        static let minimumScore: Float32 = 0.2 // Minimum score for a keypoint to be considered valid.
        static let torsoRatio: Float = 1.9 // Ratio of the torso region to the maximum range of the torso keypoints.
        static let bodyRatio: Float = 1.2 // Ratio of the body region to the maximum range of the confident keypoints.
        static let minPointScore: Float = 0.4 // Minimum score for a keypoint to be used in the smart crop calculation.
        static let meanParam: Float = 0 // Mean value used for normalization of the input image.
        static let stdParam: Float = 1 // Standard deviation used for normalization of the input image.
    }
    
    private var interpreter: Interpreter // Interpreter object for running the TensorFlow Lite model.
    private var inputTensor: Tensor // Input tensor for the model.
    private var outputTensor: Tensor // Output tensor of the model.
    private var cropRegion: DetectionArea? // The region of the image that was cropped and resized for the current inference.
    private var isProcessing = false // Flag to check if a model is busy processing an image.
    
    // MARK: - Init
    
    init() throws {
        // Load the TensorFlow Lite model from the app's bundle.
        guard let modelPath = Bundle.main.path(forResource: Configuration.modelFileName, ofType: "tflite") else {
            fatalError("Can not load model.")
        }
        // Set up the interpreter with the specified options and delegates.
        var options = Interpreter.Options()
        options.threadCount = Configuration.defaultThreadCount
        var delegates = [MetalDelegate()]
        interpreter = try Interpreter(modelPath: modelPath, options: options, delegates: delegates)
        // Allocate the tensors for the model.
        try interpreter.allocateTensors()
        inputTensor = try interpreter.input(at: 0)
        outputTensor = try interpreter.output(at: 0)
    }
    
    
    // MARK: - Public methods
    
    /**
     Performs pose detection on a given pixel buffer image.
     
     - Parameter pixelBuffer: The pixel buffer image to perform pose detection on.
     
     - Throws: An `EstimatorError` if an error occurs during the preprocessing, inference, or postprocessing stages.
     
     - Returns: A tuple containing the detected keypoints, the total score, a list of confidence scores for each keypoint, and a list of x-y coordinates for each keypoint.
     */
    func detectPose(on pixelBuffer: CVPixelBuffer) throws -> ([KeyPoint], Float32, [Float32], [[Float]]) {
        guard !isProcessing else { throw EstimatorError.modelBusyError }
        isProcessing = true
        defer { isProcessing = false }
        // Preprocess the input image and convert it to a tensor.
        guard let data = preprocess(pixelBuffer) else {
            throw  EstimatorError.preprocessError
        }
        do {
            // Copy the input tensor data to the interpreter.
            try interpreter.copy(data, toInputAt: 0)
            // Run the interpreter.
            try interpreter.invoke()
            // Get the output tensor.
            outputTensor = try interpreter.output(at: 0)
        } catch _ { throw  EstimatorError.inferenceError }
        // Postprocess the output tensor to get the detected keypoints, the total score, and the confidence scores for each keypoint.
        let (result, score, pointsList, positionArray) = postprocess(imageSize: pixelBuffer.size, modelOutput: outputTensor)
        
        guard let points = result else {
            throw  EstimatorError.postprocessError
        }
        // Return the detected keypoints, the total score, and the confidence scores and coordinates for each keypoint.
        return (points, score, pointsList, positionArray)
    }
    
    
    private func preprocess(_ pixelBuffer: CVPixelBuffer) -> Data? {
        let sourcePixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)
        let dimensions = inputTensor.shape.dimensions
        let inputWidth = CGFloat(dimensions[1])
        let inputHeight = CGFloat(dimensions[2])
        let imageWidth = pixelBuffer.size.width
        let imageHeight = pixelBuffer.size.height
        
        let cropRegion = self.cropRegion ?? initialCropRegion(imageWidth: imageWidth, imageHeight: imageHeight)
        self.cropRegion = cropRegion
        
        let rectF = DetectionArea(
            left: cropRegion.left * imageWidth,
            top: cropRegion.top * imageHeight,
            right: cropRegion.right * imageWidth,
            bottom: cropRegion.bottom * imageHeight)
        
        let modelSize = CGSize(width: inputWidth, height: inputHeight)
        guard let thumbnail = pixelBuffer.cropAndResize(fromRect: rectF.rect, toSize: modelSize) else { return nil }
        guard let inputData = thumbnail.rgbData(
            isModelQuantized: inputTensor.dataType == .uInt8,
            imageMean: Configuration.meanParam,
            imageStd: Configuration.stdParam)
        else { return nil }
        return inputData
    }
    
    
    private func postprocess(imageSize: CGSize, modelOutput: Tensor) -> ([KeyPoint]?, Float32, [Float32], [[Float]]) {
        let imgWidth = imageSize.width
        let imgHeight = imageSize.height
        let crop = self.cropRegion ?? initialCropRegion(imageWidth: imgWidth, imageHeight: imgHeight)
        let minX: CGFloat = crop.left * imgWidth
        let minY: CGFloat = crop.top * imgHeight
        let output = modelOutput.data.toArray(type: Float32.self)
        let dim = modelOutput.shape.dimensions
        let numKeyPoints = dim[2]
        let inputWidth = CGFloat(inputTensor.shape.dimensions[1])
        let inputHeight = CGFloat(inputTensor.shape.dimensions[2])
        let widthRatio = (crop.width * imgWidth / inputWidth)
        let heightRatio = (crop.height * imgHeight / inputHeight)
        var pos: [CGFloat] = []
        var posArr: [[Float]] = []
        var totalScoreSum: Float32 = 0
        var kpts: [KeyPoint] = []
        for idx in 0..<numKeyPoints {
            let x = ((CGFloat(output[idx * 3 + 1]) * inputWidth) * widthRatio) + minX
            let y = ((CGFloat(output[idx * 3 + 0]) * inputHeight) * heightRatio) + minY
            pos.append(x)
            pos.append(y)
            posArr.append([Float(output[idx * 3 + 1]), Float(output[idx * 3 + 0])])
            let score = output[idx * 3 + 2]
            totalScoreSum += score
            let keyPt = KeyPoint(
                bodyPart: Joint.allCases[idx], coordinate: CGPoint(x: x, y: y), score: score)
            kpts.append(keyPt)
        }
        self.cropRegion = nextFrameCropArea(keyPoints: kpts, imageWidth: imgWidth, imageHeight: imgHeight)
        let totalScore = totalScoreSum / Float32(numKeyPoints)
        
        return (kpts, totalScore, output, posArr)
    }
    
    
    private func nextFrameCropArea(keyPoints: [KeyPoint], imageWidth: CGFloat, imageHeight: CGFloat) -> DetectionArea {
        let targetKeyPoints = keyPoints.map { keyPoint in
            KeyPoint.init(bodyPart: keyPoint.bodyPart,
                          coordinate: CGPoint(x: keyPoint.coordinate.x, y: keyPoint.coordinate.y),
                          score: keyPoint.score)
        }
        if torsoVisible(keyPoints) {
            let centerX =
            (targetKeyPoints[Joint.leftHip.position].coordinate.x
             + targetKeyPoints[Joint.rightHip.position].coordinate.x) / 2.0
            let centerY =
            (targetKeyPoints[Joint.leftHip.position].coordinate.y
             + targetKeyPoints[Joint.rightHip.position].coordinate.y) / 2.0
            
            let torsoAndBodyDistances =
            calculateTorsoBodyDist(
                keyPoints: keyPoints, targetKeyPoints: targetKeyPoints, centerX: centerX, centerY: centerY
            )
            
            let list = [
                torsoAndBodyDistances.maxTorsoXDistance * CGFloat(Configuration.torsoRatio),
                torsoAndBodyDistances.maxTorsoYDistance * CGFloat(Configuration.torsoRatio),
                torsoAndBodyDistances.maxBodyXDistance * CGFloat(Configuration.bodyRatio),
                torsoAndBodyDistances.maxBodyYDistance * CGFloat(Configuration.bodyRatio),
            ]
            
            var cropLengthHalf = list.max() ?? 0.0
            let tmp: [CGFloat] = [
                centerX, CGFloat(imageWidth) - centerX, centerY, CGFloat(imageHeight) - centerY,
            ]
            cropLengthHalf = min(cropLengthHalf, tmp.max() ?? 0.0)
            let cropCornerY = centerY - cropLengthHalf
            let cropCornerX = centerX - cropLengthHalf
            if cropLengthHalf > (CGFloat(max(imageWidth, imageHeight)) / 2.0) {
                return initialCropRegion(imageWidth: imageWidth, imageHeight: imageHeight)
            } else {
                let cropLength = cropLengthHalf * 2
                return DetectionArea(
                    left: max(cropCornerX, 0) / imageWidth,
                    top: max(cropCornerY, 0) / imageHeight,
                    right: min((cropCornerX + cropLength) / imageWidth, 1),
                    bottom: min((cropCornerY + cropLength) / imageHeight, 1))
            }
        } else {
            return initialCropRegion(imageWidth: imageWidth, imageHeight: imageHeight)
        }
    }
    
    
    private func initialCropRegion(imageWidth: CGFloat, imageHeight: CGFloat) -> DetectionArea {
        var xMin: CGFloat
        var yMin: CGFloat
        var width: CGFloat
        var height: CGFloat
        if imageWidth > imageHeight {
            height = 1
            width = imageHeight / imageWidth
            yMin = 0
            xMin = ((imageWidth - imageHeight) / 2.0) / imageWidth
        } else {
            width = 1
            height = imageWidth / imageHeight
            xMin = 0
            yMin = ((imageHeight - imageWidth) / 2.0) / imageHeight
        }
        return DetectionArea(left: xMin, top: yMin, right: xMin + width, bottom: yMin + height)
    }
    
    
    private func torsoVisible(_ keyPoints: [KeyPoint]) -> Bool {
        return
        ((keyPoints[Joint.leftHip.position].score > Configuration.minPointScore
          || keyPoints[Joint.rightHip.position].score > Configuration.minPointScore))
        && ((keyPoints[Joint.leftShoulder.position].score > Configuration.minPointScore
             || keyPoints[Joint.rightShoulder.position].score > Configuration.minPointScore))
    }
    
    
    
    private func calculateTorsoBodyDist(
        keyPoints: [KeyPoint], targetKeyPoints: [KeyPoint], centerX: CGFloat, centerY: CGFloat
    ) -> TorsoBodyDist {
        let torsoJoints = [
            Joint.leftShoulder.position,
            Joint.rightShoulder.position,
            Joint.leftHip.position,
            Joint.rightHip.position,
        ]
        
        let maxTorsoYRange = torsoJoints.lazy.map { abs(centerY - targetKeyPoints[$0].coordinate.y) }
            .max() ?? 0.0
        let maxTorsoXRange = torsoJoints.lazy.map { abs(centerX - targetKeyPoints[$0].coordinate.x) }
            .max() ?? 0.0
        
        let confidentKeypoints = keyPoints.lazy.filter( {$0.score < Configuration.minPointScore} )
        let maxBodyYRange = confidentKeypoints.map(   { abs(centerY - $0.coordinate.y) }).max() ?? 0.0
        let maxBodyXRange = confidentKeypoints.map({ abs(centerX - $0.coordinate.x) }).max() ?? 0.0
        
        return TorsoBodyDist(
            maxTorsoYDistance: maxTorsoYRange,
            maxTorsoXDistance: maxTorsoXRange,
            maxBodyYDistance: maxBodyYRange,
            maxBodyXDistance: maxBodyXRange)
    }
}

