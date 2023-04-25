//
//  CVPixelBuffer+Additions.swift
//  ExersizeAssesment
//
//  Created by Yelyzaveta Boiarchuk on 20.03.2023.
//

import Foundation
import Accelerate

extension CVPixelBuffer {
    
    var size: CGSize {
        return CGSize(width: CVPixelBufferGetWidth(self), height: CVPixelBufferGetHeight(self))
    }
    
    func resized(to size: CGSize) -> CVPixelBuffer? {
        let imageWidth = CVPixelBufferGetWidth(self)
        let imageHeight = CVPixelBufferGetHeight(self)
        let pixelBufferType = CVPixelBufferGetPixelFormatType(self)
        guard
            pixelBufferType == kCVPixelFormatType_32BGRA || pixelBufferType == kCVPixelFormatType_32ARGB
        else {
            return nil
        }
        let inputImageRowBytes = CVPixelBufferGetBytesPerRow(self)
        let imageChannels = 4
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        guard let inputBaseAddress = CVPixelBufferGetBaseAddress(self) else {
            return nil
        }
        var inputVImageBuffer = vImage_Buffer(
            data: inputBaseAddress, height: UInt(imageHeight), width: UInt(imageWidth),
            rowBytes: inputImageRowBytes)
        
        let scaledImageRowBytes = Int(size.width) * imageChannels
        guard let scaledImageBytes = malloc(Int(size.height) * scaledImageRowBytes) else {
            return nil
        }
        
        var scaledVImageBuffer = vImage_Buffer(
            data: scaledImageBytes, height: UInt(size.height), width: UInt(size.width),
            rowBytes: scaledImageRowBytes)
        
        let scaleError = vImageScale_ARGB8888(
            &inputVImageBuffer, &scaledVImageBuffer, nil, vImage_Flags(0))
        
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        
        guard scaleError == kvImageNoError else {
            return nil
        }
        
        let releaseCallBack: CVPixelBufferReleaseBytesCallback = { mutablePointer, pointer in
            if let pointer = pointer {
                free(UnsafeMutableRawPointer(mutating: pointer))
            }
        }
        var scaledPixelBuffer: CVPixelBuffer?
        
        let conversionStatus = CVPixelBufferCreateWithBytes(
            nil, Int(size.width), Int(size.height), pixelBufferType, scaledImageBytes,
            scaledImageRowBytes, releaseCallBack, nil, nil, &scaledPixelBuffer)
        
        guard conversionStatus == kCVReturnSuccess else {
            free(scaledImageBytes)
            return nil
        }
        return scaledPixelBuffer
    }
    
    
    func cropAndResize(fromRect source: CGRect, toSize size: CGSize) -> CVPixelBuffer? {
        let inputImageRowBytes = CVPixelBufferGetBytesPerRow(self)
        let imageChannels = 4
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        defer { CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0)) }
        
        guard
            let inputBaseAddress = CVPixelBufferGetBaseAddress(self)?.advanced(
                by: Int(source.minY) * inputImageRowBytes + Int(source.minX) * imageChannels)
        else {
            return nil
        }
        
        var croppedImage = vImage_Buffer(
            data: inputBaseAddress, height: UInt(source.height), width: UInt(source.width),
            rowBytes: inputImageRowBytes)
        
        let resultRowBytes = Int(size.width) * imageChannels
        guard let resultAddress = malloc(Int(size.height) * resultRowBytes) else {
            return nil
        }
        
        var resizedImage = vImage_Buffer(
            data: resultAddress,
            height: UInt(size.height), width: UInt(size.width),
            rowBytes: resultRowBytes
        )
        
        let error = vImageScale_ARGB8888(&croppedImage, &resizedImage, nil, vImage_Flags(0))
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        if error != kvImageNoError {
            os_log("Error scaling the image.", type: .error)
            free(resultAddress)
            return nil
        }
        
        let releaseCallBack: CVPixelBufferReleaseBytesCallback = { mutablePointer, pointer in
            if let pointer = pointer {
                free(UnsafeMutableRawPointer(mutating: pointer))
            }
        }
        
        var result: CVPixelBuffer?
        
        let conversionStatus = CVPixelBufferCreateWithBytes(
            nil,
            Int(size.width), Int(size.height),
            CVPixelBufferGetPixelFormatType(self),
            resultAddress,
            resultRowBytes,
            releaseCallBack,
            nil,
            nil,
            &result
        )
        
        guard conversionStatus == kCVReturnSuccess else {
            free(resultAddress)
            return nil
        }
        return result
    }
    
    func rgbData(isModelQuantized: Bool, imageMean: Float, imageStd: Float) -> Data? {
        CVPixelBufferLockBaseAddress(self, .readOnly)
        defer {
            CVPixelBufferUnlockBaseAddress(self, .readOnly)
        }
        guard let sourceData = CVPixelBufferGetBaseAddress(self) else {
            return nil
        }
        
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let sourceBytesPerRow = CVPixelBufferGetBytesPerRow(self)
        let destinationChannelCount = 3
        let destinationBytesPerRow = destinationChannelCount * width
        
        var sourceBuffer = vImage_Buffer(
            data: sourceData,
            height: vImagePixelCount(height),
            width: vImagePixelCount(width),
            rowBytes: sourceBytesPerRow)
        
        guard let destinationData = malloc(height * destinationBytesPerRow) else {
            os_log("Error: out of memory.", type: .error)
            return nil
        }
        
        defer {
            free(destinationData)
        }
        
        var destinationBuffer = vImage_Buffer(
            data: destinationData,
            height: vImagePixelCount(height),
            width: vImagePixelCount(width),
            rowBytes: destinationBytesPerRow)
        
        if CVPixelBufferGetPixelFormatType(self) == kCVPixelFormatType_32BGRA {
            vImageConvert_BGRA8888toRGB888(&sourceBuffer, &destinationBuffer, UInt32(kvImageNoFlags))
        } else if CVPixelBufferGetPixelFormatType(self) == kCVPixelFormatType_32ARGB {
            vImageConvert_ARGB8888toRGB888(&sourceBuffer, &destinationBuffer, UInt32(kvImageNoFlags))
        }
        
        let byteData = Data(bytes: destinationBuffer.data, count: destinationBuffer.rowBytes * height)
        if isModelQuantized {
            return byteData
        }
        let bytes = [UInt8](byteData)
        let floats = bytes.map { (Float($0) - imageMean) / imageStd }
        return Data(copyingBufferOf: floats)
    }
}
