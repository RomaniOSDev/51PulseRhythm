//
//  SettingsViewModel.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import Foundation
import Combine

enum SessionDuration: Int, CaseIterable {
    case three = 180
    case five = 300
    case ten = 600
    
    var displayName: String {
        switch self {
        case .three:
            return "3 min"
        case .five:
            return "5 min"
        case .ten:
            return "10 min"
        }
    }
}

enum DifficultyLevel: String, CaseIterable {
    case beginner = "Beginner"
    case advanced = "Advanced"
}

class SettingsViewModel: ObservableObject {
    @Published var defaultSessionDuration: SessionDuration = .five
    @Published var soundEnabled: Bool = true
    @Published var hapticEnabled: Bool = true
    @Published var difficultyLevel: DifficultyLevel = .beginner
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let sessionDuration = "defaultSessionDuration"
        static let soundEnabled = "soundEnabled"
        static let hapticEnabled = "hapticEnabled"
        static let difficultyLevel = "difficultyLevel"
    }
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        if let durationRaw = userDefaults.object(forKey: Keys.sessionDuration) as? Int,
           let duration = SessionDuration(rawValue: durationRaw) {
            defaultSessionDuration = duration
        }
        
        soundEnabled = userDefaults.object(forKey: Keys.soundEnabled) as? Bool ?? true
        hapticEnabled = userDefaults.object(forKey: Keys.hapticEnabled) as? Bool ?? true
        
        if let difficultyRaw = userDefaults.string(forKey: Keys.difficultyLevel),
           let difficulty = DifficultyLevel(rawValue: difficultyRaw) {
            difficultyLevel = difficulty
        }
    }
    
    func saveSettings() {
        userDefaults.set(defaultSessionDuration.rawValue, forKey: Keys.sessionDuration)
        userDefaults.set(soundEnabled, forKey: Keys.soundEnabled)
        userDefaults.set(hapticEnabled, forKey: Keys.hapticEnabled)
        userDefaults.set(difficultyLevel.rawValue, forKey: Keys.difficultyLevel)
    }
}
