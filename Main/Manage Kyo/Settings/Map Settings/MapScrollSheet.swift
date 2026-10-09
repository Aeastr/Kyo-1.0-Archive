//
//  MapScrollSheet.swift
//  KyoNeo
//
//  Created by Aether on 16/07/2023.
//

import SwiftUI
import MapKit
import AmethystUI

@available(iOS 17, *)
struct MapScrollSheet: View {
    var debug = true
    @State var searchText: String = ""
    @Binding var searchResults: [MKMapItem]
    @Binding  var selectedResult: MKMapItem?

    @FocusState private var focusedField: Bool
    @Binding var presentationSheetMode: PresentationDetent

    @Binding var presentedItem: [MKMapItem]

    var body: some View {
        NavigationStack(path: $presentedItem){
        ScrollViewReader{ proxy in
            ScrollView{
                VStack(spacing: 15){
                    ForEach(searchResults, id: \.self){ result in
                        HStack{
                            Button {
                                presentationSheetMode = .fraction(0.53)
                                presentedItem = [result]
                            } label: {
                                HStack{
                                    Image(systemName: "graduationcap")
                                        .symbolRenderingMode(/*@START_MENU_TOKEN@*/.hierarchical/*@END_MENU_TOKEN@*/)
                                        .font(.title3)
                                        .frame(width: 45, height: 45)

                                    Text(result.name ?? "")
                                        .multilineTextAlignment(.leading)


                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 12)
                                .foregroundColor(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                            }




                            .padding(.horizontal, 5)

                        }
                        .id(result)

                    //    .transition(.opacity.animation(.smooth))
                        .modify {
                            if #available(iOS 17.0, *) {
                                $0.scrollTransition { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1 : 0.95)
                                        .blur(radius: phase.isIdentity ? 0 : 3)
                                }
                            }
                            else{
                                $0
                            }
                        }
                        Divider()
                            .padding(.leading, 70)
                    }
                }
            }
            .navigationDestination(for: MKMapItem.self) { result in
                MapDetail(item: result)
                    .onAppear{

                        withAnimation(.smooth){
                            presentationSheetMode = .fraction(0.53)
                            selectedResult = result
                        }
                    }
                    .onDisappear{
                        withAnimation(.smooth){
                            selectedResult = nil
                        }
                    }
            }

            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 85)
            })
            .onChange(of: selectedResult) { result in
                withAnimation(.smooth){
                    proxy.scrollTo(result, anchor: .center)
                }
            }
        }
        .overlay(alignment: .top, content: {
            HStack{
                TextField(text: $searchText) {
                    Text("Find your campus")
                }
                .focused($focusedField)
                .onChange(of: searchText){ text in

                        withAnimation(.smooth){
                            presentationSheetMode = .fraction(0.5)
                            if text.count > 4{
                                search(for: text)
                            }
                            else{
                                searchResults = []
                            }
                        }

                }

                .onSubmit {
                    withAnimation(.smooth){

                        presentationSheetMode = .fraction(0.5)
                    }
                }
                .padding( 15)
                .background {
                    Color("NeoButton").opacity( 0.4)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    // .shadow(color: actualColor.opacity(scrolled ? 0 : 0.3), radius: 7, x: 0, y: 8)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.primary.opacity(0.15), lineWidth: 1.5))
                }


            }
            .padding(.horizontal, 15)
            .padding(.top, 20)
            .padding(.bottom, 20)
#if os(iOS) || os(visionOS)
            .background(VariableBlurView())
            #endif
        })
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
