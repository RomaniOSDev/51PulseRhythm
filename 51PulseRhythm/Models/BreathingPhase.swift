//
//  BreathingPhase.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import Foundation

enum BreathingPhase: String, CaseIterable {
    case inhale = "Inhale"
    case hold1 = "Hold"
    case exhale = "Exhale"
    case hold2 = "Pause"
    
    var displayName: String {
        return self.rawValue
    }
}
