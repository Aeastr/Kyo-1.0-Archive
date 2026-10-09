// FIX: Replace the historical paywall with a local Pro preview setting.
// The original purchase implementation is preserved on original-source.
import SwiftUI

struct KyoPlus: View {
    var color: Color = .accentColor
    var onboard: Bool = false
    @AppStorage("archivePlusEnabled") private var proEnabled = true

    var body: some View {
        VStack(spacing: 12) {
            Text("Kyo+ in this archive")
                .font(.headline)
            Toggle("Pro", isOn: $proEnabled)
                .tint(color)
            Text("Explore the original free and Pro features. No purchase needed.")
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
