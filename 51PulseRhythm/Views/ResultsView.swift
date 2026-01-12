//
//  ResultsView.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import SwiftUI

struct ResultsView: View {
    let result: SessionResult
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.prBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Session Complete")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(result.technique.name)
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .padding(.top)
                    
                    // Stats cards
                    VStack(spacing: 16) {
                        ResultStatCard(
                            title: "Total Time",
                            value: formatTime(result.totalTime),
                            icon: "clock.fill",
                            color: .prInhale
                        )
                        
                        ResultStatCard(
                            title: "Cycles Completed",
                            value: "\(result.completedCycles)",
                            icon: "repeat",
                            color: .prExhale
                        )
                        
                        ResultStatCard(
                            title: "Rhythm Stability",
                            value: String(format: "%.1f%%", result.rhythmStability),
                            icon: "waveform.path",
                            color: .prInhale
                        )
                        
                        ResultStatCard(
                            title: "Calmness Level",
                            value: String(format: "%.1f%%", result.calmnessLevel),
                            icon: "leaf.fill",
                            color: .prExhale
                        )
                    }
                    .padding(.horizontal)
                    
                    // Calmness chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Calmness Level")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 30)
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [.prInhale, .prExhale],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * CGFloat(result.calmnessLevel) / 100, height: 30)
                            }
                        }
                        .frame(height: 30)
                    }
                    .padding(.horizontal)
                    
                    // Achievements
                    if !result.achievements.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Achievements")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            ForEach(result.achievements, id: \.self) { achievement in
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text(achievement)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Back to Techniques")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.prInhale)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct ResultStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        ResultsView(result: SessionResult(
            technique: BreathingTechnique.techniques[0],
            totalTime: 300,
            completedCycles: 8,
            rhythmStability: 85.5,
            calmnessLevel: 88.2,
            achievements: ["First Session", "10 Cycles in a Row"]
        ))
    }
}
