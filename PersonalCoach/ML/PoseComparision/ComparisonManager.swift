//
//  PoseComparer.swift
//  PersonalCoach
//
//  Created by Yelyzaveta Boiarchuk on 09.04.2023.
//

import Foundation


final class ComparisonManager {
    
    // MARK: - Private properties
    private struct PrecalculatedPositionsData: Codable { let array: [[[Float]]] }
    private let decoder = JSONDecoder()
    private let tagretPositions: [[[Float]]]
    private var aligner: PositionComparer
    
    
    //MARK: - Init
    init() {
        if let url = Bundle.main.url(forResource: "coach-3-mirror", withExtension: "json") {
            do {
                let jsonData = try Data(contentsOf: url)
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                let jsonDataEncoded = try JSONSerialization.data(withJSONObject: jsonObject)
                let jsonString = String(data: jsonDataEncoded, encoding: .utf8)
                let myData = try decoder.decode(PrecalculatedPositionsData.self, from: jsonDataEncoded)
                self.tagretPositions = myData.array
            } catch {
                self.tagretPositions = []
            }
        }
        else {
            self.tagretPositions = []
        }
        self.aligner = PositionComparer(targetSequence: self.tagretPositions)
        self.aligner.prepare()
    }
    
     
    // MARK: - Public Methods
    func receive(positions: [[Float]]) -> (Float, Bool) {
        return self.aligner.receive(positions: positions)
    }
    
    
    func getDeviatedLines() -> [Int] {
        aligner.getDeviatedLines()
    }
}
