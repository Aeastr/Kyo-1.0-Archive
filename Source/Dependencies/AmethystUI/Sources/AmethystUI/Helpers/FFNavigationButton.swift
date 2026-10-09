// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI


public enum scrolledLookBehaviourSetting{
    case regularOverlayMode
    case keepColor
    case noChange
}


public struct neoNavigationButton: ButtonStyle {
    // Properties
    var cornerRadius: CGFloat = 14
    var color: Color = .blue
    var scrolledLookBehaviour: scrolledLookBehaviourSetting = .regularOverlayMode
    var role: neoButtonRole = .regularAction
    @Environment(\.colorScheme) var colorScheme
    @Binding var scrolled: Bool

    // Public initializer
    public init(cornerRadius: CGFloat = 14,
                color: Color = .blue,
                scrolledLookBehaviour: scrolledLookBehaviourSetting = .regularOverlayMode,
                role: neoButtonRole = .regularAction,
                scrolled: Binding<Bool>) {
        self.cornerRadius = cornerRadius
        self.color = color
        self.scrolledLookBehaviour = scrolledLookBehaviour
        self.role = role
        self._scrolled = scrolled
    }

    // ButtonStyle method
    public func makeBody(configuration: Self.Configuration) -> some View {
        // Determine the actual color based on the button role
        let actualColor = (role == .regularAction ? color :
                            role == .destructive ? .red :
                            color
        )

        return configuration.label
            // Apply blend mode based on scrolledLookBehaviour setting
            .blendMode(scrolledLookBehaviour == .noChange ? .normal : .overlay)
            .overlay(
                // Apply different overlay styles based on scrolledLookBehaviour setting
                scrolledLookBehaviour == .regularOverlayMode ?
                    configuration.label.foregroundStyle(.primary).opacity(scrolled ? 0.6 : 1)
                :
                scrolledLookBehaviour == .keepColor ?
                    configuration.label.foregroundStyle(actualColor).opacity(scrolled ? 0.8 : 1)
                : nil
            )
            .frame(width: 25, height: 25)
            .padding(8)
            .foregroundColor(scrolled ? scrolledLookBehaviour == .noChange ? actualColor : .primary : actualColor)
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .opacity(configuration.isPressed ? 0.4 : 1)
            .background {
                Color("NeoButton", bundle: .module).opacity(colorScheme == .dark ? 0.6 : 0.3)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .shadow(color: actualColor.opacity(scrolled ? 0 : 0.3), radius: 7, x: 0, y: 8)
                    
                    .scaleEffect(configuration.isPressed ? 0.7 : 1.0)
                    .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            }
    }
}



struct neoGenericBlurButton: ButtonStyle {
    var cornerRadius: CGFloat = 14
    var color: Color = .blue
    var role: neoButtonRole = .regularAction
    @Environment(\.colorScheme) var colorScheme
    @Binding var scrolled: Bool

    func makeBody(configuration: Self.Configuration) -> some View {

        let actualColor = (role == .regularAction ? color :
                            role == .destructive ? .red :
                            color
        )
        configuration.label
            .foregroundColor(.primary)
            .blendMode(.overlay)
            .overlay{
                configuration.label.foregroundColor((scrolled ? Color.primary : actualColor).opacity(scrolled ? 0.5 : 1))
            }
            .frame(width: 25, height: 25)
            .padding(7)
            .scaleEffect(x: configuration.isPressed ? 1.2 : 1.0)

            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))

            .overlay(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).stroke(
                LinearGradient(gradient: Gradient(colors: [scrolled ? Color("outline1-scolledState", bundle: .module) : actualColor.opacity(0.2), scrolled ? Color("outline2-scolledState", bundle: .module) : actualColor.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                , lineWidth: 1))

        .scaleEffect(configuration.isPressed ? 0.7 : 1.0)
        .opacity(configuration.isPressed ? 0.4 : 1)
        .animation(.easeOut(duration: 0.2), value: configuration.isPressed)


    }
}



public enum neoButtonRole{
    case regularAction
    case destructive
    case cancel
    case create
}
