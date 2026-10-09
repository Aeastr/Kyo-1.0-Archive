//
//  TabBarCustomise.swift
//  KyoNeo
//
//  Created by Aether on 01/05/2023.
//

import SwiftUI
import AmethystUI

//struct TabBarCustomise: View {
//    var color: Color
//    @State var scrolled = false
//    @State private var dragOverIndex: Int?
//    @State private var draggingIndex: Int?
//
//
//    var body: some View {
//
//        ScrollView{
//            ScrollDetector(scrolled: $scrolled)
//
//            Text("Order")
//                .sectionTitle(topPadding: 0, verticalPadding: 0)
//                .padding(.horizontal, 20)
//            tabbarDraggable()
//                .padding(.horizontal, 20)
//            Color.clear.frame(width: 100)
//
//
////            HStack(spacing: 16) {
////                ForEach(tabItemsData.tabItems.indices, id: \.self) { index in
////                    let tabItem = tabItemsData.tabItems[index]
////                    VStack{
////                        Text(tabItem.text)
////                    }
////                    .padding()
////                    .background(draggedTabItem == tabItem ? Color.blue.opacity(0.5) : Color.clear)
////                    .cornerRadius(8)
////                    .onDrag {
////                        draggedTabItem = tabItem
////                        draggingIndex = index
////                        return NSItemProvider(object: String(tabItem.id) as NSString)
////                    }
////                    .onDrop(of: ["public.text"], delegate: TabItemDropDelegate(item: tabItem, draggedTabItem: $draggedTabItem, tabItemsData: tabItemsData, dragOverIndex: $dragOverIndex, currentIndex: index))
////                    .offset(x: dragOverIndex == index ? (draggingIndex! > index ? -20 : 20) : 0)
////                    .contentShape(Rectangle().offset(x: dragOverIndex == index ? (draggingIndex! > index ? 20 : -20) : 0))
////                    
////                    
////                    // Adjust the offset amount as needed
////                    .animation(.easeInOut(duration: 0.2)) // Add animation for smooth movement
////                }
////            }
//            
//            .navigationBarTitle("")
//            .navigationBarHidden(true)
//        }
//        .coordinateSpace(name: "scroll")
//        .safeAreaInset(edge: .top, content: {
//            Color.clear.frame(height: 80)
//        })
//        .overlay(
//            FluidNavigationBar(title: "Tab Bar", titleColor: .primary,   tintColor: .primary, compactMode: true, type: .back, scrolled: $scrolled, content: {
//
//            }, toolbar: {
//
//            })
//        )
//    }
//}

//class TabItemDropDelegate: DropDelegate {
//    let item: TabItem
//    @Binding var draggedTabItem: TabItem?
//    let tabItemsData: TabItemsData
//    @Binding var dragOverIndex: Int?
//    let currentIndex: Int
//
//    init(item: TabItem, draggedTabItem: Binding<TabItem?>, tabItemsData: TabItemsData, dragOverIndex: Binding<Int?>, currentIndex: Int) {
//        self.item = item
//        _draggedTabItem = draggedTabItem
//        self.tabItemsData = tabItemsData
//        _dragOverIndex = dragOverIndex
//        self.currentIndex = currentIndex
//    }
//
//    func performDrop(info: DropInfo) -> Bool {
//        guard let draggedTabItem = draggedTabItem else { return false }
//
//        let fromIndex = tabItemsData.tabItems.firstIndex(of: draggedTabItem)
//        let toIndex = dragOverIndex ?? tabItemsData.tabItems.count
//
//        if let fromIndex = fromIndex {
//            tabItemsData.tabItems.swapAt(fromIndex, toIndex)
//            tabItemsData.saveTabItems()
//            print("Swapped tab item from index \(fromIndex) to index \(toIndex)")
//        } else {
//            print("Failed to perform drop")
//        }
//
//        self.draggedTabItem = nil
//        self.dragOverIndex = nil
//
//        return true
//    }
//
//
//
//
//    func dropEntered(info: DropInfo) -> DropProposal? {
//        dragOverIndex = currentIndex
//        return DropProposal(operation: .move)
//    }
//
//    func dropUpdated(info: DropInfo) -> DropProposal? {
//        dragOverIndex = currentIndex
//        return DropProposal(operation: .move)
//    }
//
//    func dropExited(info: DropInfo) {
//        dragOverIndex = nil
//    }
//}


//struct tabbarDraggable: View {
//
//    @Environment(\.colorScheme) var colorScheme
//
//    @AppStorage("appAccentColor") var appAccentColor = "Default"
//    @AppStorage("multicolored") var multicolored = true
//    @AppStorage("appAccentColorIndex") var appAccentColorIndex = 1
//
//    @EnvironmentObject var tabItemsData: TabItemsData
//    @State private var draggedTabItem: TabItem?
//    @State private var dragOverIndex: Int?
//    @State private var draggingIndex: Int?
//
//    @State var showBG = true
//    var body: some View {
//        VStack {
//
//
//
//
//                HStack(spacing: 0) {
//
//                    buttons            }
//
//
//
//                            .padding(.horizontal, 2)
//                            .padding(.vertical,  6)
//                            .frame(maxWidth: .infinity, maxHeight: 88 )
//                            .neoSettingsCard()
//                                        .frame(maxHeight: .infinity, alignment: .bottom)
//                                        .ignoresSafeArea()
//
//
//
//        }.environmentObject(tabItemsData)
//
//    }
//
//    var buttons: some View {
//        // Iterate through the tabItems array, with the index and tab as variables
//        HStack(spacing: 0){
//            ForEach(tabItemsData.tabItems.indices, id: \.self) { index in
//                var tabItem = tabItemsData.tabItems[index]
//
//
//
//
////                if index == dragOverIndex {
////                                Divider() // Add Divider where the dragged item will be added
////                            }
//
//
//                VStack(spacing: 3) {
//                    // Use a ZStack to adjust the icon color based on the selected tab
//                    ZStack {
//                        Color(multicolored ? "\(appAccentColor)/\(tabItem.id + 1)" : "\(appAccentColor)/\(appAccentColorIndex)")
//
//                                .frame(width: 31, height: 29)
//                    }
//                    // Mask the ZStack with the icon view
//                    .mask(
//                        tabItem.icon.view()
//                            .frame(width: 31, height: 29)
//                    )
//                    // Display the tab text with a font of .caption2 and a maximum width of 58 points
//                    Text(tabItem.text).font(.caption2)
//                        .fontWeight(.medium)
//                        .frame(width: 58)
//                        .foregroundStyle( Color(multicolored ? "\(appAccentColor)/\(tabItem.id + 1)" : "\(appAccentColor)/\(appAccentColorIndex)") )
//
//                }
//
//                .contentShape(RoundedRectangle(cornerRadius: 8))
//                
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//
//                .scaleEffect(dragOverIndex == index ? 0.8 : 1)
////                .offset(x: dragOverIndex == index ? (draggingIndex! > index ? -20 : 20) : 0)
//                // Add an overlay using a GeometryReader to track the X-coordinate of each tab item
//
//                // Handle tap gestures on each tab item
//
//                // Set the foreground style based on whether the tab is selected
//
//
//                // Add a Spacer() between each tab item
//
//                .id(tabItem.id)
//                
//                .onDrag {
//                    draggedTabItem = tabItem
//                    draggingIndex = index
//                    return NSItemProvider(object: String(tabItem.id) as NSString)
//                }
//
//                .onDrop(of: ["public.text"], delegate: TabItemDropDelegate(item: tabItem, draggedTabItem: $draggedTabItem, tabItemsData: tabItemsData, dragOverIndex: $dragOverIndex, currentIndex: index))
//
//        }
//        }.animation(.bouncy)
//    }
//
//
//
//}
