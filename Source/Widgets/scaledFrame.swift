//
//  ScaledFrame.swift
//
//
//  Created by Aether on 10/07/2023.
//

import SwiftUI

/// A custom SwiftUI view that provides a scaled frame for its content.
///
/// The `ScaledFrame` struct scales the frame's dimensions based on the user's preferred size settings in the system. It conforms to the `View` protocol, allowing it to be used as a view in SwiftUI.
///
/// Usage:
/// To use `ScaledFrame`, create an instance of it and pass in the desired width, height, alignment, and content to be displayed within the frame.
///
/// Example usage:
///
///     ScaledFrame(width: 200, height: 100, alignment: .center) {
///         Text("Hello, World!")
///     }
///
/// In this example, a `ScaledFrame` view is created with a fixed width of 200 points, a fixed height of 100 points, and centered alignment. The content of the frame is a `Text` view displaying the text "Hello, World!".
///
/// The `ScaledFrame` struct uses the `@ScaledMetric` property wrapper to enable scaling of the frame's dimensions.
///
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public struct ScaledFrame<Content>: View where Content: View {
    @ScaledMetric private var width: Double
    @ScaledMetric private var height: Double
    private var alignment: Alignment
    private var content: () -> Content

    /// Initializes a new instance of `ScaledFrame` with the provided parameters.
    ///
    /// - Parameters:
    ///   - width: The optional width of the frame. If not specified, the width will not be explicitly set.
    ///   - height: The optional height of the frame. If not specified, the height will not be explicitly set.
    ///   - alignment: The alignment of the content within the frame. Defaults to `.center`.
    ///   - content: A closure that returns the content to be displayed within the frame.
    ///
    public init(
        width: ScaledMetric<Double>? = nil,
        height: ScaledMetric<Double>? = nil,
        alignment: Alignment = .center,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _width = width ?? ScaledMetric(wrappedValue: -1)
        _height = height ?? ScaledMetric(wrappedValue: -1)
        self.alignment = alignment
        self.content = content
    }

    public var body: some View {
        content().frame(
            width: width > 0 ? width : nil,
            height: height > 0 ? height : nil,
            alignment: alignment
        )
    }
}

/// An extension on the `View` protocol to provide a convenient way to create a `ScaledFrame` view.
///
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension View {
    /// Applies a `ScaledFrame` to the current view, providing a scaled frame for its content.
    ///
    /// - Parameters:
    ///   - width: The optional width of the frame. If not specified, the width will not be explicitly set.
    ///   - height: The optional height of the frame. If not specified, the height will not be explicitly set.
    ///   - relativeTo: The text style to scale the width and height relative to.
    ///   - alignment: The alignment of the content within the frame. Defaults to `.center`.
    /// - Returns: A new view hierarchy that includes the `ScaledFrame` view.
    ///
    func scaledFrame(
        width: Double?,
        height: Double?,
        relativeTo textStyle: Font.TextStyle,
        alignment: Alignment = .center
    ) -> some View {
        ScaledFrame(
            width: width.flatMap { ScaledMetric(wrappedValue: $0, relativeTo: textStyle) },
            height: height.flatMap { ScaledMetric(wrappedValue: $0, relativeTo: textStyle) },
            alignment: alignment
        ) {
            self
        }
    }
}
