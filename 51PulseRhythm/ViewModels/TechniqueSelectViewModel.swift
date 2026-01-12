//
//  TechniqueSelectViewModel.swift
//  51PulseRhythm
//
//  Created by Роман Главацкий on 12.01.2026.
//

import Foundation
import Combine

class TechniqueSelectViewModel: ObservableObject {
    @Published var techniques: [BreathingTechnique] = BreathingTechnique.techniques
    @Published var selectedTechnique: BreathingTechnique?
    
    func selectTechnique(_ technique: BreathingTechnique) {
        selectedTechnique = technique
    }
}
