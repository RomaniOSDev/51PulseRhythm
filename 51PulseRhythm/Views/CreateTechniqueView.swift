//
//  CreateTechniqueView.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import SwiftUI

struct CreateTechniqueView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var customService = CustomTechniqueService.shared
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var inhaleDuration: Int = 4
    @State private var hold1Duration: Int = 0
    @State private var exhaleDuration: Int = 4
    @State private var hold2Duration: Int = 0
    
    let editingTechnique: BreathingTechnique?
    
    init(technique: BreathingTechnique? = nil) {
        self.editingTechnique = technique
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.prBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Name and Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Name")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Enter technique name", text: $name)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Enter description", text: $description)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                        
                        // Duration Settings
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Breathing Phases")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            DurationSlider(
                                title: "Inhale",
                                icon: "arrow.down.circle",
                                color: .prInhale,
                                value: $inhaleDuration
                            )
                            
                            DurationSlider(
                                title: "Hold",
                                icon: "pause.circle",
                                color: .gray,
                                value: $hold1Duration
                            )
                            
                            DurationSlider(
                                title: "Exhale",
                                icon: "arrow.up.circle",
                                color: .prExhale,
                                value: $exhaleDuration
                            )
                            
                            DurationSlider(
                                title: "Pause",
                                icon: "pause.circle.fill",
                                color: .gray,
                                value: $hold2Duration
                            )
                        }
                        
                        // Preview
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Preview")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text(name.isEmpty ? "Technique Name" : name)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text(description.isEmpty ? "Description" : description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    if inhaleDuration > 0 {
                                        Label("Inhale: \(inhaleDuration)s", systemImage: "arrow.down.circle")
                                            .font(.caption)
                                            .foregroundColor(.prInhale)
                                    }
                                    if hold1Duration > 0 {
                                        Label("Hold: \(hold1Duration)s", systemImage: "pause.circle")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    if exhaleDuration > 0 {
                                        Label("Exhale: \(exhaleDuration)s", systemImage: "arrow.up.circle")
                                            .font(.caption)
                                            .foregroundColor(.prExhale)
                                    }
                                    if hold2Duration > 0 {
                                        Label("Pause: \(hold2Duration)s", systemImage: "pause.circle.fill")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(16)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(editingTechnique == nil ? "Create Technique" : "Edit Technique")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.white)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTechnique()
                    }
                    .foregroundColor(.prInhale)
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty || inhaleDuration == 0 || exhaleDuration == 0)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if let technique = editingTechnique {
                loadTechnique(technique)
            }
        }
    }
    
    private func loadTechnique(_ technique: BreathingTechnique) {
        name = technique.name
        description = technique.description
        inhaleDuration = technique.inhaleDuration
        hold1Duration = technique.hold1Duration
        exhaleDuration = technique.exhaleDuration
        hold2Duration = technique.hold2Duration
    }
    
    private func saveTechnique() {
        guard !name.isEmpty, inhaleDuration > 0, exhaleDuration > 0 else {
            return
        }
        
        let technique = BreathingTechnique(
            id: editingTechnique?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            inhaleDuration: inhaleDuration,
            hold1Duration: hold1Duration,
            exhaleDuration: exhaleDuration,
            hold2Duration: hold2Duration
        )
        
        if editingTechnique != nil {
            customService.updateTechnique(technique)
        } else {
            customService.addTechnique(technique)
        }
        
        // Small delay to ensure the service updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dismiss()
        }
    }
}

struct DurationSlider: View {
    let title: String
    let icon: String
    let color: Color
    @Binding var value: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.white)
                Spacer()
                Text("\(value)s")
                    .foregroundColor(color)
                    .fontWeight(.semibold)
            }
            
            Slider(value: Binding(
                get: { Double(value) },
                set: { value = Int($0) }
            ), in: 0...20, step: 1)
            .tint(color)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    CreateTechniqueView()
}
