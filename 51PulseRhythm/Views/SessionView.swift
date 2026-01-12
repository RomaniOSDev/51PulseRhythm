//
//  SessionView.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import SwiftUI
import AudioToolbox

struct SessionView: View {
    let technique: BreathingTechnique
    @StateObject private var viewModel: SessionViewModel
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var animationScale: CGFloat = 0.5
    @State private var animationOpacity: Double = 0.5
    @State private var metronomePosition: CGFloat = 0
    @Environment(\.dismiss) var dismiss
    @State private var navigateToResults = false
    
    init(technique: BreathingTechnique, sessionDuration: TimeInterval = 300, totalCycles: Int = 10) {
        self.technique = technique
        _viewModel = StateObject(wrappedValue: SessionViewModel(
            technique: technique,
            sessionDuration: sessionDuration,
            totalCycles: totalCycles
        ))
    }
    
    var body: some View {
        ZStack {
            Color.prBackground
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Top bar with timer and cycles
                HStack {
                    VStack(alignment: .leading) {
                        Text("Time Remaining")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(formatTime(viewModel.timeRemaining))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Cycles")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(viewModel.completedCycles)/\(viewModel.totalCycles)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                
                Spacer()
                
                // Central visualizer
                ZStack {
                    // Background circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    currentPhaseColor.opacity(0.2),
                                    Color.prBackground
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 200
                            )
                        )
                        .frame(width: 300, height: 300)
                    
                    // Animated circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    currentPhaseColor.opacity(animationOpacity),
                                    currentPhaseColor.opacity(animationOpacity * 0.5)
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 150
                            )
                        )
                        .frame(width: 200 * animationScale, height: 200 * animationScale)
                        .blur(radius: 20)
                    
                    // Phase indicator
                    VStack(spacing: 8) {
                        Text(viewModel.currentPhase.displayName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(currentPhaseColor)
                        
                        Text("\(viewModel.phaseTimeRemaining)s")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .frame(height: 300)
                
                Spacer()
                
                // Rhythm bar with metronome
                VStack(spacing: 12) {
                    Text("Follow the rhythm")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background bar
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 8)
                            
                            // Colored bar
                            RoundedRectangle(cornerRadius: 4)
                                .fill(currentPhaseColor)
                                .frame(width: geometry.size.width * CGFloat(viewModel.phaseTimeRemaining) / CGFloat(getCurrentPhaseDuration()), height: 8)
                            
                            // Metronome dot
                            Circle()
                                .fill(Color.white)
                                .frame(width: 16, height: 16)
                                .offset(x: metronomePosition * geometry.size.width - 8)
                        }
                    }
                    .frame(height: 20)
                }
                .padding(.horizontal)
                
                // Control buttons
                HStack(spacing: 20) {
                    Button(action: {
                        viewModel.pauseSession()
                    }) {
                        Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        viewModel.endSession()
                        navigateToResults = true
                    }) {
                        Text("End")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 60)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(30)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            viewModel.startSession()
            startAnimations()
        }
        .onChange(of: viewModel.currentPhase) { _ in
            triggerFeedback()
            // Small delay to ensure phase is updated before starting animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startAnimations()
            }
        }
        .onChange(of: viewModel.phaseTimeRemaining) { newValue in
            updateMetronome()
        }
        .background(
            Group {
                if let result = viewModel.sessionResult {
                    NavigationLink(
                        destination: ResultsView(result: result),
                        isActive: $navigateToResults
                    ) {
                        EmptyView()
                    }
                }
            }
        )
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    viewModel.endSession()
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private var currentPhaseColor: Color {
        switch viewModel.currentPhase {
        case .inhale:
            return .prInhale
        case .exhale:
            return .prExhale
        case .hold1, .hold2:
            return viewModel.currentPhase == .hold1 ? .prInhale : .prExhale
        }
    }
    
    private func getCurrentPhaseDuration() -> Int {
        switch viewModel.currentPhase {
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
    
    private func startAnimations() {
        let duration = Double(getCurrentPhaseDuration())
        
        switch viewModel.currentPhase {
        case .inhale:
            // Reset to initial state without animation
            animationScale = 0.5
            animationOpacity = 0.5
            // Animate to expanded state
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: duration)) {
                    self.animationScale = 1.2
                    self.animationOpacity = 0.8
                }
            }
        case .exhale:
            // Reset to expanded state without animation
            animationScale = 1.0
            animationOpacity = 0.6
            // Animate to contracted state
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: duration)) {
                    self.animationScale = 0.5
                    self.animationOpacity = 0.3
                }
            }
        case .hold1, .hold2:
            // Reset to neutral state
            animationScale = 1.0
            animationOpacity = 0.5
            // Animate pulsing
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    self.animationScale = 1.1
                }
            }
        }
    }
    
    private func updateMetronome() {
        let duration = Double(getCurrentPhaseDuration())
        let progress = 1.0 - (Double(viewModel.phaseTimeRemaining) / duration)
        metronomePosition = progress
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func triggerFeedback() {
        if settingsViewModel.hapticEnabled {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        
        if settingsViewModel.soundEnabled {
            // Simple system sound for phase change
            AudioServicesPlaySystemSound(1057)
        }
    }
}

#Preview {
    NavigationView {
        SessionView(technique: BreathingTechnique.techniques[0])
    }
}
