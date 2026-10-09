//
//  ResourcesView.swift
//  KyoNeo
//
//  Created by Aether on 14/08/2023.
//

import SwiftUI
import AmethystUI

struct ResourcesView: View {
    @State var scrolled: Bool = false
    var color: Color = .purple
    var body: some View {
        ScrollView{
            ScrollDetector(scrolled: $scrolled)
            let rows: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
            LazyVGrid(columns: rows, spacing: 16) {
                Group{
                    HStack{
                        Image(systemName: "a.book.closed")
                        Text("Grades")

                    }
                    .font(.title3)
                    .frame(height: 120)
                    Text("Placeholder")

                    .frame(height: 120)
                    Text("Placeholder")
                        .frame(height: 120)
                    Text("Placeholder")
                        .frame(height: 120)
                }
                .frame(maxWidth: .infinity)
                .regularOutline()
            }
            .padding(.horizontal, 20)

        }
        .coordinateSpace(name: "scroll")
        .safeAreaInset(edge: .top, content: {
            Color.clear.frame(height: 80)
        })
        .overlay(alignment: .top){
            FluidNavigationBar(title: "Resources", titleColor: .primary,   tintColor: color, compactMode: true, scrolled: $scrolled, content: {
                
                
            }, toolbar: {
                Text("")
            })
        }

    }
}

#Preview {
    ResourcesView()
}
