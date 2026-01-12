//
//  AchievementsView.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import SwiftUI

struct AchievementsView: View {
    @StateObject private var achievementService = AchievementService.shared
    @State private var selectedCategory: Achievement.AchievementCategory? = nil
    
    var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievementService.getAchievementsByCategory(category)
        }
        return achievementService.achievements
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.prBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Summary
                        VStack(spacing: 8) {
                            Text("\(achievementService.getUnlockedAchievements().count)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.prInhale)
                            
                            Text("of \(achievementService.achievements.count) Achievements")
                                .font(.title3)
                                .foregroundColor(.gray)
                            
                            Text("Unlocked")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(.top)
                        
                        // Category Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                CategoryChip(
                                    title: "All",
                                    isSelected: selectedCategory == nil
                                ) {
                                    selectedCategory = nil
                                }
                                
                                ForEach(Achievement.AchievementCategory.allCases, id: \.self) { category in
                                    CategoryChip(
                                        title: category.rawValue,
                                        isSelected: selectedCategory == category
                                    ) {
                                        selectedCategory = category
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Achievements Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(filteredAchievements) { achievement in
                                AchievementCard(achievement: achievement)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(.white)
        }
        .preferredColorScheme(.dark)
    }
}

struct CategoryChip: View {
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

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked ?
                        LinearGradient(
                            colors: [Color.prInhale.opacity(0.3), Color.prExhale.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? .prInhale : .gray)
            }
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            if !achievement.isUnlocked {
                VStack(spacing: 4) {
                    ProgressView(value: achievement.progressPercentage, total: 100)
                        .tint(.prInhale)
                        .scaleEffect(x: 1, y: 0.8)
                    
                    Text("\(achievement.currentProgress)/\(achievement.targetValue)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.prExhale)
                    
                    if let date = achievement.unlockedDate {
                        Text(date, style: .date)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    achievement.isUnlocked ?
                    Color.prInhale.opacity(0.1) :
                    Color.gray.opacity(0.1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            achievement.isUnlocked ?
                            Color.prInhale.opacity(0.3) :
                            Color.clear,
                            lineWidth: 1
                        )
                )
        )
    }
}

#Preview {
    AchievementsView()
}
