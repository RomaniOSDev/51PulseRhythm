//
//  PulseRhythmWidget.swift
//  51PulseRhythm Widget Extension
//
//  Created by Роман Главацкий on 12.01.2026.
//

import WidgetKit
import SwiftUI

struct PulseRhythmWidget: Widget {
    let kind: String = "PulseRhythmWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PulseRhythmTimelineProvider()) { entry in
            PulseRhythmWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Pulse Rhythm")
        .description("Quick access to breathing sessions and your daily streak.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct PulseRhythmTimelineProvider: TimelineProvider {
    typealias Entry = PulseRhythmWidgetEntry
    
    func placeholder(in context: Context) -> PulseRhythmWidgetEntry {
        PulseRhythmWidgetEntry(
            date: Date(),
            totalSessions: 0,
            currentStreak: 0,
            totalTime: 0
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PulseRhythmWidgetEntry) -> Void) {
        let entry = PulseRhythmWidgetEntry(
            date: Date(),
            totalSessions: SessionHistoryService.shared.getTotalSessions(),
            currentStreak: SessionHistoryService.shared.getCurrentStreak(),
            totalTime: SessionHistoryService.shared.getTotalTime()
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = PulseRhythmWidgetEntry(
            date: Date(),
            totalSessions: SessionHistoryService.shared.getTotalSessions(),
            currentStreak: SessionHistoryService.shared.getCurrentStreak(),
            totalTime: SessionHistoryService.shared.getTotalTime()
        )
        
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct PulseRhythmWidgetEntry: TimelineEntry {
    let date: Date
    let totalSessions: Int
    let currentStreak: Int
    let totalTime: TimeInterval
}

struct PulseRhythmWidgetEntryView: View {
    var entry: PulseRhythmTimelineProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            Color.prBackground
            
            switch family {
            case .systemSmall:
                SmallWidgetView(entry: entry)
            case .systemMedium:
                MediumWidgetView(entry: entry)
            default:
                SmallWidgetView(entry: entry)
            }
        }
    }
}

struct SmallWidgetView: View {
    let entry: PulseRhythmWidgetEntry
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "lungs.fill")
                    .font(.title2)
                    .foregroundColor(.prInhale)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.currentStreak)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Day Streak")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(entry.totalSessions)")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Sessions")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Link(destination: URL(string: "pulserhythm://start")!) {
                    Image(systemName: "play.circle.fill")
                        .font(.title3)
                        .foregroundColor(.prInhale)
                }
            }
        }
        .padding()
    }
}

struct MediumWidgetView: View {
    let entry: PulseRhythmWidgetEntry
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lungs.fill")
                        .font(.title2)
                        .foregroundColor(.prInhale)
                    Text("Pulse Rhythm")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    StatRow(icon: "flame.fill", value: "\(entry.currentStreak)", label: "Day Streak", color: .prInhale)
                    StatRow(icon: "clock.fill", value: formatTime(entry.totalTime), label: "Total Time", color: .prExhale)
                    StatRow(icon: "repeat", value: "\(entry.totalSessions)", label: "Sessions", color: .prInhale)
                }
            }
            
            Spacer()
            
            Link(destination: URL(string: "pulserhythm://start")!) {
                VStack(spacing: 8) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.prInhale)
                    Text("Start")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.prInhale.opacity(0.2))
                .cornerRadius(12)
            }
        }
        .padding()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}

struct StatRow: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

// Preview helpers for iOS 16+
@available(iOS 17.0, *)
struct WidgetPreviewHelper {
    static func smallPreview() -> some View {
        PulseRhythmWidgetEntryView(entry: PulseRhythmWidgetEntry(
            date: Date(),
            totalSessions: 42,
            currentStreak: 7,
            totalTime: 3600
        ))
    }
    
    static func mediumPreview() -> some View {
        PulseRhythmWidgetEntryView(entry: PulseRhythmWidgetEntry(
            date: Date(),
            totalSessions: 42,
            currentStreak: 7,
            totalTime: 3600
        ))
    }
}
