//
//  SessionResult.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import Foundation

struct SessionResult: Codable {
    let technique: BreathingTechnique
    let totalTime: TimeInterval
    let completedCycles: Int
    let rhythmStability: Double // percentage 0-100
    let calmnessLevel: Double // percentage 0-100
    let achievements: [String]
    let sessionDate: Date
    
    init(technique: BreathingTechnique, totalTime: TimeInterval, completedCycles: Int, rhythmStability: Double = 0.0, calmnessLevel: Double = 0.0, achievements: [String] = []) {
        self.technique = technique
        self.totalTime = totalTime
        self.completedCycles = completedCycles
        self.rhythmStability = rhythmStability
        self.calmnessLevel = calmnessLevel
        self.achievements = achievements
        self.sessionDate = Date()
    }
}
