//
//  CustomTemplates.swift
//  KyoNeo
//
//  Created by Aether on 28/08/2023.
//

import SwiftUI
import AmethystUI

struct CustomTemplates: View {
    var color: Color = Color.accentColor
    @Environment(\.dismiss) var dismiss
    @State var scrolled: Bool = false
    var body: some View {
        ScrollView{

        }
        .overlay(alignment: .top) {
            FluidNavigationBar(title: "Templates",   tintColor: color, scrolled: $scrolled) {

                Button {

                    dismiss()
                } label: {
                    Text("Done" )
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                }
                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
            } toolbar: {

            }

        }
    }
}

#Preview {
    CustomTemplates()
}
