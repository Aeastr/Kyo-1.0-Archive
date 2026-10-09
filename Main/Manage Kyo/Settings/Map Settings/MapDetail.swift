//
//  MapDetail.swift
//  KyoNeo
//
//  Created by Aether on 16/07/2023.
//

import SwiftUI
import MapKit
import AmethystUI

#if !os(visionOS)
@available(iOS 17.0, *)
struct MapDetail: View {
    var debug = true
    @State var scrolled: Bool = false
    @State private var route: MKRoute?

    @ObservedObject var locationManager = LocationManager.shared

    @AppStorage("savedLatitude") var savedLatitude: Double?
    @AppStorage("savedongitude") var savedLongitude: Double?

    @Environment(\.dismiss) var dismiss

    var item: MKMapItem

    init(scrolled: Bool = false, route: MKRoute? = nil, item: MKMapItem) {
        self._scrolled = .init(initialValue: scrolled)
        self._route = .init(initialValue: route)
        self.item = item
    }

    var body: some View {
        ScrollView{
            ScrollDetector(scrolled: $scrolled)
            Text("Location")
                .sectionTitle()
                .bold()
                .padding(.horizontal, 20)
            Text(item.placemark.title ?? "Location name not found")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)

            Text("Travel Times")
                .sectionTitle()
                .bold()
                .padding(.horizontal, 20)
            HStack{
                HStack{
                    Image(systemName: "figure.walk")
                        .font(.title3)
                        .scaledFrame(width: 21, height: 25, relativeTo: .title3)
                    Text("-")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .regularOutline()
                HStack{
                    Image(systemName: "car")
                        .font(.title3)
                        .scaledFrame(width: 28, height: 25, relativeTo: .title3)
                    Text("-")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .regularOutline()
                HStack{
                    Image(systemName: "train.side.rear.car")
                        .font(.title3)
                        .scaledFrame(width: 28, height: 25, relativeTo: .title3)
                    Text("-")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .regularOutline()
            }
            .padding(.horizontal, 20)

        }
        .coordinateSpace(name: "scroll")
        .navigationTitle(item.name ?? "No Name")
        .toolbar(.hidden)
        .safeAreaPadding(.top, 65)

        .overlay(alignment: .top){
            FluidNavigationBar(title: item.name?.shortened(maxLength: 38) ?? "No Name", titleColor: .primary,   type: .back, scrolled: $scrolled, content: {
                
            }, toolbar: {
                
            })
        }
        .safeAreaInset(edge: .bottom) {
            HStack{
                Button {
                    item.openInMaps()
                } label: {
                    Text("Open in Maps")
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                }
                .buttonStyle(BentoButton(color: .primary, scrolled: .constant(false)))

                Button {

                    MapItemStorage.saveMapItemToUserDefaults(mapItem: item, forKey: "savedMapItem")

                    print("set\(item.placemark.coordinate.latitude) \(item.placemark.coordinate.longitude)")
                    dismiss()
                } label: {
                    Text("Set as my Campus")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 3)
                }
                .buttonStyle(BentoButton(color: .white, backgroundTint: .brown, scrolled: .constant(false)))

            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
#if os(iOS) || os(visionOS)
            .background{VariableBlurView().rotationEffect(Angle(degrees: 180)).ignoresSafeArea()}
            #endif
        }
    }

    func getDirections() {
     //   route = nil
        print("[MapDetailView getDirections] -Start-")
        let request = MKDirections.Request()

        if let lat = (locationManager.userLocation?.coordinate.latitude), let long = (locationManager.userLocation?.coordinate.longitude) {
            log("[MapDetailView] - User Location is: lat(\(lat), long:(\(long))", debug: debug)
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: .init(latitude: lat, longitude: long)))
        }
        else{
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: item.placemark.coordinate))
        }
        request.transportType = .walking

        log("[MapDetailView - Request Source: \(request.source)]", debug: debug)
        request.destination = item

        log("[MapDetailView - Directions Request: \(request)]", debug: debug)

        Task {
            let directions = MKDirections(request: request)
            log("[MapDetailView - Directions Object: \(directions)]", debug: debug)

            do {
                let response = try await directions.calculate()
                log("[MapDetailView - Directions Calculated Successfully]", debug: debug)

                guard let firstRoute = response.routes.first else {
                    log("[MapDetailView - No Routes Found in Response]", debug: debug)
                    return
                }

                route = firstRoute
                log("[MapDetailView - Route Set Successfully]", debug: debug)
            } catch {
                log("[MapDetailView - Error Calculating Directions: \(error)]", debug: debug)
            }
        }

        print("[MapDetailView getDirections] -End-")
    }

    func travelTime() -> String? {
        getDirections()
        guard let route else {
            log("[MapDetailView travelTime() - No route found]", debug: debug)
            return nil
        }

        log("[MapDetailView - Route: \(route)]", debug: debug)

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]

        guard let travelTime = formatter.string(from: route.expectedTravelTime) else {
            log("[MapDetailView - Unable to calculate travel time]", debug: debug)
            return nil
        }

        log("[MapDetailView - Travel Time: \(travelTime)]", debug: debug)

        for (index, step) in route.steps.enumerated() {
            log("[MapDetailView - Step \(index + 1): \(step.instructions)]", debug: debug)
        }

        return travelTime
    }

}
#else
struct MapDetail: View {

    init(scrolled: Bool = false, route: MKRoute? = nil, item: MKMapItem) {
    }
    var body: some View {
        Text("Location features are not availible on Kyo for visionOS")
    }
}
#endif
