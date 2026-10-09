//
//  settingsHoldButton.swift
//  KyoNeo
//
//  Created by Aether on 26/09/2023.
//

import SwiftUI

struct settingsHoldButton: View {
    @State private var counter = 0
    @State private var timer: Timer?
    @State private var hide: Bool = false
    @State private var showSheet = false

    @AppStorage("debug") var debug: Bool = false

    var body: some View {
        Button(action: {
            if self.counter < 20{
                hide = false
                self.counter += 1

               

            }

            if let timer = self.timer {
                timer.invalidate()
            }

            self.timer = Timer.scheduledTimer(withTimeInterval: 1.4, repeats: true) { _ in
                if self.counter > 9 {
                    self.counter = 0
                }

                if self.counter > 0 {
                    hide = true
                    self.counter -= 1
                }

            }

            if self.counter == 10 {

                debug.toggle()
            }
        }) {
            Text("Kyo\(counter != 0 ? ", \(hide ? "going down.." : counter < 6 ? "keep going.." : counter < 9 ? "almost.." :  counter > 9 ? "Debug Toggled" : "one more! " ) \(counter < 10 ? "\(counter)" : "")" : "")")
                .contentTransition(counter != 0 ? .numericText() : .opacity)
                .font(.caption)
        }
        .buttonStyle(bounceButton())
        .foregroundStyle(Color.primary)
        .animation(.smooth)
      
    }
}

#Preview {
    settingsHoldButton()
}

