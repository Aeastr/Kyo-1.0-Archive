//
//  MapSearch.swift
//  KyoNeo
//
//  Created by Aether on 16/07/2023.
//

import SwiftUI
import AmethystUI
import MapKit

#if !os(visionOS)
@available(iOS 17, *)
struct MapSearch: View{
    var debug = true
    @Binding var show: Bool
    @State var searchText = ""
    @State var presentationSheetMode: PresentationDetent = .fraction(0.10)

    @State var searchResults: [MKMapItem] = []
    @State private var selectedResult: MKMapItem?

    @State private var position: MapCameraPosition = .camera(MapCamera(centerCoordinate: .userLocation, distance: 1000, heading: 10, pitch: 35))
    @State private var visibleRegion: MKCoordinateRegion? = .userRegion


    @ObservedObject var locationManager = LocationManager.shared

    @State private var presentedItem: [MKMapItem] = []

    @Namespace var mapscope

    var body: some View{
        ZStack{
            if locationManager.userLocation == nil {
                UserLocationRequest()
            }
            else{
                content
            }
        }
    }

    init(debug: Bool = true, show: Binding<Bool>) {
        self.debug = debug
        self._show = show
        if let pos = (MapItemStorage.loadMapItemFromUserDefaults(forKey: "savedMapItem")?.placemark.coordinate){
            self._position = .init(initialValue: .camera(MapCamera(centerCoordinate: pos, distance: 500, heading: 10, pitch: 35)))
        }
    }

    var content: some View {
        VStack{
            if #available(iOS 17.0, *) {

                Map( position: $position, selection: $selectedResult, scope: mapscope) {
                    UserAnnotation()
                    ForEach(searchResults, id: \.self){ result in

                        Marker(item: result)
                    }
                    if let n = MapItemStorage.loadMapItemFromUserDefaults(forKey: "savedMapItem")?.name, let x = (MapItemStorage.loadMapItemFromUserDefaults(forKey: "savedMapItem")?.placemark.coordinate){
                        Marker(n, coordinate: x)
                    }

                }
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        search(for: "School")
                    }
                }
                .mapControls({
                    MapUserLocationButton()
                })

                .mapStyle(.standard(elevation: .realistic))
             //   .animation(.linear, value: presentationSheetMode)

                .safeAreaPadding(.top, 90)

            } else {
                // Fallback on earlier versions
            }
        }
        .onChange(of: selectedResult){
            if let result = selectedResult{
                withAnimation(.smooth){
                    position = .item(result)
                    presentedItem = [result]
                }
            }



        }

        .sheet(isPresented: .constant(true), content: {
            MapScrollSheet(searchResults: $searchResults, selectedResult: $selectedResult, presentationSheetMode: $presentationSheetMode, presentedItem: $presentedItem)


            .presentationDetents((presentedItem == [] ? [.fraction(0.53), .large, .fraction(0.10)] : [.fraction(0.53), .large]), selection: $presentationSheetMode)

            .presentationBackgroundInteraction(.enabled)
            .presentationBackground(.clear)
            .background(.regularMaterial)
            .interactiveDismissDisabled()
            .presentationCornerRadius(25)
        })
        .safeAreaInset(edge: .bottom, content: {
            Color.clear.frame(height: presentationSheetMode == .fraction(0.10) ? 120 : 410)
                .animation(.smooth, value: presentationSheetMode)
        })

        .overlay(alignment: .top){
            FluidNavigationBar(title: "Search", titleColor: .primary,  titleWeight: .semibold ,scrolled: .constant(false)) {
                Button {
                    show = false
                } label: {
                    Text("Done")
                        .scaledFrame(width: 60, height: 40, relativeTo: .body)
                }
                .buttonStyle(NavigationButton(color: .primary, scrolled: .constant(false)))

            } toolbar: {

            }

        }


    }

    func search(for query: String) {

        log("[MapScrollSheet - Search Start]", debug: debug)
        let request = MKLocalSearch.Request()

        let filter = MKPointOfInterestFilter(including: [.school, .university])
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.pointOfInterestFilter = filter
        log("[MapScrollSheet - Search Request: \(request)]", debug: debug)

        Task {
            let search = MKLocalSearch(request: request)
            log("[MapScrollSheet - Search: \(search)]", debug: debug)
            let response = try? await search.start()
            log("[MapScrollSheet - Response: \(response)]", debug: debug)
            searchResults = response?.mapItems ?? []
            log("[MapScrollSheet - Search Results : \(searchResults.count)]", debug: debug)
        }
        print(searchResults)
    }
}

//#Preview {
//    VStack{
//        if #available(iOS 17, *) {
//            MapSearch(show: .constant(true))
//        } else {
//            // Fallback on earlier versions
//        }
//    }
//}

#else
struct MapSearch: View {
    init(debug: Bool = true, show: Binding<Bool>) {
    }
    var body: some View {
        Text("Location features are not availible on Kyo for visionOS")
    }
}
#endif


