//
//  SessionViewModel.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import Foundation
import Combine
import SwiftUI

class SessionViewModel: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var isPaused: Bool = false
    @Published var currentPhase: BreathingPhase = .inhale
    @Published var timeRemaining: TimeInterval = 0
    @Published var phaseTimeRemaining: Int = 0
    @Published var completedCycles: Int = 0
    @Published var totalCycles: Int = 10
    @Published var sessionDuration: TimeInterval = 300 // 5 minutes default
    
    @Published var sessionResult: SessionResult?
    
    private var technique: BreathingTechnique
    private var timer: Timer?
    private var phaseTimer: Timer?
    private var sessionStartTime: Date?
    private var phaseStartTime: Date?
    private var cancellables = Set<AnyCancellable>()
    
    // Rhythm tracking
    private var phaseTransitions: [Date] = []
    private var expectedPhaseDurations: [Int] = []
    
    init(technique: BreathingTechnique, sessionDuration: TimeInterval = 300, totalCycles: Int = 10) {
        self.technique = technique
        self.sessionDuration = sessionDuration
        self.totalCycles = totalCycles
        self.timeRemaining = sessionDuration
        
        setupExpectedDurations()
    }
    
    private func setupExpectedDurations() {
        expectedPhaseDurations = [
            technique.inhaleDuration,
            technique.hold1Duration,
            technique.exhaleDuration,
            technique.hold2Duration
        ]
    }
    
    func startSession() {
        guard !isPlaying else { return }
        isPlaying = true
        isPaused = false
        sessionStartTime = Date()
        startPhase(.inhale)
        startTimers()
    }
    
    func pauseSession() {
        isPaused.toggle()
        if isPaused {
            timer?.invalidate()
            phaseTimer?.invalidate()
        } else {
            startTimers()
        }
    }
    
    func endSession() {
        timer?.invalidate()
        phaseTimer?.invalidate()
        isPlaying = false
        isPaused = false
        
        let totalTime = sessionDuration - timeRemaining
        let stability = calculateRhythmStability()
        let calmness = calculateCalmnessLevel(stability: stability)
        let achievements = calculateAchievements(stability: stability)
        
        sessionResult = SessionResult(
            technique: technique,
            totalTime: totalTime,
            completedCycles: completedCycles,
            rhythmStability: stability,
            calmnessLevel: calmness,
            achievements: achievements
        )
        
        // Save to history and update achievements
        if let result = sessionResult {
            SessionHistoryService.shared.saveSession(result)
            AchievementService.shared.updateAchievements(with: result)
        }
    }
    
    private func startTimers() {
        // Main session timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            self.timeRemaining -= 0.1
            if self.timeRemaining <= 0 {
                self.endSession()
            }
        }
        
        // Phase timer
        updatePhaseTimer()
    }
    
    private func updatePhaseTimer() {
        phaseTimer?.invalidate()
        phaseTimeRemaining = getCurrentPhaseDuration()
        
        phaseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            self.phaseTimeRemaining -= 1
            if self.phaseTimeRemaining <= 0 {
                self.moveToNextPhase()
            }
        }
    }
    
    private func startPhase(_ phase: BreathingPhase) {
        currentPhase = phase
        phaseStartTime = Date()
        phaseTimeRemaining = getCurrentPhaseDuration()
        phaseTransitions.append(Date())
        updatePhaseTimer()
    }
    
    private func moveToNextPhase() {
        phaseTransitions.append(Date())
        
        switch currentPhase {
        case .inhale:
            if technique.hold1Duration > 0 {
                startPhase(.hold1)
            } else {
                startPhase(.exhale)
            }
        case .hold1:
            startPhase(.exhale)
        case .exhale:
            if technique.hold2Duration > 0 {
                startPhase(.hold2)
            } else {
                completeCycle()
            }
        case .hold2:
            completeCycle()
        }
    }
    
    private func completeCycle() {
        completedCycles += 1
        if completedCycles >= totalCycles || timeRemaining <= 0 {
            endSession()
        } else {
            startPhase(.inhale)
        }
    }
    
    private func getCurrentPhaseDuration() -> Int {
        switch currentPhase {
        case .inhale:
            return technique.inhaleDuration
        case .hold1:
            return technique.hold1Duration
        case .exhale:
            return technique.exhaleDuration
        case .hold2:
            return technique.hold2Duration
        }
    }
    
    private func calculateRhythmStability() -> Double {
        guard phaseTransitions.count >= 2 else { return 0.0 }
        
        var correctTransitions = 0
        var totalTransitions = 0
        
        for i in 1..<phaseTransitions.count {
            let duration = phaseTransitions[i].timeIntervalSince(phaseTransitions[i-1])
            let expectedDuration = Double(expectedPhaseDurations[(i-1) % expectedPhaseDurations.count])
            
            if abs(duration - expectedDuration) <= 0.5 {
                correctTransitions += 1
            }
            totalTransitions += 1
        }
        
        return totalTransitions > 0 ? Double(correctTransitions) / Double(totalTransitions) * 100.0 : 0.0
    }
    
    private func calculateCalmnessLevel(stability: Double) -> Double {
        // Calmness is based on rhythm stability
        return stability
    }
    
    private func calculateAchievements(stability: Double) -> [String] {
        var achievements: [String] = []
        
        if completedCycles >= 1 {
            achievements.append("First Session")
        }
        if completedCycles >= 10 {
            achievements.append("10 Cycles in a Row")
        }
        if stability >= 90 {
            achievements.append("Perfect Rhythm")
        }
        
        return achievements
    }
    
    deinit {
        timer?.invalidate()
        phaseTimer?.invalidate()
    }
}
