//
//  OnboardingService.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import Foundation

class OnboardingService {
    static let shared = OnboardingService()
    
    private let userDefaults = UserDefaults.standard
    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    
    private init() {}
    
    var hasSeenOnboarding: Bool {
        get {
            userDefaults.bool(forKey: hasSeenOnboardingKey)
        }
        set {
            userDefaults.set(newValue, forKey: hasSeenOnboardingKey)
        }
    }
    
    func markOnboardingAsSeen() {
        hasSeenOnboarding = true
    }
}
