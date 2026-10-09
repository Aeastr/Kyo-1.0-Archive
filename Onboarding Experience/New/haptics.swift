//
//  haptics.swift
//  KyoNeo
//
//  Created by Aether on 18/07/2023.
//

import CoreHaptics
import SwiftUI

class HapticManager {
    private var engine: CHHapticEngine?

    init?() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return nil
        }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Error starting haptic engine: \(error)")
            return nil
        }
    }

    func playHaptic() {
        guard let engine = engine else { return }

        // Create a haptic event that represents the friction/hum feedback
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5) // Adjust the sharpness to control the "hum" effect
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 1.0)

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makeAdvancedPlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Error playing haptic feedback: \(error)")
        }
    }
}
