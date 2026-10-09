//
//  extensions.swift
//  KyoNeo
//
//  Created by Aether on 16/07/2023.
//

import SwiftUI
import MapKit

extension CLLocationCoordinate2D{
    static var userLocation: CLLocationCoordinate2D{
        return .init(latitude: 25.7602, longitude: -80.1959)
    }
}

extension MKCoordinateRegion{
    static var userRegion: MKCoordinateRegion{
        return .init(center: .userLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
}
