//
//  Achievement.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import Foundation

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let targetValue: Int
    var currentProgress: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    enum AchievementCategory: String, Codable, CaseIterable {
        case sessions = "Sessions"
        case time = "Time"
        case cycles = "Cycles"
        case streak = "Streak"
        case stability = "Stability"
    }
    
    static let allAchievements: [Achievement] = [
        // Session achievements
        Achievement(
            id: "first_session",
            title: "First Steps",
            description: "Complete your first breathing session",
            icon: "star.fill",
            category: .sessions,
            targetValue: 1,
            currentProgress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "10_sessions",
            title: "Dedicated",
            description: "Complete 10 sessions",
            icon: "flame.fill",
            category: .sessions,
            targetValue: 10,
            currentProgress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "50_sessions",
            title: "Committed",
            description: "Complete 50 sessions",
            icon: "trophy.fill",
            category: .sessions,
            targetValue: 50,
            currentProgress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "100_sessions",
            title: "Master",
            description: "Complete 100 sessions",
            icon: "crown.fill",
            category: .sessions,
            targetValue: 100,
            currentProgress: 0,
            isUnlocked: false
        ),
        
        // Time achievements
        Achievement(
            id: "1_hour",
            title: "Hour of Peace",
            description: "Meditate for 1 hour total",
            icon: "clock.fill",
            category: .time,
            targetValue: 3600,
            currentProgress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "10_hours",
            title: "Zen Master",
            description: "Meditate for 10 hours total",
            icon: "moon.stars.fill",
            category: .time,
            targetValue: 36000,
            currentProgress: 0,
            isUnlocked: false
        ),
        
        // Cycle achievements
        Achievement(
            id: "perfect_10",
            title: "Perfect 10",
            description: "Complete 10 cycles in one session",
            icon: "10.circle.fill",
            category: .cycles,
            targetValue: 10,
            currentProgress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "perfect_50",
            title: "Endurance",
            description: "Complete 50 cycles in one session",
            icon: "infinity",
            category: .cycles,
            targetValue: 50,
            currentProgress: 0,
            isUnlocked: false
        ),
        
        // Streak achievements
        Achievement(
            id: "3_day_streak",
            title: "Three Day Streak",
            description: "Meditate for 3 days in a row",
            icon: "calendar",
            category: .streak,
            targetValue: 3,
            currentProgress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "7_day_streak",
            title: "Week Warrior",
            description: "Meditate for 7 days in a row",
            icon: "calendar.badge.clock",
            category: .streak,
            targetValue: 7,
            currentProgress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "30_day_streak",
            title: "Monthly Master",
            description: "Meditate for 30 days in a row",
            icon: "calendar.badge.exclamationmark",
            category: .streak,
            targetValue: 30,
            currentProgress: 0,
            isUnlocked: false
        ),
        
        // Stability achievements
        Achievement(
            id: "perfect_rhythm",
            title: "Perfect Rhythm",
            description: "Achieve 90% rhythm stability",
            icon: "waveform.path",
            category: .stability,
            targetValue: 90,
            currentProgress: 0,
            isUnlocked: false
        ),
        Achievement(
            id: "zen_master",
            title: "Zen Master",
            description: "Achieve 95% rhythm stability",
            icon: "leaf.fill",
            category: .stability,
            targetValue: 95,
            currentProgress: 0,
            isUnlocked: false
        )
    ]
    
    var progressPercentage: Double {
        guard targetValue > 0 else { return 0 }
        return min(Double(currentProgress) / Double(targetValue) * 100, 100)
    }
}
