// FIX: Replace the historical RevenueCat paywall with the included-access explanation.
// The original purchase implementation is preserved on original-source.
import SwiftUI

struct KyoPlus: View {
    var color: Color = .accentColor
    var onboard: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            Text("Kyo+ is included")
                .font(.headline)
            Text("All Kyo+ features are enabled in this source archive. No purchase is needed.")
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
