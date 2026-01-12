//
//  TechniqueSelectView.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import SwiftUI

struct TechniqueSelectView: View {
    @StateObject private var viewModel = TechniqueSelectViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @ObservedObject private var customService = CustomTechniqueService.shared
    @State private var selectedTechnique: BreathingTechnique?
    @State private var navigateToSession = false
    @State private var showCreateTechnique = false
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.prBackground,
                        Color.prBackground.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header section
                    VStack(spacing: 8) {
                        Text("Choose Your")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Breathing Technique")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    // Techniques grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(customService.getAllTechniques()) { technique in
                                TechniqueCard(
                                    technique: technique,
                                    isSelected: selectedTechnique?.id == technique.id,
                                    isCustom: customService.customTechniques.contains(where: { $0.id == technique.id })
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedTechnique = technique
                                    }
                                }
                            }
                            
                            // Add Custom Technique Card
                            Button(action: {
                                showCreateTechnique = true
                            }) {
                                VStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.gray.opacity(0.2)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "plus")
                                            .font(.title3)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Create Custom")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        
                                        Text("Add your own technique")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer(minLength: 0)
                                }
                                .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200, alignment: .topLeading)
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.gray.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                                .foregroundColor(.gray.opacity(0.3))
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                    
                    Spacer()
                }
                
                // Start Session Button
                VStack {
                    Spacer()
                    if let technique = selectedTechnique {
                        Button(action: {
                            navigateToSession = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                Text("Start Session")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
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
                        .padding(.bottom, 34)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: HistoryView()) {
                        Image(systemName: "clock.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        NavigationLink(destination: AchievementsView()) {
                            Image(systemName: "trophy.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                        }
                        
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .sheet(isPresented: $showCreateTechnique) {
                CreateTechniqueView()
            }
            .navigationDestination(isPresented: $navigateToSession) {
                if let technique = selectedTechnique {
                    SessionView(
                        technique: technique,
                        sessionDuration: TimeInterval(settingsViewModel.defaultSessionDuration.rawValue)
                    )
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct TechniqueCard: View {
    let technique: BreathingTechnique
    let isSelected: Bool
    var isCustom: Bool = false
    let action: () -> Void
    
    @ObservedObject private var customService = CustomTechniqueService.shared
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                // Header with icon
                HStack {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: isSelected ? [Color.prInhale.opacity(0.3), Color.prExhale.opacity(0.2)] : [Color.gray.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: iconForTechnique(technique.name))
                            .font(.title3)
                            .foregroundColor(isSelected ? .prInhale : .gray)
                    }
                    
                    Spacer()
                    
                    if isCustom {
                        Menu {
                            Button(action: {
                                showEditSheet = true
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive, action: {
                                showDeleteAlert = true
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.prInhale)
                    }
                }
                
                // Title and description
                VStack(alignment: .leading, spacing: 6) {
                    Text(technique.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Text(technique.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // Duration details
                VStack(alignment: .leading, spacing: 8) {
                    if technique.inhaleDuration > 0 {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.prInhale)
                                .frame(width: 8, height: 8)
                            Text("Inhale")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            Spacer(minLength: 4)
                            Text("\(technique.inhaleDuration)s")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.prInhale)
                                .lineLimit(1)
                        }
                    }
                    
                    if technique.hold1Duration > 0 {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 8, height: 8)
                            Text("Hold")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            Spacer(minLength: 4)
                            Text("\(technique.hold1Duration)s")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                    }
                    
                    if technique.exhaleDuration > 0 {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.prExhale)
                                .frame(width: 8, height: 8)
                            Text("Exhale")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            Spacer(minLength: 4)
                            Text("\(technique.exhaleDuration)s")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.prExhale)
                                .lineLimit(1)
                        }
                    }
                    
                    if technique.hold2Duration > 0 {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 8, height: 8)
                            Text("Pause")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            Spacer(minLength: 4)
                            Text("\(technique.hold2Duration)s")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200, alignment: .topLeading)
            .padding(20)
            .fixedSize(horizontal: false, vertical: false)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [
                                Color.prInhale.opacity(0.15),
                                Color.prExhale.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [
                                Color.gray.opacity(0.1),
                                Color.gray.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ?
                                LinearGradient(
                                    colors: [Color.prInhale.opacity(0.6), Color.prExhale.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 2 : 0
                            )
                    )
            )
            .shadow(color: isSelected ? Color.prInhale.opacity(0.2) : Color.clear, radius: 10, x: 0, y: 5)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showEditSheet) {
            CreateTechniqueView(technique: technique)
        }
        .alert("Delete Technique", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                customService.deleteTechnique(technique)
            }
        } message: {
            Text("Are you sure you want to delete \"\(technique.name)\"? This action cannot be undone.")
        }
    }
    
    private func iconForTechnique(_ name: String) -> String {
        switch name {
        case "4-7-8":
            return "moon.zzz.fill"
        case "Box Breathing":
            return "square.fill"
        case "Boxing":
            return "bolt.fill"
        case "Coherent":
            return "heart.fill"
        default:
            return "lungs.fill"
        }
    }
}

#Preview {
    TechniqueSelectView()
}
