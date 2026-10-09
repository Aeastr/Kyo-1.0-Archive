import SwiftUI

extension View {
    func wiggling(wiggle: Binding<Bool>) -> some View {
        modifier(WiggleModifier(wiggle: wiggle))
    }
}

struct WiggleModifier: ViewModifier {
    @State private var isWiggling = false
    @Binding var wiggle: Bool

    private static func randomize(interval: TimeInterval, withVariance variance: Double) -> TimeInterval {
        let random = (Double(arc4random_uniform(1000)) - 500.0) / 500.0
        return interval + variance * random
    }

    private let rotateAnimation = Animation
        .easeInOut(
            duration: WiggleModifier.randomize(
                interval: 0.14,
                withVariance: 0.025
            )
        )
        .repeatForever(autoreverses: true)

    private let bounceAnimation = Animation
        .easeInOut(
            duration: WiggleModifier.randomize(
                interval: 0.18,
                withVariance: 0.025
            )
        )
        .repeatForever(autoreverses: true)

    func body(content: Content) -> some View {
        if wiggle{
            content
                .rotationEffect(.degrees(isWiggling ? wiggle ? 2.0 : 0 : 0))
                .animation(rotateAnimation, value: isWiggling)
                .offset(x: 0, y: isWiggling ? wiggle ? 2.0 : 0 : 0)
                .animation(bounceAnimation, value: isWiggling)
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isWiggling.toggle()
                    }

                }
        }
        else{
            content
        }
    }
}
