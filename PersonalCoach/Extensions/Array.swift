//
//  Array.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 25.04.2023.
//

import Foundation

extension Array where Element: FloatingPoint {
    func minIndex() -> Int? {
        guard var minValue = self.first else { return nil }
        var minIndex = 0

        for (index, value) in self.enumerated() {
            if value < minValue {
                minValue = value
                minIndex = index
            }
        }
        return minIndex
    }
}
