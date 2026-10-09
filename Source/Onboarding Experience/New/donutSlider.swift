//
//  RotatingDial.swift
//  KyoNeo
//
//  Created by Aether on 20/07/2023.
//

import SwiftUI

struct donutSlider: View {
    var totalCount = 8
    var color: Color = Color.accentColor
    var bgColor: Color = Color.accentColor
    var lineThickness:LineThickness = .max
    var indicatorDiameter = 50.0
    var lineWidth:Double {
        return indicatorDiameter * lineThickness.rawValue
    }
    var circleSizeMultiplier = 4
    var scaledCircleSize: Double {
        let manualScaling = indicatorDiameter * Double(circleSizeMultiplier)
#if !os(macOS) && !os(visionOS)
        let boundingScaling = UIScreen.main.bounds.width - 100
        #elseif os(macOS) || os(visionOS)
        let boundingScaling: Double = 400
        #endif
        return min(manualScaling, boundingScaling)
    }

    ///A forced size for the dial specified by the caller
    var dialSize: Double?

    var intendedDialSize: Double {
        dialSize ?? scaledCircleSize
    }

    var canRotateLessThan0 = false
    var canRotateMoreThan360 = false
    var showProgress = true

    @State var dragging = false

    //MARK: - Internal State
    @Binding var progress: Double
    @Binding var angle: Double
    var oldAngle: Double = 0
    @State var currentQuadrant:Quadrant = .one
    @State var upcomingQuadrant:Quadrant = .one


    @State var showDragPrompt = false
    var showCentre = true
    var angleIncrease = 12.0


    var onDragEnd: () -> Void = {}

    //MARK: - Init Method
        init(totalCount: Int = 20, color: Color = Color.accentColor, bgColor: Color = Color.accentColor,
             lineThickness: LineThickness = .max, indicatorDiameter: Double = 50.0,
             circleSizeMultiplier: Int = 4, dialSize: Double? = nil,
             canRotateLessThan0: Bool = false, canRotateMoreThan360: Bool = false,
             showProgress: Bool = true, showCentre: Bool = true,
             progress: Binding<Double>, angle: Binding<Double>,
             oldAngle: Double = 0,
             currentQuadrant: Quadrant = .one, upcomingQuadrant: Quadrant = .one,
             showDragPrompt: Bool = false,
             onDragEnd: @escaping () -> Void = {}) {

            self.totalCount = totalCount
            self.color = color
            self.bgColor = bgColor
            self.lineThickness = lineThickness
            self.indicatorDiameter = indicatorDiameter
            self.circleSizeMultiplier = circleSizeMultiplier
            self.dialSize = dialSize
            self.canRotateLessThan0 = canRotateLessThan0
            self.canRotateMoreThan360 = canRotateMoreThan360
            self.showProgress = showProgress
            self.showCentre = showCentre
            self.angleIncrease = Double(360 / totalCount)

            self._progress = progress
            self._angle = angle
            self.oldAngle = oldAngle
            self.currentQuadrant = currentQuadrant
            self.upcomingQuadrant = upcomingQuadrant
            self._showDragPrompt = State(initialValue: showDragPrompt)
            self.onDragEnd = onDragEnd
        }

    //MARK: - View
    var body: some View {
        VStack {
            ZStack {
                dialOutline
                

                if oldAngle != 0 {
                    Capsule()
                        .fill(color)
                    //  .blur(radius: 1.0)
                      //  .overlay(Image(systemName: oldAngle < 180 ?  "hourglass.start" : "hourglass.end") .rotationEffect(.init(degrees: 90  - oldAngle )))
                        .frame(width: indicatorDiameter - 20, height: indicatorDiameter - 30)
                        .offset(x: intendedDialSize / 2) //put indicator circle on the edge
                        .rotationEffect(.init(degrees: oldAngle))//modification for it to rotate angle chosen

                        .rotationEffect(.init(degrees: -90)) //Offset the indicator to compensate for initial SwiftUI coordinate drift

                        .foregroundStyle(Color(hex:"944AD9"))
                        .onAppear{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation(.smooth){
                                    showDragPrompt = true
                                }
                            }
                        }
                        .onChange(of: angle) { change in
                            if angle == oldAngle{
#if !os(macOS) && !os(visionOS)
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.warning)
#endif
                            }
                        }
                }

                if showProgress {
                    currentProgressFill

                        .shadow(color: color.opacity(1), radius: 5, y: 0)
                }



                angleIndicator
                    .onChange(of: angle) { change in 
                        if angle == 0{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation(.smooth){
                                    showDragPrompt = true
                                }
                            }
                        }
                    }


                if showCentre{
                    centerButton
                }
            }
        }
    }

    func onDrag(value: DragGesture.Value) {
        withAnimation(.bouncy) {


            showDragPrompt = false
            dragging = true



            currentQuadrant = upcomingQuadrant
            let dx = value.location.x
            let dy = value.location.y

            // Atan2 at the edge of the line, removing the radius of the indicator line and atan2 will give from -180 to 180
            let radians = atan2(dy - (0.5 * indicatorDiameter), dx - (0.5 * indicatorDiameter))

            var dragAngle = radians * 180 / .pi

            // Simple technique for 0 to 360... eg = 360 - 176 = 184..
            if dragAngle < 0 {
                dragAngle = 360 + dragAngle
            }

            let futureQuadrant = quadrant(x: Sign.of(dx), atan2: Sign.of(radians))

            if shouldSnapTo0(from: currentQuadrant, to: futureQuadrant) {
                setAngleOfIndicator(to: 0)
            } else if shouldSnapTo360(from: currentQuadrant, to: futureQuadrant) {
                setAngleOfIndicator(to: 360)
            } else if dragAngle <= 360 {
                // Round the drag angle to the nearest multiple of 9 degrees
                let roundedAngle = round(dragAngle / angleIncrease) * angleIncrease
                self.upcomingQuadrant = futureQuadrant
                setAngleOfIndicator(to: roundedAngle)
            }
        }
    }

    ///The gray outline for the dial. This will have a thickness of `lineWidth` and a
        ///frame that encapsulates `circleSize`
        var dialOutline: some View {
            Circle()
                .stroke(RadialGradient(gradient: Gradient(colors: [bgColor.opacity(0.15), bgColor.opacity(0.4), bgColor.opacity(0.4)]), center: .center, startRadius: 140, endRadius: 65), style: StrokeStyle(lineWidth: lineWidth))
                .frame(width: intendedDialSize, height: intendedDialSize)
            // .stroke(Color(.cardBg).opacity(0.3), style: StrokeStyle(lineWidth: 50, lineCap: .round))
           //     .blur(radius: 3)
                .hueRotation(Angle(degrees: 8))
//                .contrast(3)
        }

        ///The green fill representing the current progress.
        var currentProgressFill: some View {
            Group{

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(color.gradient.opacity(0.6),
                                style: StrokeStyle(lineWidth: lineWidth - 5 + (dragging ? 8 : 0), lineCap: .round))
                        .frame(width: intendedDialSize, height: intendedDialSize)
                        .rotationEffect(.init(degrees: -90))
                    //            .shadow(color: .secondary,radius: 50)

//                        .contrast(3)
                        .opacity(progress == 0 ? 0 : 1)
                        .animation(.smooth, value: dragging)

            }
        }

        /// The circle representing the angle that is currently chosen. It will have a frame
        /// encapsulating `indicatorDiameter` and starts at the `angle` with 0º
        /// indicated at the top.
        var angleIndicator: some View {
            ZStack{
                //            Circle()
                //                .fill(Color.clear)
                //
                //                .overlay(Text("🚀"))
                //                .rotationEffect(.init(degrees: 115))
                //                .frame(width: indicatorDiameter - 10, height: indicatorDiameter - 10)
                //                .offset(x: intendedDialSize / (angle > 25 ?  2.2 : 2)) //put indicator circle on the edge
                //                .offset(y: angle > 25 ? -40 : 0)
                //                .rotationEffect(.init(degrees: angle))//modification for it to rotate angle chosen
                //                .gesture(DragGesture().onChanged(onDrag(value:)))
                //                .rotationEffect(.init(degrees: -90)) //Offset the indicator to compensate for initial SwiftUI coordinate drift
                //                .opacity(angle > 60 ? 1 : 0)
                //
                //
                //                Circle()
                //                    .fill(Color.clear)
                //
                //                    .overlay(Text("☄️"))
                //                    .rotationEffect(.init(degrees: 200))
                //                    .frame(width: indicatorDiameter - 10, height: indicatorDiameter - 10)
                //                    .offset(x: intendedDialSize / 2.7) //put indicator circle on the edge
                //                    .offset(y: -70)
                //                    .rotationEffect(.init(degrees: angle))//modification for it to rotate angle chosen
                //                    .gesture(DragGesture().onChanged(onDrag(value:)))
                //                    .rotationEffect(.init(degrees: -90)) //Offset the indicator to compensate for initial SwiftUI coordinate drift
                //                    .opacity(angle > 180 ? 1 : 0)

                Circle()
                    .fill( color.gradient)
                    .contentShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                //  .blur(radius: 1.0)
                   // .overlay(Image(systemName: angle < 180 ?  "circle.dotted" : "hourglass.end") .rotationEffect(.init(degrees: 90  - angle )))
                    .frame(width: indicatorDiameter - 10 + (dragging ? 8 : 0), height: indicatorDiameter - 10 + (dragging ? 8 : 0))
                    .offset(x: intendedDialSize / 2) //put indicator circle on the edge
                    .rotationEffect(.init(degrees: angle))//modification for it to rotate angle chosen
                    .highPriorityGesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged(onDrag(value:)).onEnded({ _ in
                        dragging = false
                        self.onDragEnd()
                    }))
                    .rotationEffect(.init(degrees: -90)) //Offset the indicator to compensate for initial SwiftUI coordinate drift
                    .animation(.smooth, value: dragging)
                    .foregroundStyle(.white)
                    .onAppear{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.smooth){
                                showDragPrompt = true
                            }
                        }
                    }


                if showDragPrompt{
                    Circle()
                        .fill(Color.clear)

                        .overlay(Image(systemName: "chevron.right"))
                        .rotationEffect(.init(degrees: 107))
                        .frame(width: indicatorDiameter - 10, height: indicatorDiameter - 10)
                        .offset(x: intendedDialSize / 2.1) //put indicator circle on the edge
                        .offset(y: 30)
                        .rotationEffect(.init(degrees: angle))//modification for it to rotate angle chosen
                        .highPriorityGesture(DragGesture(minimumDistance: 30, coordinateSpace: .global).onChanged(onDrag(value:)))
                        .rotationEffect(.init(degrees: -90)) //Offset the indicator to compensate for initial SwiftUI coordinate drift
                        .opacity(angle < 5 ? 1 : 0)
                        .foregroundStyle(.white)
                }

            }
        }

        /// A central button that indicates the current angle measurement. Its frame accounts
        /// for the size of the `indicatorDiameter`
    var centerButton: some View {
        ZStack {
//                let totalMinutes =
//                let minutes = Int(Double(totalMinutes) * progress) % 60
//                let hours = Int(Double(totalMinutes) * progress) / 60
//                let timeString = String(format: "%02d:%02d", hours, minutes)

            let count = (Int(Double(totalCount) * progress) % 60)



            Text(count, format: .number)
                .contentTransition(.numericText())
                .font(.title.weight(.bold))
                .foregroundStyle(color)
//                SegmentedTime(time: timeString)
//                    .foregroundStyle(.primary)
//                    .brightness(0.4)
//                    .frame(width: intendedDialSize - indicatorDiameter - lineWidth + 30,
//                           height: intendedDialSize - indicatorDiameter - lineWidth )
//                    .sensoryFeedback(.increase, trigger: timeString)

        }
    }
}



//MARK: - Supporting Types


//MARK: - Supporting methods
extension donutSlider {

    ///Reveals the quadrant of a circle from an x coordinate and atan2
    func quadrant(x:Sign, atan2:Sign) -> Quadrant {
        switch (x, atan2) {
        case (.positive, .positive):
            return .one
        case (.negative, .positive):
            return .two
        case (.negative, .negative):
            return .three
        case (.positive, .negative):
            return .four
        }
    }

    ///Sets the angle and progress
    func setAngleOfIndicator(to angle:Double) {
        self.angle = angle
        self.progress = angle/360.0
    }

    ///Whether or not this dial should stop at and snap to 360º
    func shouldSnapTo360(from currentQuadrant:Quadrant,
                         to upcomingQuadrant:Quadrant) -> Bool {
        !canRotateMoreThan360 && //configuration
        currentQuadrant == .four && upcomingQuadrant == .one && // in the correct Quadrant?
        progress > 0.8 //Make sure we don't snap too soon
    }

    ///Whether or not this dial should stop at and snap to 0º
    func shouldSnapTo0(from currentQuadrant:Quadrant,
                       to upcomingQuadrant:Quadrant) -> Bool {
        !canRotateLessThan0 && //configuration
        currentQuadrant == .one && upcomingQuadrant == .four && // in the correct Quadrant?
        progress < 0.2 //Make sure we don't snap too soon
    }
}

//MARK: - Preview
//struct RotatingDial_Previews: PreviewProvider {
//    static var previews: some View {
//        RotatingDial().preferredColorScheme(.light)
//        RotatingDial().preferredColorScheme(.dark)
//        RotatingDial(lineThickness:.thin,
//                     indicatorDiameter: 30,
//                     dialSize:100).preferredColorScheme(.dark)
//
//    }
//}

extension donutSlider {

    ///Supporting type to represent the sign of a number.
    ///Helps with pattern matching and exhaustive switches
    enum Sign {
        case positive, negative

        ///Positive is defined as >= 0.
        static func of(_ num:Double) -> Sign {
            if num >= 0 {
                return positive
            }
            else {
                return negative
            }
        }
    }

    ///A standardized thickness of the line drawn
    enum LineThickness:Double {
        case veryThin = 0.1,
             thin = 0.3,
             regular = 0.5,
             thick = 0.7,
             max = 1.0
    }

    ///Quadrants of a circle
    enum Quadrant:Int {
        case one = 1, two, three, four
    }
}
