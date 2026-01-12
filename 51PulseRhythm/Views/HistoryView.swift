//
//  HistoryView.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var historyService = SessionHistoryService.shared
    @State private var selectedFilter: FilterOption = .all
    @State private var selectedTechnique: BreathingTechnique?
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
    }
    
    var filteredSessions: [SessionResult] {
        getFilteredSessions()
    }
    
    private func getFilteredSessions() -> [SessionResult] {
        let calendar = Calendar.current
        let now = Date()
        var sessions: [SessionResult] = []
        
        switch selectedFilter {
        case .all:
            sessions = historyService.getSessions(for: selectedTechnique)
        case .today:
            let today = calendar.startOfDay(for: now)
            let allSessions = historyService.sessions
            sessions = allSessions.filter { session in
                let sessionDay = calendar.startOfDay(for: session.sessionDate)
                return sessionDay == today
            }
        case .week:
            if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) {
                let allSessions = historyService.sessions
                sessions = allSessions.filter { $0.sessionDate >= weekAgo }
            } else {
                sessions = historyService.sessions
            }
        case .month:
            if let monthAgo = calendar.date(byAdding: .day, value: -30, to: now) {
                let allSessions = historyService.sessions
                sessions = allSessions.filter { $0.sessionDate >= monthAgo }
            } else {
                sessions = historyService.sessions
            }
        }
        
        return sessions.sorted { first, second in
            first.sessionDate > second.sessionDate
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.prBackground
                    .ignoresSafeArea()
                
                if historyService.sessions.isEmpty {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(.white)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !historyService.sessions.isEmpty {
                        Menu {
                            Button(role: .destructive, action: {
                                historyService.deleteAllSessions()
                            }) {
                                Label("Clear All", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Sessions Yet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("Complete your first session to see history here")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                StatisticsCardsView()
                filterPickerView
                techniqueFilterView
                sessionsListView
            }
            .padding(.top)
        }
    }
    
    private var filterPickerView: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(FilterOption.allCases, id: \.self) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var techniqueFilterView: some View {
        Group {
            if !historyService.sessions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(
                            title: "All Techniques",
                            isSelected: selectedTechnique == nil
                        ) {
                            selectedTechnique = nil
                        }
                        
                        ForEach(uniqueTechniques, id: \.id) { technique in
                            FilterChip(
                                title: technique.name,
                                isSelected: selectedTechnique?.id == technique.id
                            ) {
                                selectedTechnique = technique
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var uniqueTechniques: [BreathingTechnique] {
        let techniques = historyService.sessions.map { $0.technique }
        var unique: [BreathingTechnique] = []
        var seenIds: Set<UUID> = []
        
        for technique in techniques {
            if !seenIds.contains(technique.id) {
                unique.append(technique)
                seenIds.insert(technique.id)
            }
        }
        
        return unique
    }
    
    private var sessionsListView: some View {
        LazyVStack(spacing: 12) {
            ForEach(filteredSessions, id: \.sessionDate) { session in
                SessionHistoryCard(session: session)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

struct StatisticsCardsView: View {
    @StateObject private var historyService = SessionHistoryService.shared
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                StatCard(
                    title: "Total Sessions",
                    value: "\(historyService.getTotalSessions())",
                    icon: "flame.fill",
                    color: .prInhale
                )
                
                StatCard(
                    title: "Total Time",
                    value: formatTime(historyService.getTotalTime()),
                    icon: "clock.fill",
                    color: .prExhale
                )
                
                StatCard(
                    title: "Current Streak",
                    value: "\(historyService.getCurrentStreak()) days",
                    icon: "calendar.badge.clock",
                    color: .prInhale
                )
                
                StatCard(
                    title: "Avg Calmness",
                    value: String(format: "%.0f%%", historyService.getAverageCalmness()),
                    icon: "leaf.fill",
                    color: .prExhale
                )
            }
            .padding(.horizontal)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 120)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.prInhale : Color.gray.opacity(0.2))
                )
        }
    }
}

struct SessionHistoryCard: View {
    let session: SessionResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.technique.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(session.sessionDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(formatTime(session.totalTime))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.prInhale)
            }
            
            HStack(spacing: 20) {
                Label("\(session.completedCycles) cycles", systemImage: "repeat")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Label(String(format: "%.0f%%", session.rhythmStability), systemImage: "waveform.path")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Label(String(format: "%.0f%%", session.calmnessLevel), systemImage: "leaf.fill")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if !session.achievements.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(session.achievements, id: \.self) { achievement in
                            Text(achievement)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.prExhale.opacity(0.2))
                                .foregroundColor(.prExhale)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    HistoryView()
}
