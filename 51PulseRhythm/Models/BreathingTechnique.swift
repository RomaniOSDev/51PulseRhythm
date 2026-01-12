//
//  BreathingTechnique.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import Foundation

struct BreathingTechnique: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let inhaleDuration: Int // seconds
    let hold1Duration: Int // seconds
    let exhaleDuration: Int // seconds
    let hold2Duration: Int // seconds
    
    var totalCycleDuration: Int {
        return inhaleDuration + hold1Duration + exhaleDuration + hold2Duration
    }
    
    static let techniques: [BreathingTechnique] = [
        BreathingTechnique(
            id: UUID(),
            name: "4-7-8",
            description: "For falling asleep",
            inhaleDuration: 4,
            hold1Duration: 7,
            exhaleDuration: 8,
            hold2Duration: 0
        ),
        BreathingTechnique(
            id: UUID(),
            name: "Box Breathing",
            description: "For concentration",
            inhaleDuration: 4,
            hold1Duration: 4,
            exhaleDuration: 4,
            hold2Duration: 4
        ),
        BreathingTechnique(
            id: UUID(),
            name: "Boxing",
            description: "For energy",
            inhaleDuration: 4,
            hold1Duration: 0,
            exhaleDuration: 4,
            hold2Duration: 4
        ),
        BreathingTechnique(
            id: UUID(),
            name: "Coherent",
            description: "For balance",
            inhaleDuration: 6,
            hold1Duration: 0,
            exhaleDuration: 6,
            hold2Duration: 0
        )
    ]
}
