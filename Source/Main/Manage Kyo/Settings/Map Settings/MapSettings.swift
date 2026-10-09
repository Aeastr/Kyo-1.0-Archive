//
//  MapSettings.swift
//  KyoNeo
//
//  Created by Aether on 16/07/2023.
//

import SwiftUI
import MapKit
import AmethystUI

@available(iOS 17, *)
struct MapSettings: View {
    @Namespace var namespace
    @State var searchResults: [MKMapItem] = []
    @State var show = false
    @State var scrolled: Bool = false
    @State var showlocre: Bool = false
    var color = Color.purple

    @AppStorage("savedLatitude") var savedLatitude: Double?
    @AppStorage("savedLongitude") var savedLongitude: Double?
    var body: some View {
        ScrollView{
            ScrollDetector(scrolled: $scrolled)
            HStack{
                Image(systemName: "lightbulb")
                    .font(.title2)
                    .scaledFrame(width: 50, height: 50, relativeTo: .title2)
                Text("Kyo Maps is currently here for minimal testing purposes and isn't fully implemented")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            .neoSettingsCard()
            .padding(.horizontal, 20)
            .padding(.bottom, 5)

            VStack{
                MapView2()
                    .disabled(true)


            }
            .frame(height: 130)
            .frame(maxWidth: .infinity)
            .background {
                Color("NeoButton").opacity(0.6)
            }

            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .regularOutline()
            .padding(.horizontal, 20)

                Text("For now, you can allow location access and check out map search, this is still unstable and has issues, but we'll be updating it over time")
                .font(.caption)
                .padding(.vertical, 10)
                .padding(.horizontal, 30)
            Button {
                show.toggle()
            } label: {
                Label(MapItemStorage.isMapItemSet(forKey: "savedMapItem") ? "Change Campus" : "Find My Campus", systemImage: "magnifyingglass")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PolishedButton(color: color))
            .padding(.horizontal, 20)
            if MapItemStorage.isMapItemSet(forKey: "savedMapItem"){
                Button {
                    //            MapItemStorage.saveMapItemToUserDefaults(mapItem: nil, forKey: "savedMapItem")
                    MapItemStorage.resetMapItem(forKey: "savedMapItem")
                } label: {
                    Label("Remove Campus", systemImage: "xmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PolishedButton(color: color))
                .padding(.horizontal, 20)
            }



                Button {

                    showlocre.toggle()
                } label: {
                    Label("Force show location request UI", systemImage: "triangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PolishedButton(color: color))
                .padding(.horizontal, 20)
#if !os(macOS)
                .fullScreenCover(isPresented: $showlocre){
                    UserLocationRequest()
                }
            #endif


        }
#if os(iOS) || os(visionOS)
    .fullScreenCover(isPresented: $show) {
        MapSearch(show: $show)
    }
#else
    .sheet(isPresented: $show) {
        MapSearch(show: $show)
            .presentationCornerRadius(25)
    }
#endif
        #if os(iOS) || os(visionOS)
        .safeAreaPadding(.top, 80)
        .toolbar(.hidden)
        .overlay(alignment: .top){
            FluidNavigationBar(title: "Maps",   type: .back, scrolled: $scrolled, content: {
                
            }, toolbar: {
                
            })
        }
        #endif

    }



}

@available(iOS 17.0, *)
struct MapView2: View {
    @State private var loadedMapItem: MKMapItem?

    var body: some View {

        if let n = MapItemStorage.loadMapItemFromUserDefaults(forKey: "savedMapItem")?.name, let x = (MapItemStorage.loadMapItemFromUserDefaults(forKey: "savedMapItem")?.placemark.coordinate){
            Map(position: .constant(.camera(MapCamera(centerCoordinate: x, distance: 180, heading: 2, pitch: 45)))){
                // Add an annotation for the loaded MKMapItem
                //            MapPin(coordinate: (loadedMapItem?.placemark.coordinate)!, tint: .red)
                Marker(n, coordinate: x)

            }
            .mapStyle(.standard(elevation: .realistic, emphasis: .muted, pointsOfInterest: [.school], showsTraffic: false))
            .onAppear {
                print("x")
                // Load the map item from UserDefaults when the view appears
                loadedMapItem = MapItemStorage.loadMapItemFromUserDefaults(forKey: "savedMapItem")
            }
            .onDisappear {
                // Clear the loadedMapItem when the view disappears
                loadedMapItem = nil
            }
        }
        else{
            Text("No Map Set")
                .font(.caption)
                .onAppear {
                    print("xd")
                    // Load the map item from UserDefaults when the view appears
                    loadedMapItem = MapItemStorage.loadMapItemFromUserDefaults(forKey: "savedMapItem")
                }
        }
    }

    private var region: MKCoordinateRegion {
        if let mapItem = loadedMapItem {
            // You can customize the region as needed based on the loaded MKMapItem's location
            return MKCoordinateRegion(
                center: mapItem.placemark.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        } else {
            // Default region if no map item is loaded
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
                span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            )
        }
    }
}



struct MapItemStorage {
    static func serializeMapItem(mapItem: MKMapItem) -> [String: Any] {
        var serializedMapItem: [String: Any] = [:]
        serializedMapItem["name"] = mapItem.name
        serializedMapItem["latitude"] = mapItem.placemark.coordinate.latitude
        serializedMapItem["longitude"] = mapItem.placemark.coordinate.longitude
        // Add more properties as needed
        return serializedMapItem
    }

    static func saveMapItemToUserDefaults(mapItem: MKMapItem, forKey key: String) {
        let serializedMapItem = serializeMapItem(mapItem: mapItem)
        UserDefaults.standard.set(serializedMapItem, forKey: key)
    }

    static func loadMapItemFromUserDefaults(forKey key: String) -> MKMapItem? {
        if let serializedMapItem = UserDefaults.standard.dictionary(forKey: key) as? [String: Any] {
            return createMapItemFromSerializedData(data: serializedMapItem)
        }
        return nil
    }

    static func createMapItemFromSerializedData(data: [String: Any]) -> MKMapItem? {
        guard let name = data["name"] as? String,
              let latitude = data["latitude"] as? Double,
              let longitude = data["longitude"] as? Double else {
            return nil
        }

        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: location)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        // Set other properties as needed

        return mapItem
    }

    static func resetMapItem(forKey key: String) {
            UserDefaults.standard.removeObject(forKey: key)
        }

    static func isMapItemSet(forKey key: String) -> Bool {
            return UserDefaults.standard.object(forKey: key) != nil
        }
}
