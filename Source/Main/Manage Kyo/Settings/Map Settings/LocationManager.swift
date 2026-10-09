//
//  LocationManager.swift
//  KyoNeo
//
//  Created by Aether on 16/07/2023.
//

#if !os(visionOS)
import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    static let shared = LocationManager()
    private let debug = true

    override init(){
        log("[LocationManager - class] initalise ", debug: debug)
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }

    func requestLocation() {
        log("[LocationManager - requestLocation] location requested ", debug: debug)
        manager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        log("[LocationManager - CLLocationManagerDelegate] checking status with switch", debug: debug)
        switch status {
        case .notDetermined:
            log("[LocationManager - CLLocationManagerDelegate] notDetermined ", debug: debug)
        case .restricted:
            log("[LocationManager - CLLocationManagerDelegate] restricted ", debug: debug)
        case .denied:
            log("[LocationManager - CLLocationManagerDelegate] denied ", debug: debug)
        case .authorizedAlways:
            log("[LocationManager - CLLocationManagerDelegate] authorizedAlways ", debug: debug)
        case .authorizedWhenInUse:
            log("[LocationManager - CLLocationManagerDelegate] authorizedWhenInUse ", debug: debug)
        @unknown default:
            log("[LocationManager - CLLocationManagerDelegate] unknown?default - break ", debug: debug)
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        self.userLocation = location
    }
}
#endif
