//
//  SessionHistoryService.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import Foundation
import Combine

class SessionHistoryService: ObservableObject {
    static let shared = SessionHistoryService()
    
    @Published var sessions: [SessionResult] = []
    
    private let userDefaults = UserDefaults.standard
    private let sessionsKey = "savedSessions"
    
    private init() {
        loadSessions()
    }
    
    func saveSession(_ session: SessionResult) {
        sessions.append(session)
        saveSessions()
    }
    
    func deleteSession(_ session: SessionResult) {
        sessions.removeAll { $0.sessionDate == session.sessionDate }
        saveSessions()
    }
    
    func deleteAllSessions() {
        sessions.removeAll()
        saveSessions()
    }
    
    func getSessions(for technique: BreathingTechnique? = nil) -> [SessionResult] {
        if let technique = technique {
            return sessions.filter { $0.technique.id == technique.id }
        }
        return sessions.sorted { $0.sessionDate > $1.sessionDate }
    }
    
    func getTotalSessions() -> Int {
        return sessions.count
    }
    
    func getTotalTime() -> TimeInterval {
        return sessions.reduce(0) { $0 + $1.totalTime }
    }
    
    func getAverageCalmness() -> Double {
        guard !sessions.isEmpty else { return 0 }
        return sessions.reduce(0) { $0 + $1.calmnessLevel } / Double(sessions.count)
    }
    
    func getAverageStability() -> Double {
        guard !sessions.isEmpty else { return 0 }
        return sessions.reduce(0) { $0 + $1.rhythmStability } / Double(sessions.count)
    }
    
    func getSessionsThisWeek() -> [SessionResult] {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        
        return sessions.filter { $0.sessionDate >= weekAgo }
    }
    
    func getCurrentStreak() -> Int {
        guard !sessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        let sortedSessions = sessions.sorted { $0.sessionDate > $1.sessionDate }
        
        for session in sortedSessions {
            let sessionDate = calendar.startOfDay(for: session.sessionDate)
            
            if sessionDate == currentDate {
                streak += 1
                if let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) {
                    currentDate = previousDay
                } else {
                    break
                }
            } else if sessionDate < currentDate {
                break
            }
        }
        
        return streak
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            userDefaults.set(encoded, forKey: sessionsKey)
        }
    }
    
    private func loadSessions() {
        if let data = userDefaults.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([SessionResult].self, from: data) {
            sessions = decoded.sorted { $0.sessionDate > $1.sessionDate }
        }
    }
}
