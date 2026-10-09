//
//  coredatadebugoverivew.swift
//  KyoNeo
//
//  Created by Aether on 23/07/2023.
//

import SwiftUI
import AmethystUI

struct coredatadebugoverivew: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var classes: FetchedResults<ClassEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "color1", ascending: true)]) var customColors: FetchedResults<CusColor>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "color1", ascending: true)]) var customUserColors: FetchedResults<CustomUserColor>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var splitters: FetchedResults<SplitterEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "label", ascending: true)]) var tasks: FetchedResults<TaskEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)]) var taskTypes: FetchedResults<TaskTypeEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var teachers: FetchedResults<TeacherEntity>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>

    @State var scrolled: Bool = false
    var body: some View {
            List {
                Section("weeks"){
                    ForEach(weeks, id:\.id){ item in
                        NavigationLink {
                            List{
                                Section("name"){
                                    Text(item.name ?? "No Name")
                                }
                                Section("id"){
                                    Text((item.id?.uuidString ?? "Fatal Flaw - no UUID"))
                                }
                                Section("days"){
                                    if let daysArray = (Array(item.days ?? []) as? [Day])?.sorted(by: { $0.number < $1.number }) {
                                        ForEach(daysArray, id: \.self) { day in
                                            NavigationLink {
                                                List{
                                                    if let timeSlotsArray = (Array(day.timeSlots ?? []) as? [TimeSlot])?.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() }) {
                                                        ForEach(timeSlotsArray, id: \.self) { timeSlot in
                                                            NavigationLink {
                                                                List{
                                                                    Section("id"){
                                                                        Text((timeSlot.id?.uuidString ?? "Fatal Flaw - no UUID"))
                                                                    }
                                                                    Section("class entity"){
                                                                        VStack(alignment: .leading){
                                                                            Text("name: " + (timeSlot.classEntity?.name ?? "No Name"))
                                                                            Text("id: " + (timeSlot.classEntity?.id?.uuidString ?? "Fatal Flaw - no UUID"))
                                                                                .font(.caption)

                                                                            Text("shortName: " + (timeSlot.classEntity?.shortName ?? "No Short Name"))
                                                                                .font(.caption)

                                                                            Text("color1: " + (timeSlot.classEntity?.color1 ?? "No color1"))
                                                                                .font(.caption)

                                                                            Text("color2: " + (timeSlot.classEntity?.color2 ?? "No color2"))
                                                                                .font(.caption)

                                                                        }
                                                                    }
                                                                    Section("splitter entity"){
                                                                        VStack(alignment: .leading){
                                                                            Text("name: " + (timeSlot.splitterEntity?.name ?? "No Name"))
                                                                            Text("id: " + (timeSlot.splitterEntity?.id?.uuidString ?? "Fatal Flaw - no UUID"))
                                                                                .font(.caption)

                                                                            Text("color1: " + (timeSlot.splitterEntity?.color1 ?? "No color1"))
                                                                                .font(.caption)

                                                                            Text("color2: " + (timeSlot.splitterEntity?.color2 ?? "No color2"))
                                                                                .font(.caption)

                                                                        }
                                                                    }
                                                                    Section("time stamp"){
                                                                        if let start = timeSlot.timestamp{
                                                                            Text("\(start)")
                                                                        }
                                                                        else{
                                                                            Text("no time stamp")
                                                                        }
                                                                    }
                                                                    Section("start time"){
                                                                        if let start = timeSlot.startTime{
                                                                            Text("\(start)")
                                                                        }
                                                                        else{
                                                                            Text("no start time")
                                                                        }
                                                                    }
                                                                    Section("end time"){
                                                                        if let end = timeSlot.endTime{
                                                                            Text("\(end)")
                                                                        }
                                                                        else{
                                                                            Text("no start time")
                                                                        }
                                                                    }
                                                                    Section("muted?"){
                                                                        Text("\(timeSlot.muted.description)")
                                                                    }
                                                                    Section("notes"){
                                                                        Text("\(timeSlot.notes ?? "no notes")")
                                                                    }
                                                                    Section("room"){
                                                                        Text("\(timeSlot.room ?? "no room")")
                                                                    }


                                                                }
                                                                .navigationTitle(((timeSlot.id?.uuidString ?? "Fatal Flaw - no UUID")))

                                                            } label: {
                                                                Text((timeSlot.id?.uuidString ?? "Fatal Flaw - no UUID"))
                                                            }

                                                        }
                                                    }
                                                }
                                                .navigationTitle(day.name ?? "No day label")
                                            } label: {
                                            
                                            VStack(alignment: .leading){
                                                Text(day.name ?? "No label")
                                                Text("id: " + (day.id?.uuidString ?? "Fatal Flaw - no UUID"))
                                                    .font(.caption)
                                                Text("number: \(day.number)")
                                                    .font(.caption)
                                                if let timestamp = day.timestamp{
                                                    Text("timestamp: \(timestamp)")
                                                        .font(.caption)
                                                }
                                            }
                                        }
                                        }
                                    }

                                }
                            }
                            .navigationTitle("Week \(item.number)")
                        } label: {
                            Text(item.number , format: .number)
                        }
                    }
                }

                Section("timeSlots"){
                    ForEach(timeSlots, id:\.id){ item in
                        Text((item.classEntity?.name ?? "No Name"))
                    }
                }

                Section(VariableDataNames().classesName()){
                    ForEach(classes, id:\.id){ item in
                        NavigationLink {
                            List{
                                Section("name"){
                                    Text((item.name ?? "No Name"))
                                }
                                Section("id"){
                                    Text((item.id?.uuidString ?? "Fatal Flaw - no UUID"))
                                }
                                Section("shortName"){
                                    Text((item.shortName ?? "No Short Name"))
                                }
                                Section("generated shortName"){
                                    Text((item.name ?? "No Name").shortenedClassName(maxLength: 100) + "            thres: 100")
                                    Text((item.name ?? "No Name").shortenedClassName(maxLength: 20) + "            thres: 20")
                                    Text((item.name ?? "No Name").shortenedClassName(maxLength: 10) + "            thres: 10")
                                    Text((item.name ?? "No Name").shortenedClassName(maxLength: 5) + "            thres: 5")
                                    Text((item.name ?? "No Name").shortenedClassName(maxLength: 4) + "            thres: 4")
                                    Text((item.name ?? "No Name").shortenedClassName(maxLength: 3) + "            thres: 3")
                                }
                                Section("color1"){
                                    Text((item.color1 ?? "No color1"))
                                        .foregroundStyle(Color(hex: item.color2 ?? "No color2"))
                                        .font(.body.weight(.bold))
                                }
                                Section("color2"){
                                    Text((item.color2 ?? "No color2"))
                                        .foregroundStyle(Color(hex: item.color2 ?? "No color2"))
                                        .font(.body.weight(.bold))
                                }

                            }
                            .navigationTitle(item.name ?? "No label")
                        } label: {
                            Text(item.name ?? "No label")
                        }


                    }
                }
                Section("splitters"){
                    ForEach(splitters, id:\.id){ item in
                        NavigationLink {
                            List{
                                Section("name"){
                                    Text((item.name ?? "No Name"))
                                }
                                Section("id"){
                                    Text((item.id?.uuidString ?? "Fatal Flaw - no UUID"))
                                }
                                Section("color1"){
                                        Text((item.color1 ?? "No color1"))
                                        .foregroundStyle(Color(hex: item.color1 ?? "No color1"))
                                        .font(.body.weight(.bold))
                                }
                                Section("color2"){
                                    Text((item.color2 ?? "No color2"))
                                        .foregroundStyle(Color(hex: item.color2 ?? "No color2"))
                                        .font(.body.weight(.bold))
                                }

                            }
                            .navigationTitle(item.name ?? "No label")
                        } label: {
                            Text(item.name ?? "No label")
                        }
                    }
                }

                Section("customUserColors"){
                    ForEach(customUserColors, id:\.id){ item in
                        VStack(alignment: .leading){
                            Text(item.id?.uuidString ?? "! No UUID")
                            HStack{
                                Text(item.color1 ?? "").foregroundStyle(Color(hex: item.color1 ?? "No color1"))
                                
                                Text(item.color2 ?? "").foregroundStyle(Color(hex: item.color2 ?? "No color2"))
                            }
                        }
                    }
                }

                Section("tasks"){
                    ForEach(tasks, id:\.id){ item in
                        NavigationLink {
                            List{
                                Section("due") {
                                    if let due = item.due{
                                        Text("\(due)")
                                    }
                                    else{
                                        Text("no due date")
                                    }
                                }
                                Section("classEntity") {
                                    NavigationLink {
                                        List{
                                            Section("name"){
                                                Text((item.classEntity?.name ?? "No Name"))
                                            }
                                            Section("id"){
                                                Text((item.classEntity?.id?.uuidString ?? "Fatal Flaw - no UUID"))
                                            }
                                            Section("shortName"){
                                                Text((item.classEntity?.shortName ?? "No Short Name"))
                                            }
                                            Section("generated shortName"){
                                                Text((item.classEntity?.name ?? "No Name").shortenedClassName(maxLength: 100) + "            thres: 100")
                                                Text((item.classEntity?.name ?? "No Name").shortenedClassName(maxLength: 20) + "            thres: 20")
                                                Text((item.classEntity?.name ?? "No Name").shortenedClassName(maxLength: 10) + "            thres: 10")
                                                Text((item.classEntity?.name ?? "No Name").shortenedClassName(maxLength: 5) + "            thres: 5")
                                                Text((item.classEntity?.name ?? "No Name").shortenedClassName(maxLength: 4) + "            thres: 4")
                                                Text((item.classEntity?.name ?? "No Name").shortenedClassName(maxLength: 3) + "            thres: 3")
                                            }
                                            Section("color1"){
                                                Text((item.classEntity?.color1 ?? "No color1"))
                                                    .foregroundStyle(Color(hex: item.classEntity?.color2 ?? "No color2"))
                                                    .font(.body.weight(.bold))
                                            }
                                            Section("color2"){
                                                Text((item.classEntity?.color2 ?? "No color2"))
                                                    .foregroundStyle(Color(hex: item.classEntity?.color2 ?? "No color2"))
                                                    .font(.body.weight(.bold))
                                            }

                                        }
//                                        .navigationTitle(item.name ?? "No label")
                                    } label: {
                                        Text(item.classEntity?.name ?? "No label")
                                    }
                                }
                                Section("completed?") {
                                    Text(item.completed.description)
                                }
                                Section("link") {
                                    Text(item.link ?? "no link")
                                }
                                Section("notes") {
                                    Text(item.notes ?? "no notes")
                                }
                                Section("muted?") {
                                    Text(item.muted.description)
                                }
                            }
                            .navigationTitle(item.label ?? "No label")

                        } label: {
                            Text(item.label ?? "No label")
                        }

                    }
                }
                Section("taskTypes"){
                    ForEach(taskTypes, id:\.id){ item in
                        HStack{
                            Text(item.title ?? "No Name")
                            Spacer()
                            Image(systemName: item.icon ?? "square")
                        }
                    }
                }
                Section("teachers"){
                    ForEach(teachers, id:\.id){ item in
                        HStack{
                            Text(item.name ?? "No Name")
                            Spacer()
                            Image(systemName: "person")
                        }
                    }
                }

            }
            .coordinateSpace(name: "scroll")
            .toolbar(.hidden)
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 70)
            })
            .overlay(alignment: .top){
                FluidNavigationBar(title: "debug", titleColor: .primary, tintColor: .primary, compactMode: true, type: .back, scrolled: $scrolled, linelimit: 1) {

                } toolbar: {

                }

            }

    }
}

#Preview {
    coredatadebugoverivew()
}
