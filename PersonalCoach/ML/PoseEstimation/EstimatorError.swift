//
//  PoseEstimationError.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 25.04.2023.
//

import Foundation

enum EstimatorError: Error {
  case modelBusyError
  case preprocessError
  case inferenceError
  case postprocessError
}
