//
//  NewWelcomeView.swift
//  KyoNeo
//
//  Created by Aether on 18/07/2023.
//

import SwiftUI
import AmethystUI
#if canImport(RiveRuntime)
import RiveRuntime
#endif
import CoreMotion

struct NewWelcomeView: View {
    @Binding var index: Int
    @State private var peeled: Bool = false
    @State private var showButtons: Bool = true
    @State var isPresentingImportView: Bool = false
    @AppStorage("appAccentColor") var appAccentColor = "Default"
    @AppStorage("multicolored") var multicolored = true
    @AppStorage("appAccentColorIndex") var appAccentColorIndex = 1
    @State private var position: Double = 0.5

    @AppStorage("selectedTabIndex") var selectedTabIndex: Int = 2 // Holds the currently selected tab

    @ObservedObject var iconManager = IconManager()
    var color: Color

    #if !os(macOS)
    private let motionManager = CMMotionManager()
    private func startMotionUpdates() {
            if motionManager.isDeviceMotionAvailable {
                motionManager.deviceMotionUpdateInterval = 0.1 // Adjust the update interval as needed
                motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
                    guard let motion = motion else { return }
                    // Calculate tilt values from motion data
                    let tiltY = motion.attitude.roll // Adjust this based on your desired axis

                    // Calculate position based on tilt
                    position = (tiltY + 1) / 2 // Adjust the scaling and offset as needed
                }
            }
        }
    private func stopMotionUpdates() {
            motionManager.stopDeviceMotionUpdates()
        }
    #endif

    var body: some View {
        ZStack{
            //
            #if !os(visionOS)
            Color.clear
                .background{

                    LinearGradient(gradient: Gradient(stops: [
                        Gradient.Stop(color: color.opacity(0.06), location: position - 0.17),
                        Gradient.Stop(color: color.opacity(0.35), location: CGFloat(position)),
//                                Gradient.Stop(color: Color.white.opacity(0.4), location: CGFloat(position + 0.08)),
                        Gradient.Stop(color: color.opacity(0.06), location: position + 0.17)
                    ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .mask{
                            VStack{
                                VStack(spacing: 0){
                                    Image("doodle1").resizable()
                                        .aspectRatio(contentMode: .fill)
                                    Image("doodle1").resizable()
                                        .aspectRatio(contentMode: .fill)
                                }

                                    .scaleEffect(1.2)

                            }
                        }
                        .opacity(0.3)

                    .animation(.smooth, value: position)
//                    .onAppear {
//                                startMotionUpdates()
//                            }
#if !os(macOS)
                            .onDisappear {
                                stopMotionUpdates()
                            }
                    #endif
                }
            #endif

//            let x = RiveViewModel(fileName: "splash2", stateMachineName: "textMachine", artboardName: "introText")
//            LinearGradient(colors: [color.darken(by: -0.25), color], startPoint: .leading, endPoint: .trailing)
//                .mask({
//                    x.view()
//                        .ignoresSafeArea()
//                        .mask(Rectangle().scaleEffect(x: 0.7, y: 0.3))
//                })
//                .shadow(color: Color("bw"), radius: 10, x: 0, y: 0)
//                .onAppear{
//                    DispatchQueue.main.asyncAfter(deadline: .now() + (2.0)){
//
//                        withAnimation(.smooth){
//                            showButtons = true
//
//                            #if !os(macOS)
//                            startMotionUpdates()
//                            #endif
//                        }
//                    }
//                }
//                .onChange(of: index){ change in
//                    if index != 0{
//                        x.triggerInput("hide")
//                    }
//                }
            Image("kyoPaper")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 30)
                .frame(maxWidth: 700)


#if !os(macOS)
                .scaleEffect(0.8)
            #else
                .scaleEffect(0.6)
            #endif

        }
#if os(iOS) || os(visionOS)
        .sheet(isPresented: $isPresentingImportView, onDismiss: {

        }) {
            ImportViewOnboard(isPresented: $isPresentingImportView)
                .tint(Color("Default/2"))
                .presentationCornerRadius(25)
        }
        #endif
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            if showButtons{
#if os(iOS) || os(visionOS)
            VStack(spacing: 14){
                VStack{
                    ButtonPeel(index: $index, peeled: $peeled, color: color.darken(by: -0.25), progressOffset: 0.05)
                    //                    .opacity(0)
                        .shadow(color: color.darken(by: -0.25).opacity(0.3), radius: 5, y: 3.0)
                        .background{
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [5]))

                                .fill(color)
                                .padding(4)
                                .opacity(0.6)

                        }
                }

//                Button(action: {
//                    isPresentingImportView.toggle()
//                }, label: {
//                    Text("Import Data")
//                        .font(.callout )
//                        .frame(maxWidth: .infinity)
//                })
//                .buttonStyle(PolishedButton(color: color, background: false))
//                .padding(.bottom, 17)
            }
            .transition(.blurWithoutScale)

            .padding(.horizontal, 20)

                    #if !os(visionOS)
            .background(LinearGradient(gradient: Gradient(colors: [Color.clear, Color("bw").opacity(0.5)]), startPoint: .top, endPoint: .bottom))
            .background(VariableBlurView().rotationEffect(Angle(degrees: 180)).ignoresSafeArea())
                #else
            .padding(.bottom, 40)
                #endif
                #else
                HStack{
                    Button(action: {
                        isPresentingImportView.toggle()
                    }, label: {
                        Text("Import Data")
                            .font(.callout )
                    })
                    .buttonStyle(PolishedButton(color: color, background: false))
                    Spacer()
                    Button {
                        withAnimation(.smoothCard){
                            index = index + 1
                        }
                    } label: {
                        Text("Get Started")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PolishedButton(color: color, background: true))
                }
                .padding(.bottom, 17)
                .padding(.horizontal, 20)
#endif
        }
        }
    }
}


struct ButtonPeel: View {
    @Binding var index: Int
    var color: Color
    // MARK: - Initializers
    init(index: Binding<Int>, peeled: Binding<Bool>, color: Color, progressOffset: CGFloat = 0.0) {
        self._index = index
        self._peeled = peeled
        self.color = color
        self.progressOffset = progressOffset
    }

    // MARK: - Swipe-to-Delete State Properties
    @State private var dragProgress: CGFloat = 0
        @State private var dragProgressOffset: CGFloat = 0
        @State private var dragProgressMultiplier: CGFloat = 1
        @Binding private var peeled: Bool
        @State private var startedDrag: Bool = false
    @State private var halfway: Bool = true

    // MARK: - Other Properties
    var progressOffset: CGFloat = 0.0

    // MARK: - Darken Text App Storage Property
    @AppStorage("darkenText") var darkenText = false

    // MARK: - Color Scheme Environment Property
    @Environment(\.colorScheme) var colorScheme


    var body: some View{
        classSticker

            .mask{
                classStickerMask
            }

            .overlay{
                stickerEffect
            }
            .overlay{
                arrow
            }
           // .animation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7))
            .onTapGesture {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
                    dragProgress = .zero
                    dragProgressOffset = 1.0
                    dragProgressMultiplier = 1.01
                    startedDrag = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
                        index = 1
                    }
                }
            }
    }

    var classSticker: some View{
        HStack{
            Spacer()
            Text("Get Started")
                .bold()
//                .fontWidth(.init(((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier) * 2))
//                .offset(x: 5 * (((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier) * 2))
            Spacer()
        //    Image(systemName: "arrow.right")
        }
        .padding()
        .background(color.gradient)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .regularOutline(cornerRadius: 15, lineWidth: 2.4, color: color.darken(by: 0.5).opacity(0.8))
    }

    var classStickerUnderside: some View{
        HStack{
            Spacer()
            Text(" ")
                .bold()
//                .fontWidth(.init(((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier) * 2))
//                .offset(x: 5 * (((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier) * 2))
            Spacer()
        //    Image(systemName: "arrow.right")
        }
        .padding()
        .background(color.gradient)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .regularOutline(cornerRadius: 15, lineWidth: 2.4, color: color.darken(by: 0.5).opacity(0.8))
    }

    var arrow: some View{
        GeometryReader {
            let globalFrame = $0.frame(in: .global)
            let size = $0.size

            let overallProgress = ((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier)
            let scale = max(1,(min(1.09,1 + (Double(overallProgress)) / 2.5) - 0.015))

            Image(systemName: "arrow.left")
                .foregroundStyle(.white)
                .frame(width: globalFrame.width * (1 - overallProgress), height: globalFrame.height, alignment: .trailing)
                .scaleEffect(scale)
                .offset(x: size.width * -((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier) - 20)
                .opacity(startedDrag ? overallProgress > 0.15 ? 0 : 1 : 1)

        }
    }



    var stickerEffect: some View{
        GeometryReader {
            let globalFrame = $0.frame(in: .global)
            let size = $0.size
            let overallProgress = ((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier)
            let scale = max(1,(min(1.09,1 + (Double(overallProgress)) / 2.5) - 0.015))
            classStickerUnderside

                .scaleEffect(x: -1)
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.20), Color.white.opacity(0.03)]), startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0.6, y: 0))


                        .frame(width: size.width * (((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier)))
                        .frame(width: size.width, alignment: .leading)
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                )

            .overlay(
                LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.002), Color.black.opacity(0.03)]), startPoint: .init(x: 0.6, y: 0), endPoint: .init(x: 1, y: 0))


                .blur(radius: 4)
                .scaleEffect(1.3)
                .scaleEffect(x:  1.1 + overallProgress)
                .offset(x: 15)

                .scaleEffect(overallProgress < 0.035 ? 1 : 1.05)
                    .frame(width: size.width * (((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier)))
                    .frame(width: size.width, alignment: .leading)

                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            )


            .scaleEffect(scale)
                .offset(x: size.width - (size.width * ((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier)))
                .offset(x: size.width * -((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier))

                .mask{
                    RoundedRectangle(cornerRadius: 3)

                        .scaleEffect(scale)
                        .offset(x: size.width * -((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier))
                }

                .shadow(color: color.darken(by: 0.3).opacity(0.6),radius: 10)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            var translationX = value.translation.width
                            translationX = max(-translationX, 0)

                                let progress = translationX / size.width
                            startedDrag = true

                            withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
                                dragProgress = progress
                                if (-(value.translation.width) / size.width) + dragProgressOffset < (0.2){
                                    dragProgressOffset = 0.0
                                    halfway = false
                                }
                                if (-(value.translation.width) / size.width) + dragProgressOffset < (0.4){
                                    dragProgressMultiplier = 0.8
                                    halfway = false
                                }
                                else{
                                    dragProgressMultiplier = 1.1
                                    halfway = true
                                }
                            }
                        })
                        .onEnded({ value in
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
                                if dragProgress < 0.2 {
                                    dragProgress = .zero
                                    dragProgressMultiplier = 1.0
                                    startedDrag = false
                                }
                                else if !(dragProgress < 0.4){
                                    dragProgress = .zero
                                    dragProgressOffset = 1.0
                                    dragProgressMultiplier = 1.01
                                    startedDrag = false
                                    index = 1
                                }
                                else{
                                        dragProgress = .zero
                                        dragProgressMultiplier = 1.0
                                        startedDrag = false
                                }

                            }
                        })
                )
//
//                .modify {
//                    if #available(iOS 17.0, *) {
//                        $0.sensoryFeedback(.impact(flexibility: .solid, intensity: .infinity), trigger: index)
//
//                    } else {
//                        $0
//                    }
//                }
//                .modify {
//                    if #available(iOS 17.0, *) {
//                        $0.sensoryFeedback(.increase, trigger: startedDrag)
//
//                    } else {
//                        $0
//                    }
//                }
//                .modify {
//                    if #available(iOS 17.0, *) {
//                        $0.sensoryFeedback(.impact(flexibility: .soft, intensity: .infinity), trigger: halfway)
//
//                    } else {
//                        $0
//                    }
//                }







        }
        .onChange(of: index) { i in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.smooth){
                print("dhsufsohf \(i)")
                if i == 0{

                    dragProgressOffset = 0.0
                    dragProgressMultiplier = 1.0

                    dragProgressOffset = 0.0
                }
            }
                    }

        }
    }

    var classStickerMask: some View{
        GeometryReader {
            let globalFrame = $0.frame(in: .global)

            RoundedRectangle(cornerRadius: 3)
                .padding(.trailing, max(0, (((dragProgress + max(progressOffset,dragProgressOffset)) * dragProgressMultiplier) * globalFrame.width ) ))
                .scaleEffect(x: 1.01, y: 3)
        }
    }

}
