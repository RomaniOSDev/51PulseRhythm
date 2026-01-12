//
//  SettingsView.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.prBackground
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Session Settings").foregroundColor(.white)) {
                        Picker("Default Duration", selection: $viewModel.defaultSessionDuration) {
                            ForEach(SessionDuration.allCases, id: \.self) { duration in
                                Text(duration.displayName).tag(duration)
                            }
                        }
                        .foregroundColor(.white)
                        
                        Picker("Difficulty Level", selection: $viewModel.difficultyLevel) {
                            ForEach(DifficultyLevel.allCases, id: \.self) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        .foregroundColor(.white)
                    }
                    .listRowBackground(Color.gray.opacity(0.1))
                    
                    Section(header: Text("Feedback").foregroundColor(.white)) {
                        Toggle("Sound Cues", isOn: $viewModel.soundEnabled)
                            .foregroundColor(.white)
                        
                        Toggle("Haptic Feedback", isOn: $viewModel.hapticEnabled)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.gray.opacity(0.1))
                    
                    Section(header: Text("About").foregroundColor(.white)) {
                        Button(action: {
                            rateApp()
                        }) {
                            HStack {
                                Text("Rate Us")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                        
                        Button(action: {
                            openPrivacyPolicy()
                        }) {
                            HStack {
                                Text("Privacy Policy")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(.prInhale)
                            }
                        }
                        
                        Button(action: {
                            openTermsOfService()
                        }) {
                            HStack {
                                Text("Terms of Service")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(.prExhale)
                            }
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.1))
                }
                .scrollContentBackground(.hidden)
                .onChange(of: viewModel.defaultSessionDuration) { _ in
                    viewModel.saveSettings()
                }
                .onChange(of: viewModel.soundEnabled) { _ in
                    viewModel.saveSettings()
                }
                .onChange(of: viewModel.hapticEnabled) { _ in
                    viewModel.saveSettings()
                }
                .onChange(of: viewModel.difficultyLevel) { _ in
                    viewModel.saveSettings()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(.white)
        }
        .preferredColorScheme(.dark)
    }
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://example.com/privacy-policy") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTermsOfService() {
        if let url = URL(string: "https://example.com/terms-of-service") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsView()
}
