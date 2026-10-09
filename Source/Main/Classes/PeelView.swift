//
//  PeelView.swift
//  KyoNeo
//
//  Created by Aether on 15/07/2023.
//

import SwiftUI

struct PeelEffect<Content: View>: View{
    var content: Content
    
    var onDelete: () -> ()

    init(@ViewBuilder content: @escaping () -> Content, onDelete: @escaping () -> (), progressOffset: CGFloat = 0.0) {
        self.content = content()
        self.onDelete = onDelete
        self.progressOffset = progressOffset
    }

    @State private var dragProgress: CGFloat = 0
    @State private var dragProgressOffset: CGFloat = 0
    @State private var dragProgressMultiplier: CGFloat = 1
    @State private var confirmDelete: Bool = false
    var progressOffset: CGFloat = 0.0
    @State private var startedDrag: Bool = false

    var body: some View{
        content
            .mask{
                GeometryReader {
                    let rect = $0.frame(in: .global)

                    RoundedRectangle(cornerRadius: 3)
                        .padding(.trailing, ((dragProgress + progressOffset + dragProgressOffset) * dragProgressMultiplier) * rect.width)
                }
            }
            .overlay{
                GeometryReader {
                    let rect = $0.frame(in: .global)
                    let size = $0.size

                    content
                        .scaleEffect(-1)

                        .offset(x: size.width - (size.width * ((dragProgress + progressOffset + dragProgressOffset) * dragProgressMultiplier)))
                        .offset(x: size.width * -((dragProgress + progressOffset + dragProgressOffset) * dragProgressMultiplier))
                        .mask{
                            RoundedRectangle(cornerRadius: 3)
                                .offset(x: size.width * -((dragProgress + progressOffset + dragProgressOffset) * dragProgressMultiplier))
                        }
                        .shadow(color: .black.opacity(0.4),radius: 10)
                        .contentShape(Rectangle())

                        .gesture(
                            DragGesture()
                                .onChanged({ value in
                                    var translationX = value.translation.width
                                    translationX = max(-translationX, 0)

                                    let progress = translationX / size.width
                                    dragProgress = progress
                                    startedDrag = true
                                    if (-(value.translation.width) / size.width) + dragProgressOffset < (0.2){
                                        dragProgressOffset = 0.0
                                    }
                                    if (-(value.translation.width) / size.width) + dragProgressOffset < (0.4){
                                        dragProgressMultiplier = 0.8
                                    }
                                    else{
                                        dragProgressMultiplier = 1.1
                                    }
                                })
                                .onEnded({ value in
                                    if dragProgress < 0.2 {
                                        dragProgress = .zero
                                        dragProgressMultiplier = 1.0
                                        startedDrag = false
                                    }
                                    else if !(dragProgress < 0.4){
                                        dragProgress = .zero
                                        dragProgressOffset = 1.0
                                        dragProgressMultiplier = 1.0
                                        startedDrag = false
                                        confirmDelete = true
                                    }
                                    else{

                                            dragProgress = .zero
                                        dragProgressOffset = 0.2
                                            dragProgressMultiplier = 1.0
                                            startedDrag = false
                                    }
                                })
                        )

                }
            }

            .background{
                GeometryReader {
                    let size = $0.size
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.red.opacity(0.8))
                        .overlay(alignment: .trailing){
                            HStack{
                                Image(systemName: "minus.circle.fill")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                                .padding(.trailing, 20)
                                .foregroundColor(.white)
                                .padding(.trailing, max(0, size.width * ((dragProgress + progressOffset + dragProgressOffset) * dragProgressMultiplier) - 80))
                        }
                        .padding(3)
                        .padding(.horizontal, startedDrag ? 0 : 5)
                        .offset(x: dragProgress * 2.5)
                        .onTapGesture {
                            dragProgress = .zero
                            dragProgressOffset = 1.0
                            dragProgressMultiplier = 1.0
                            startedDrag = false
                            confirmDelete = true
                        }
                }

            }
            .animation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7))
        #if os(iOS) || os(visionOS)
            .actionSheet(isPresented: $confirmDelete) {
                            ActionSheet(
                                title: Text("Are you sure you want to delete  This will delete all entries of this class"),
                                buttons: [
                                    .destructive(Text("Delete")) {
                                        withAnimation(.closeCard){

                                        }

                                    },

                                    .cancel(){
                                        withAnimation(.closeCard){

                                        }
                                    }
                                ]
                            )
                        }
        #else
            .popover(isPresented: $confirmDelete, arrowEdge: .bottom) {
                    VStack {
                        Text("Are you sure you want to delete? This will delete all entries of this class")
                            .padding()

                        HStack {
                            Button("Delete") {
                                withAnimation(.closeCard) {
                                    // Perform the delete action here
                                    // You can place your logic here

                                    confirmDelete = false
                                }
                            }
                            .foregroundColor(.red) // For a destructive appearance

                            Spacer()

                            Button("Cancel") {
                                withAnimation(.closeCard) {
                                    confirmDelete = false
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(width: 300) // Adjust the popover width as needed
                }
        #endif
    }
}
