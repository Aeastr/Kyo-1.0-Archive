// FIX: RevenueCat is removed from the unlocked archive; original purchase code is on original-source.
//
//  AppIcon.swift
//  KyoNeo
//
//  Created by Aether on 12/07/2023.
//

import SwiftUI

#if os(iOS) || os(visionOS)
struct AppIcon: View {
    @AppStorage("activeAppIcon") var activeAppIcon: String = "AppIconDefault"
    var color = Color.indigo // Replace with your desired color
    var body: some View {
        VStack{
            
            let customIcons: [String] = [
//                "Christmas",
                "AppIconDefault",
                "AppIconPurple",
                "AppIconMaple",
                "action",
                "mint",
                "peach",
                "brown",
                "photoBlue",
                "photoBlueDark",
                "redCrayon",
                "cornflour",
                "notebook",
                "Alpha",
                "pixel"
            ]

            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 15){
                    ForEach(customIcons, id: \.self) { icon in
                        Button {
                            withAnimation(.bouncy){
                                activeAppIcon = icon
                            }
                        } label: {
                            Image(uiImage: UIImage(named: icon) ?? UIImage())
                                .resizable()
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 12.2807017544))
                                .regularOutline(cornerRadius: 12.2807017544)
                                .overlay( icon == activeAppIcon ? RoundedRectangle(cornerRadius: 10).strokeBorder(color , lineWidth: 1.5) : nil )

                            .scaleEffect(icon == activeAppIcon ? 1.1 : 1)
                            .animation(.bouncy)
                        }
                        .buttonStyle(bounceButton())


                    }
                }

                .padding(.horizontal, 17)
                .padding(.vertical, 17)

            }
        }
        .frame(maxWidth: .infinity)
        .onChange(of: activeAppIcon) { newValue in
            if newValue != "AppIconDefault"{
                UIApplication.shared.setAlternateIconName(newValue)
            }
            else{
                UIApplication.shared.setAlternateIconName(nil)
            }

        }

        .background (
            Color("NeoButton").opacity(0.6)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .regularOutline()
    }
}
#Preview {
    AppIcon()
}
#endif
