//
//  PlannerStamp.swift
//  KyoNeo
//
//  Created by Aether on 17/07/2023.
//

import SwiftUI

struct PlannerStamp: View {
    var timeSlot: TimeSlot
    
    @AppStorage("global_Compact") var global_Compact  = false

    @Environment(\.managedObjectContext) private var viewContext
    @State var showItemEdit: Bool = false



    var body: some View {
        ZStack{
            if let tsClass = timeSlot.classEntity, let name = tsClass.name, let color1 = tsClass.color1, let color2 = tsClass.color2, let icon = tsClass.icon, let startText = timeSlot.startTime, let endText = timeSlot.endTime, let room = timeSlot.room{
                let brightness1 = (Color(hex: color1).getBrightness() + Color(hex: color2).getBrightness()) / 2
                let brightness2 = Color(hex: color2).getBrightness()
                VStack{
                    GeometryReader{ geo in
                        VStack(){
                                Text(name)
                                    .font(.title3.weight(.bold))
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity ,alignment: .leading)
                                    .minimumScaleFactor(0.7)
                                    // .matchedGeometryEffect(id: "\(timeSlot.id)name", in: namespace)

                            Spacer()
                            Text(startText + "-")
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                // .matchedGeometryEffect(id: "\(timeSlot.id)start", in: namespace)
                            Text(endText)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                // .matchedGeometryEffect(id: "\(timeSlot.id)end", in: namespace)
                        }

                        .padding(10)
                        .foregroundStyle(brightness2 > 0.75 ? Color(hex: color1).darken(by: 0.5) : Color.white)
                    }
                .frame(maxWidth: .infinity)
                
                .frame(minHeight: max(80, (differenceBetween(startText, endText) * (global_Compact ? 80 : 85)) * (0.8) * 1.2 * getTimeSlotHeightMultiplier(start: startText , end: endText)), maxHeight: max(100, (differenceBetween(startText, endText) * (global_Compact ? 80 : 85)) * (0.8) * 1.2 * getTimeSlotHeightMultiplier(start: startText , end: endText)))
                .background{
                    Image(systemName: icon)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .font(.system(size: 70))
                        .foregroundStyle(brightness2 > 0.75 ? Color(hex: color1).darken(by: 0.5) : Color.white)
                        .offset(x: -10, y: 10)
                        .mask {
                            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.15), Color.clear]), startPoint: .bottomLeading, endPoint: .topTrailing)
                        }

                }
//                    #if !os(visionOS)
                .background{LinearGradient(gradient: Gradient(colors: [Color(hex: color1), Color(hex: color2)]), startPoint: .topLeading, endPoint: .bottomTrailing)}
//                    #else
//                .background{LinearGradient(gradient: Gradient(colors: [Color(hex: color1), Color(hex: color2)]), startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.4)}
//                    #endif

                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                // .matchedGeometryEffect(id: "\(timeSlot.id)bg", in: namespace)

//                .background{
//                    PlannerStampBG(timeSlot: timeSlot)
//                        .offset(y: 3)
//                        .blur(radius: 12)
//                        .opacity(selectedTimeSlot == timeSlot ? brightness1 < 0.6 ? 0.2 : 0.5 : 0)
//                }
                // .matchedGeometryEffect(id: "\(timeSlot.id)mask", in: namespace)

            }
            }
            else if let tSSplit = timeSlot.splitterEntity, let name = tSSplit.name, let color1 = tSSplit.color1, let color2 = tSSplit.color2, let startText = timeSlot.startTime, let endText = timeSlot.endTime{
                if tSSplit.type == SplitterType.free.rawValue{
                    let brightness = (Color(hex: color1).getBrightness() + Color(hex: color2).getBrightness()) / 2
                    
                    VStack{
                        VStack(){
                            Image(systemName: "line.3.horizontal")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Text(startText + "-")
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            Text(endText)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }

                        .padding(global_Compact ? 6 : 10)
                        .foregroundStyle(brightness > 0.83 ? Color(hex: color1).darken(by: 0.5) : Color.white)
                    }
                    .frame(maxWidth: .infinity)

                    .frame(height: max(50, (differenceBetween(startText, endText) * (global_Compact ? 60 : 70)) * 0.8 * 1.2 * getTimeSlotHeightMultiplier(start: startText , end: endText)))

                    .background{LinearGradient(gradient: Gradient(colors: [Color(hex: color1), Color(hex: color2)]), startPoint: .topLeading, endPoint: .bottomTrailing).scaleEffect(1.25)}
                    .clipShape(RoundedRectangle(cornerRadius:global_Compact ? 0: 10))
                }
                else{
                    VStack(spacing: 3){
                        Text(name)

                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(startText + " - " + endText)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .regularOutline(cornerRadius:global_Compact ? 0 : 10)
                        .padding(.horizontal,global_Compact ? 0 : 2)
                        // .matchedGeometryEffect(id: "\(timeSlot.id)split", in: namespace)
                    
                }
            }
        }
        .animation(.smooth, value: global_Compact)
        
        .contentShape(RoundedRectangle(cornerRadius:global_Compact ? 0: 10))
        .contextMenu {
            Menu {
                Section("Are you Sure?"){
                    Button(role: .destructive) {
                        viewContext.delete(timeSlot)
                        do {
                            try viewContext.save()
                            print("deleted week entry")
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button(role: .cancel){

                    } label: {
                        Text("Cancel")
                    }
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }

            // Button to edit a TimeSlot
            Button {
                showItemEdit = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            // Button to duplicate a TimeSlot
            Button {
                duplicateTimesSlot()
            } label: {
                Label("Duplicate", systemImage: "square.on.square")
            }

        }
    }

    func duplicateTimesSlot() {
        // Apply a smooth animation when updating the view
        withAnimation {
            // Create a new TimeSlot object in the viewContext
            let dataFactory = knDataFactory()

            if let tsClass = timeSlot.classEntity, let name = tsClass.name, let color1 = tsClass.color1, let color2 = tsClass.color2, let icon = tsClass.icon, let startTime = TimeFormatter.toDate(timeSlot.startTime ?? "00:00", mode: .time), let endTime = TimeFormatter.toDate(timeSlot.endTime ?? "01:00", mode: .time), let tsDay = timeSlot.day, let tsRoom = timeSlot.room{
                dataFactory.addTimeSlot(dayEntity: tsDay, classEntity: tsClass, splitterEntity: nil, room: tsRoom, startTime: startTime , endTime: endTime)
            }

            // Save the changes to the viewContext
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

}

struct PlannerStampBG: View {
    var timeSlot: TimeSlot
    @Environment(\.managedObjectContext) private var viewContext
    @State var showItemEdit: Bool = false
    var body: some View {
        ZStack{
            if let tsClass = timeSlot.classEntity, let name = tsClass.name, let color1 = tsClass.color1, let color2 = tsClass.color2, let icon = tsClass.icon, let startText = timeSlot.startTime, let endText = timeSlot.endTime{
                LinearGradient(gradient: Gradient(colors: [Color(hex: color1), Color(hex: color2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            }
            else if let tSSplit = timeSlot.splitterEntity, let name = tSSplit.name, let color1 = tSSplit.color1, let color2 = tSSplit.color2, let startText = timeSlot.startTime, let endText = timeSlot.endTime{

                    LinearGradient(gradient: Gradient(colors: [Color(hex: color1), Color(hex: color2)]), startPoint: .topLeading, endPoint: .bottomTrailing).scaleEffect(1.25)

            }
        }


    }



}
