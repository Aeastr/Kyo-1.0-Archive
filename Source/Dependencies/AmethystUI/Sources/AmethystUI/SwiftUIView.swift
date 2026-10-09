//
//  SwiftUIView.swift
//
//
//  Created by Aether on 28/07/2023.
//

import SwiftUI

//public struct SelectionValue: Int {}

public struct TabViewTest: View {
    @Binding var selection: Int?
    @State private var internalSelection: Int = 0

    public init(selection: Binding<Int>? = nil) {
        self._selection = Binding(
            get: { selection?.wrappedValue },
            set: { newValue in
                if let binding = selection, let newValue = newValue {
                    binding.wrappedValue = newValue
                } else if let binding = selection{
                    binding.wrappedValue = 1
                    // Replace 'defaultValue' with the appropriate default value
                    // if SelectionValue is an optional type itself, use `nil` as the default value
                    // for non-optional types, you need to provide a proper default value
                    print("Warning: Attempting to set value to nil binding.")
                }
            }
        )
    }

    public var body: some View {
        VStack {
            let selectionVariable = selection != nil ? selection.unsafelyUnwrapped : internalSelection
            Text("Hello, World")

            Text("\(selectionVariable)")
                .onTapGesture {
                    if let selectionX = selection{
                        selection = selectionX + 1
                    }
                    else{
                        internalSelection = internalSelection + 1
                    }
                }
        }
    }
}

#Preview {
    TestView()
}

struct TestView: View {
    @State var value = 6

    var body: some View {
        VStack {
            Spacer()
            TabViewTest(selection: $value)
            Spacer()
            TabViewTest()
            Spacer()
        }
    }
}
