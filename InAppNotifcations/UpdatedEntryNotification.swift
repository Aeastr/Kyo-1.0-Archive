//
//  UpdatedEntryNotification.swift
//  KyoNeo
//
//  Created by Aether on 04/02/2024.
//

import SwiftUI
import CoreData

struct UpdatedEntryNotification: View {
    @Environment(\.undoManager) var undoManager
    let viewContext: NSManagedObjectContext
    var timeout: CGFloat // Set your timeout value
    let color: Color
    let count: Int
    @State private var remainingTime: CGFloat
    @State private var timer: Timer?
    @State private var undo: Bool = false
    @State private var noUndoManager = false
    @State private var cannotUndo = false
    @State private var showCreate = false

    init(viewContext: NSManagedObjectContext, timeout: CGFloat, color: Color, count: Int) {
        self.viewContext = viewContext
        self.timeout = timeout
        self.color = color
        self.count = count
        _remainingTime = State(initialValue: timeout) // Initialize remaining time with timeout
    }

    var body: some View {
        HStack {
            Button {

                if !undo{
                    if viewContext.undoManager?.canUndo ?? false {

                                        viewContext.undoManager?.undo()
                                            undo = true
                                    }
                                    else{
                                        if viewContext.undoManager?.canUndo != nil{
                                            cannotUndo = true
                                        }
                                        else{
                                            noUndoManager = true
                                        }
                                    }
                }
                else{
                    if viewContext.undoManager?.canRedo ?? false {

                                        viewContext.undoManager?.redo()
                                            undo = false
                                    }
                                    else{
                                        if viewContext.undoManager?.canUndo != nil{
                                            cannotUndo = true
                                        }
                                        else{
                                            noUndoManager = true
                                        }
                                    }
                }
            } label: {
                if undo{
                    Image(systemName: "arrow.uturn.forward")
                        .foregroundStyle(.green)
                                    .font(.title3)
                                    .bold()
                                    .frame(width: 60, height: 60)
                                    .background(.green.gradient.opacity(0.3))
                                    .clipShape(Circle())
                                    .transition(.blur.animation(.smooth))
                }
                else{
                    Image(systemName: "arrow.uturn.backward")
                        .foregroundStyle(color)
                                    .font(.title3)
                                    .bold()
                                    .frame(width: 60, height: 60)
                                    .background(color.gradient.opacity(0.3))
                                    .clipShape(Circle())
                                    .transition(.blur.animation(.smooth))
                }
            }
//            .disabled(remainingTime < 1)
//            .opacity((remainingTime < 1) ? 0.5 : 1.0)


            VStack(alignment: .leading, spacing: 6) {
                Text((cannotUndo || noUndoManager) ? "Error" : undo ? "Undid Updates" : count > 1 ? "Updated \(count) Entries" : "Updated Entry")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .transition(.blur.animation(.smooth))
                    .animation(.smooth, value: undo)
                    .lineLimit(1)
//                    .frame(width: 160, alignment: .leading)

                if cannotUndo{
                               Text("Cannot Undo")
                        .foregroundStyle(.white)
                        .transition(.blur.animation(.smooth))
                           }
                           if noUndoManager{
                               Text("No undo manager")
                                   .foregroundStyle(.white)
                                   .transition(.blur.animation(.smooth))
                           }
            }
            .padding(.top, 20)
            .padding(.bottom, -10)
            .padding(.leading, 2)
            .animation(.smooth, value: noUndoManager)
            .animation(.smooth, value: cannotUndo)
            .animation(.smooth, value: undo)


            Spacer(minLength: 0)
//                .frame(maxWidth: 50)

            if !undo{
                Gauge(value: remainingTime, in: 0...timeout) {
                    Text("\(Int(remainingTime))")
                        .contentTransition(.numericText(value: remainingTime))
                        .foregroundStyle(colorForTime(remainingTime / timeout))

                }
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(colorForTime(remainingTime / timeout)) // Dynamic color based on remaining time
                .gaugeStyle(.accessoryCircularCapacity)
                .scaleEffect(0.9)
                .transition(.blur.animation(.smooth))
            }
//            else{
//                ProgressView()
//                    .frame(width: 60, height: 60)
//                    .tint(.white)
//            }

//            Button {
//                showCreate.toggle()
//            } label: {
//                Image(systemName: "plus")
//                               .foregroundStyle(color.lighten(by: 0.2))
//                                                               .font(.title3)
//                                                               .bold()
//                                                               .frame(width: 52, height: 52)
//                                                               .background(color.gradient.opacity(0.3))
//                                                               .clipShape(Circle())
//                                                               .transition(.blur.animation(.smooth))
//                                           .scaleEffect(0.9)
//            }
//            .sheet(isPresented: $showCreate) {
//
//            }

        }
        .padding(15)
                                                          .background {
                                                              RoundedRectangle(cornerRadius: 15)
                                                                  .fill(.black)
                                                          }

        .animation(.smooth, value: undo)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()

            do {
                                                    try viewContext.save()
print("save!!")
                                                } catch {
                                                    let nsError = error as NSError
                                                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                                }
        }
    }

    private func colorForTime(_ ratio: CGFloat) -> Color {
            switch ratio {
            case 0...0.2:
                return .red
            case 0.2...0.4:
                return .orange
            case 0.4...0.6:
                return .white
            case 0.6...0.8:
                return .white
            default:
                return .white
            }
        }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            withAnimation(.smooth){
                if remainingTime > 0 {
                                remainingTime -= 1
                            } else {



                                timer?.invalidate()
                            }
            }
        }
    }
}

