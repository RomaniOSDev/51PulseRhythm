//
//  ContentView.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var showOnboarding = !OnboardingService.shared.hasSeenOnboarding
    
    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView(isPresented: $showOnboarding)
            } else {
                TechniqueSelectView()
            }
        }
    }
}

#Preview {
    ContentView()
}
