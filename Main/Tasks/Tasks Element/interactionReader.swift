//
//  interactionReader.swift
//  KyoNeo
//
//

import SwiftUI

extension View {
    func delaysTouches(for duration: TimeInterval = 0.25, action: @escaping () -> Void = {}) -> some View {
        modifier(DelaysTouches(duration: duration, action: action))
    }
}

fileprivate struct DelaysTouches: ViewModifier {
    @State private var disabled = false
    private let duration: TimeInterval
    private let action: () -> Void

    init(duration: TimeInterval, action: @escaping () -> Void) {
        self.duration = duration
        self.action = action
    }

    func body(content: Content) -> some View {
        Button(action: action) {
            content
        }
        .buttonStyle(DelaysTouchesButtonStyle(
            disabled: $disabled,
            duration: duration
        ))
        .disabled(disabled)
    }
}

fileprivate struct DelaysTouchesButtonStyle: ButtonStyle {
    @Binding private var disabled: Bool
    @State private var touchDownDate: Date?
    private let duration: TimeInterval

    init(disabled: Binding<Bool>, duration: TimeInterval) {
        _disabled = disabled
        self.duration = duration
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed, perform: handleIsPressed)
    }

    private func handleIsPressed(isPressed: Bool) {
        if isPressed {
            let date = Date()
            touchDownDate = date

            DispatchQueue.main.asyncAfter(deadline: .now() + max(duration, 0)) {
                if date == touchDownDate {
                    disabled = true

                    DispatchQueue.main.async {
                        disabled = false
                    }
                }
            }
        } else {
            touchDownDate = nil
            disabled = false
        }
    }
}

struct InteractionReaderViewModifier: ViewModifier {

    var longPressSensitivity: Int
    var tapAction: () -> Void
    var longPressAction: () -> Void
    var scaleEffect: Bool = true

    @State private var isPressing: Bool = Bool()
    @State private var currentDismissId: DispatchTime = DispatchTime.now()
    @State private var lastInteractionKind: String = String()

    func body(content: Content) -> some View {

        let processedContent = content
            .gesture(gesture)
            .onChange(of: isPressing) { newValue in

                currentDismissId = DispatchTime.now() + .milliseconds(longPressSensitivity)
                let dismissId: DispatchTime = currentDismissId

                if isPressing {

                    DispatchQueue.main.asyncAfter(deadline: dismissId) {

                        if isPressing { if (dismissId == currentDismissId) { lastInteractionKind = "longPress"; longPressAction() } }

                    }

                }
                else {

                    if (lastInteractionKind != "longPress") { lastInteractionKind = "tap"; tapAction() }

                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {lastInteractionKind = "none"}


                }

            }

        return Group {

            if scaleEffect { processedContent.scaleEffect(lastInteractionKind == "longPress" ? 1.5: (lastInteractionKind == "tap" ? 0.8 : 1.0 )) }
            else { processedContent }

        }

    }

    var gesture: some Gesture {

        DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
            .onChanged() { _ in if !isPressing { isPressing = true } }
            .onEnded() { _ in isPressing = false }

    }
}

extension View {

    func interactionReader(longPressSensitivity: Int, tapAction: @escaping () -> Void, longPressAction: @escaping () -> Void, scaleEffect: Bool = true) -> some View {

        return self.modifier(InteractionReaderViewModifier(longPressSensitivity: longPressSensitivity, tapAction: tapAction, longPressAction: longPressAction, scaleEffect: scaleEffect))

    }

}
