//
//  OnboardingView.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.prBackground
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                OnboardingPage(
                    icon: "lungs.fill",
                    title: "Welcome to Pulse Rhythm",
                    description: "Master your breathing, find your calm. A beautiful way to practice meditation and reduce stress through guided breathing exercises.",
                    color: .prInhale
                )
                .tag(0)
                
                OnboardingPage(
                    icon: "waveform.path",
                    title: "Follow the Rhythm",
                    description: "Sync your breathing with visual guides and rhythm bars. Each technique is designed for different goals - sleep, focus, energy, or balance.",
                    color: .prExhale
                )
                .tag(1)
                
                OnboardingPage(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track Your Progress",
                    description: "Monitor your meditation journey with detailed statistics, achievements, and streaks. Build a daily habit of mindfulness.",
                    color: .prInhale
                )
                .tag(2)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            VStack {
                Spacer()
                
                if currentPage == 2 {
                    Button(action: {
                        OnboardingService.shared.markOnboardingAsSeen()
                        isPresented = false
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.prInhale, Color.prInhale.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.prInhale.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        Text("Next")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                
                Image(systemName: icon)
                    .font(.system(size: 80))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
