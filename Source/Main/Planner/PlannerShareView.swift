//
//  PlannerShareView.swift
//  KyoNeo
//
//  Created by Aether on 08/08/2023.
//

import SwiftUI
import AmethystUI
import CoreMotion

struct PlannerShareView: View {

    @State var shownTimeSlot: TimeSlot?
    @State var viewTimeSlot: TimeSlot?
    @State var shareTimeSlot: TimeSlot?
    @State var classForTask: ClassEntity?



    @State var scrolled: Bool = false
    @ObservedObject var timeSlot: TimeSlot
    @Environment(\.managedObjectContext) private var viewContext
    @State private var widget1Position = CGPoint(x: 1, y: 1)
    @State private var isAnimating = true
    @State private var isTimetableType = 1
    @State private var initialAttitude: CMAttitude?

    // State variables to store relative rotation angles
        @State private var relativeRotationX: Double = 0
        @State private var relativeRotationY: Double = 0
        @State private var relativeRotationZ: Double = 0

    var body: some View {
        ScrollView{
            ScrollDetector(scrolled: $scrolled)
            EntryBlock(timeSlot: timeSlot, index: 1, context: viewContext, shownTimeSlot: $shownTimeSlot, viewTimeSlot: $viewTimeSlot, classForTask: $classForTask, shareTimeSlot: $shareTimeSlot, editMode: .constant(false))
                .allowsHitTesting(/*@START_MENU_TOKEN@*/false/*@END_MENU_TOKEN@*/)
                .rotation3DEffect(Angle(degrees: 2.3),
                                                      axis: (x: widget1Position.x, y: widget1Position.y, z: 0),
                                                      anchor: .center)
//                .animation(.linear(duration: 5))
//                                .rotation3DEffect(Angle(degrees: min(10,relativeRotationY / 3)),
//                                                  axis: (x: -1, y: 0 , z: 0),
//                                                  anchor: .center)
//                                                            .rotation3DEffect(Angle(degrees: min(10,relativeRotationX / 3)),
//                                                                              axis: (x: 0, y: -1 , z: 0),
//                                                                              anchor: .center)
//                                .rotation3DEffect(Angle(degrees: min(10, relativeRotationZ / 8)),
//                                                  axis: (x: 0, y: 0, z: -1),
//                                                  anchor: .center)
//                                .animation(.linear)
                .shadow(color: Color(hex: timeSlot.classEntity?.color1 ?? timeSlot.splitterEntity?.color1 ?? "").opacity(0.17), radius: 15, y: 1.0)
            
            Picker(selection: $isTimetableType) {
                Text("Block")
                    .tag(1)
                Text("Loop")
                    .tag(0)
            } label: {

            }
            .padding()
            .padding(.horizontal, 5)
            .pickerStyle(.segmented)


            #if os(iOS) || os(visionOS)
            ShareLink(item: Image(uiImage: generateSnapshot()), preview: SharePreview("\(timeSlot.classEntity?.name ?? timeSlot.splitterEntity?.name ?? "Untitled") Entry", image: Image(uiImage: generateSnapshot())),label: {
                Label("Photo", systemImage: "photo")
            })
            .buttonStyle(.borderedProminent)
            #elseif os(macOS)
            ShareLink(item: Image(nsImage: generateSnapshot()), preview: SharePreview("\(timeSlot.classEntity?.name ?? timeSlot.splitterEntity?.name ?? "Untitled") Entry", image: Image(nsImage: generateSnapshot())),label: {
                Label("Photo", systemImage: "photo")
            })
            .buttonStyle(.borderedProminent)
            #endif

        }
        .onAppear {
                    animatePattern()
//            startMotionUpdates()
                }
        .onDisappear{
//        stopMotionUpdates()
            isAnimating = false
        }

        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: timeSlot.classEntity?.color1 ?? timeSlot.splitterEntity?.color1 ?? "").opacity(0.2), Color.clear]), startPoint: .top, endPoint: .bottom))

        .safeAreaInset(edge: .top, content: {
            Color.clear.frame(height: 73)
        })
        #if os(iOS) || os(visionOS)
        .navigationTitle("")
        .navigationBarHidden(true)
        .overlay(alignment: .top){
            FluidNavigationBar(title: "Share", titleColor: .primary,   tintColor: Color(hex: timeSlot.classEntity?.color1 ?? timeSlot.splitterEntity?.color1 ?? ""), compactMode: true, type: .regular, scrolled: $scrolled, content: {
                
            }, toolbar: {
                
            })
        }
        #endif
    }

    #if os(iOS) || os(visionOS)
    private func generateSnapshot() -> UIImage {
        let renderer = ImageRenderer(content: EntryBlock(timeSlot: timeSlot, index: 1, context: viewContext, shownTimeSlot: $shownTimeSlot, viewTimeSlot: $viewTimeSlot, classForTask: $classForTask, shareTimeSlot: $shareTimeSlot, editMode: .constant(false), imageMode: true).frame(width: 350))

        renderer.scale = 3
        return renderer.uiImage ?? UIImage()
    }
    #elseif os(macOS)
    func generateSnapshot() -> NSImage {
            let controller = NSHostingController(rootView: self)

            let view = controller.view

            let imageSize = view.frame.size
            let bitmap = view.bitmapImageRepForCachingDisplay(in: view.bounds)!
            bitmap.size = imageSize

            view.cacheDisplay(in: view.bounds, to: bitmap)

            let image = NSImage(size: imageSize)
            image.addRepresentation(bitmap)

            return image
        }
    #endif

    private func animatePattern() {
            guard isAnimating else {
                return
            }

            animateStep(widgetIndex: 1, step: 1)
        }

        private func animateStep(widgetIndex: Int, step: Int) {
            guard isAnimating else {
                return
            }
            if #available(iOS 17.0, *) {
                let minDuration: Double = 3.8
                let maxDuration: Double = 5.5
                let randomDuration = Double.random(in: minDuration...maxDuration)

                let animation = Animation.linear(duration: randomDuration)

                var position: CGPoint
                switch step {
                case 1:
                    position = CGPoint(x: 1, y: 1)
                case 2:
                    position = CGPoint(x: -1, y: 1)
                case 3:
                    position = CGPoint(x: -1, y: -1)
                case 4:
                    position = CGPoint(x: 1, y: -1)
                default:
                    position = CGPoint(x: 0, y: 0)
                }

                withAnimation(animation) {
                    if widgetIndex == 1 {
                        widget1Position = position
                    }
                } completion: {
                    let nextStep = step < 4 ? step + 1 : 1
                    animateStep(widgetIndex: widgetIndex, step: nextStep) // Loop back to the start if step is 4
                }
            } else {
                // Fallback on earlier versions
            }
        }
}


