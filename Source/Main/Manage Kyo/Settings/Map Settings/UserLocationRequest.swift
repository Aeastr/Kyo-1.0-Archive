//
//  UserLocationRequest.swift
//  KyoNeo
//
//  Created by Aether on 16/07/2023.
//

import SwiftUI
import AmethystUI

#if !os(visionOS)
@available(iOS 17.0, *)
struct UserLocationRequest: View {
    @State var scrolled: Bool = false
    @ObservedObject var locationManager = LocationManager.shared
    var color = Color.blue

    var body: some View {
        ScrollView{
            ScrollDetector(scrolled: $scrolled)
            VStack(alignment: .leading, spacing: 10){
                Text("Kyo requires your location to offer estimated travel times, suggest optimal departure times, and assist you in attaching locations to your classes and events.")

                Text("Please note that Kyo uses Apple Maps, and as such, Apple's privacy policy will apply. It's essential to mention that any data Kyo stores is kept only on your device, ensuring your privacy and data security")
                    .font(.caption)



            }
            .padding(.horizontal, 20)
        }
        .safeAreaInset(edge: .bottom, content: {
            if locationManager.userLocation == nil {
                HStack{

                    Button(action: {

                    }, label: {
                        Text("Decline")
                            .frame(maxWidth: .infinity)
                    })
                    .buttonStyle(BentoButton(color: .red, backgroundTint: .red.opacity(0.5)))

                    Button(action: {
                        LocationManager.shared.requestLocation()
                    }, label: {
                        Text("Allow")
                            .frame(maxWidth: .infinity)
                    })
                    .buttonStyle(BentoButton(color: color, backgroundTint: color.opacity(0.5)))

                }
                .padding(.horizontal, 20)
            }
            else{
                Text("You've already granted Kyo permision to access your location. You can change this in system settings.")
            }

        })
        .coordinateSpace(name: "scroll")
        .safeAreaPadding(.top, 70)
        .overlay(alignment: .top){
            FluidNavigationBar(title: "Location", titleColor: .primary,   scrolled: $scrolled, content: {
                
            }, toolbar: {
                
            })
        }
    }
}

#Preview {
    VStack{
        if #available(iOS 17.0, *) {
            UserLocationRequest()
        } else {
            // Fallback on earlier versions
        }
    }
}
#else
struct UserLocationRequest: View {
    var body: some View {
        Text("Location features are not availible on Kyo for visionOS")
    }
}
#endif

