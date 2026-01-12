//
//  AchievementService.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import Foundation
import Combine

class AchievementService: ObservableObject {
    static let shared = AchievementService()
    
    @Published var achievements: [Achievement] = []
    
    private let userDefaults = UserDefaults.standard
    private let achievementsKey = "userAchievements"
    
    private init() {
        loadAchievements()
    }
    
    func updateAchievements(with session: SessionResult) {
        let historyService = SessionHistoryService.shared
        
        // Update session count achievements
        updateAchievement(id: "first_session", progress: historyService.getTotalSessions())
        updateAchievement(id: "10_sessions", progress: historyService.getTotalSessions())
        updateAchievement(id: "50_sessions", progress: historyService.getTotalSessions())
        updateAchievement(id: "100_sessions", progress: historyService.getTotalSessions())
        
        // Update time achievements
        let totalSeconds = Int(historyService.getTotalTime())
        updateAchievement(id: "1_hour", progress: totalSeconds)
        updateAchievement(id: "10_hours", progress: totalSeconds)
        
        // Update cycle achievements
        updateAchievement(id: "perfect_10", progress: session.completedCycles)
        updateAchievement(id: "perfect_50", progress: session.completedCycles)
        
        // Update streak achievements
        let streak = historyService.getCurrentStreak()
        updateAchievement(id: "3_day_streak", progress: streak)
        updateAchievement(id: "7_day_streak", progress: streak)
        updateAchievement(id: "30_day_streak", progress: streak)
        
        // Update stability achievements
        let stability = Int(session.rhythmStability)
        updateAchievement(id: "perfect_rhythm", progress: stability)
        updateAchievement(id: "zen_master", progress: stability)
        
        saveAchievements()
    }
    
    private func updateAchievement(id: String, progress: Int) {
        guard let index = achievements.firstIndex(where: { $0.id == id }) else { return }
        
        var achievement = achievements[index]
        
        if !achievement.isUnlocked {
            achievement.currentProgress = max(achievement.currentProgress, progress)
            
            if achievement.currentProgress >= achievement.targetValue {
                achievement.isUnlocked = true
                achievement.unlockedDate = Date()
            }
            
            achievements[index] = achievement
        }
    }
    
    func getUnlockedAchievements() -> [Achievement] {
        return achievements.filter { $0.isUnlocked }
    }
    
    func getLockedAchievements() -> [Achievement] {
        return achievements.filter { !$0.isUnlocked }
    }
    
    func getAchievementsByCategory(_ category: Achievement.AchievementCategory) -> [Achievement] {
        return achievements.filter { $0.category == category }
    }
    
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            userDefaults.set(encoded, forKey: achievementsKey)
        }
    }
    
    private func loadAchievements() {
        if let data = userDefaults.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        } else {
            // Initialize with default achievements
            achievements = Achievement.allAchievements
            saveAchievements()
        }
    }
}
