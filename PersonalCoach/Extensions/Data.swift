//
//  Data.swift
//  ExersizeAssesment
//
//  Created by Yelyzaveta Boiarchuk on 20.03.2023.
//

import Foundation

// MARK: - Data
extension Data {

  init<T>(copyingBufferOf array: [T]) {
    self = array.withUnsafeBufferPointer(Data.init)
  }

  func toArray<T>(type: T.Type) -> [T] where T: AdditiveArithmetic {
    var array = [T](repeating: T.zero, count: self.count / MemoryLayout<T>.stride)
    _ = array.withUnsafeMutableBytes { self.copyBytes(to: $0) }
    return array
  }
}
