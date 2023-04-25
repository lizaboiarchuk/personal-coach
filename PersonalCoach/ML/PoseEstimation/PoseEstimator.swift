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
        static let modelFileName = "movenet_thunder"
        static let defaultThreadCount = 16
        static let minimumScore: Float32 = 0.2
        static let torsoRatio: Float = 1.9
        static let bodyRatio: Float = 1.2
        static let minPointScore: Float = 0.4
        static let meanParam: Float = 0
        static let stdParam: Float = 1
    }
    
    private var interpreter: Interpreter
    private var inputTensor: Tensor
    private var outputTensor: Tensor
    private var cropRegion: DetectionArea?
    private var isProcessing = false
    
    // MARK: - Init
    init() throws {
        guard let modelPath = Bundle.main.path(forResource: Configuration.modelFileName, ofType: "tflite") else {
            fatalError("Can not load model.")
        }
        var options = Interpreter.Options()
        options.threadCount = Configuration.defaultThreadCount
        var delegates = [MetalDelegate()]
        interpreter = try Interpreter(modelPath: modelPath, options: options, delegates: delegates)
        try interpreter.allocateTensors()
        inputTensor = try interpreter.input(at: 0)
        outputTensor = try interpreter.output(at: 0)
    }
    
    
    // MARK: - Public methods
    func detectPose(on pixelBuffer: CVPixelBuffer) throws -> ([KeyPoint], Float32, [Float32], [[Float]]) {
        guard !isProcessing else { throw EstimatorError.modelBusyError }
        isProcessing = true
        defer { isProcessing = false }
        guard let data = preprocess(pixelBuffer) else {
            throw  EstimatorError.preprocessError
        }
        do {
            try interpreter.copy(data, toInputAt: 0)
            try interpreter.invoke()
            outputTensor = try interpreter.output(at: 0)
        } catch _ { throw  EstimatorError.inferenceError }
        let (result, score, pointsList, positionArray) = postprocess(imageSize: pixelBuffer.size, modelOutput: outputTensor)
        
        guard let points = result else {
            throw  EstimatorError.postprocessError
        }
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

