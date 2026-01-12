//
//  CustomTechniqueService.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import Foundation
import Combine

class CustomTechniqueService: ObservableObject {
    static let shared = CustomTechniqueService()
    
    @Published var customTechniques: [BreathingTechnique] = []
    
    private let userDefaults = UserDefaults.standard
    private let customTechniquesKey = "customTechniques"
    
    private init() {
        loadCustomTechniques()
    }
    
    func addTechnique(_ technique: BreathingTechnique) {
        customTechniques.append(technique)
        saveCustomTechniques()
    }
    
    func updateTechnique(_ technique: BreathingTechnique) {
        if let index = customTechniques.firstIndex(where: { $0.id == technique.id }) {
            customTechniques[index] = technique
            saveCustomTechniques()
        }
    }
    
    func deleteTechnique(_ technique: BreathingTechnique) {
        customTechniques.removeAll { $0.id == technique.id }
        saveCustomTechniques()
    }
    
    func getAllTechniques() -> [BreathingTechnique] {
        return BreathingTechnique.techniques + customTechniques
    }
    
    private func saveCustomTechniques() {
        if let encoded = try? JSONEncoder().encode(customTechniques) {
            userDefaults.set(encoded, forKey: customTechniquesKey)
        }
    }
    
    private func loadCustomTechniques() {
        if let data = userDefaults.data(forKey: customTechniquesKey),
           let decoded = try? JSONDecoder().decode([BreathingTechnique].self, from: data) {
            customTechniques = decoded
        }
    }
}
