//
//  CherryCatView.swift
//  KyoNeo
//
//  Created by Aether on 27/09/2023.
//

import SwiftUI

struct CherryCatView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if colorScheme == .light {
            Image("cat")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .padding(.horizontal, 20)
                .colorInvert()
        }
        else{
            Image("cat")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .padding(.horizontal, 20)
        }
    }
}

#Preview {
    CherryCatView()
}
