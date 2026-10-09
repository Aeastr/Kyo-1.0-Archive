//
//  TaskDetail.swift
//  KyoNeo
//
//  Created by Aether on 21/04/2024.
//

import SwiftUI
import CoreData

struct ClassDetail: View {
    var item: ClassEntity
    @AppStorage("navigationFont") var fontDesign: navigationFont = .expanded
    @AppStorage("fontWeightIndex") private var fontWeightIndex: Int = 1
    @AppStorage("fontCaseIndex") private var fontCaseIndex: Int = 0

    @State var editClass: Bool = false
    @State var deleteAlert: Bool = false

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) var timeSlots: FetchedResults<TimeSlot>
    
    @State var edit: TimeSlot? = nil
    @State var editTask: ClassEntity? = nil
    @State var addTask: ClassEntity? = nil
    
    var body: some View {

        let color1 = Color(hex: item.color1 ?? "")
        let brightness1 = color1.getBrightness()

        ScrollView {
            VStack(alignment: .leading){
                HStack(alignment: .center){
                    Text("\(item.name ?? "Untitled")")
                        .font(.system(.largeTitle, design: fontDesign.design, weight: fontWeights[min(max(fontWeightIndex, 0), 3)].weight).width(fontDesign.wdith))

                    (item.pinned ? Text(Image(systemName: "pin")) : Text(""))
                        .font(.system(.title3, design: fontDesign.design, weight: fontWeights[min(max(fontWeightIndex, 0), 3)].weight).width(fontDesign.wdith))
                        .contentTransition(.numericText())
                        .animation(.smooth, value: item.pinned)


                }
                .textCase(fontCaseIndex == 1 ? .uppercase : fontCaseIndex == 2 ? .lowercase : nil)

                Group{
                    Text("^[\(item.timeSlot?.count ?? 0) Entries](inflect: true), ")
                    +
                    Text("^[\(item.taskEntity?.count ?? 0) Tasks](inflect: true)")
                }
                .font(.caption.weight(.semibold))

            }
            .foregroundStyle(brightness1 > 0.73 ? color1.darken(by: 0.5) : Color.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .padding()
            .frame(minHeight: 300)
            .background(Color(hex: item.color1!))

            HStack(spacing: 20){

                EntriesGrid(for: item, editClass: $edit, addTaskForClass: $addTask)

                let tasksSet = item.taskEntity
                VStack{
                    Text("Tasks")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    if let tasksArrayUnsorted = tasksSet?.allObjects as? [TaskEntity] {
                        // Sorting the array by the .due property
                        let tasksArraySorted = tasksArrayUnsorted.sorted { (task1, task2) -> Bool in
                            guard let due1 = task1.due, let due2 = task2.due else {
                                return false
                            }
                            return due1 < due2
                        }

                        // Now you can use tasksArraySorted
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 10) {
                            ForEach(tasksArraySorted, id: \.self) { task in
                                TaskItem(data: task)
                            }
                        }

                    }
                }
                .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .top)
                .sheet(item: $addTask) { task in
                    NavigationStack{
                    TaskWorkshop(selectedClass: task)
                    }
                        .presentationCornerRadius(25)
                }
                .sheet(item: $edit) { entity in
                    NavigationStack{
                        TimeSlotWorkshop(entity: entity)
                    }
                    .presentationCornerRadius(25)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    editClass.toggle()
                }, label: {
                    Text("Edit")
                })
                .bold()
                .foregroundStyle(brightness1 > 0.73 ? color1.darken(by: 0.5) : Color.white)
            }
            ToolbarItem(placement: .automatic) {
                Menu(content: {
                    Button(role: .destructive) {
                        deleteAlert.toggle()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }

                }, label: {
                    Image(systemName: "ellipsis")
                })
                .bold()
                .foregroundStyle(brightness1 > 0.73 ? color1.darken(by: 0.5) : Color.white)
            }



        })
        .ignoresSafeArea()
        .sheet(isPresented: $editClass, content: {
            NavigationStack{
                ClassComposer(entity: item)
            }
            .presentationCornerRadius(25)
        })
        .alert("Are you sure?", isPresented: $deleteAlert) {
//            Button(role: .destructive) {
//
//            } label: {
//                Text("Delete")
//            }


            Button(role: .destructive) {
                for timeSlot in timeSlots{
                    if timeSlot.classEntity == item{
                                                                                                  viewContext.delete(timeSlot)
                                                                                              }

                                                                                          }

                    viewContext.delete(item)


                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            } label: {
                Text("Delete Class & Related Items")
            }

            Button(role: .cancel) {

            } label: {
                Text("Cancel")
            }


        } message: {
            Text("Delete \(item.name ?? "untitled")? Deleting related items will remove associated entries and tasks")
        }

    }
}

struct EntriesGrid: View {
    var classEntity: ClassEntity

    @Binding var editClass: TimeSlot?
    @Binding var addTaskForClass: ClassEntity?

    init(for classEntity: ClassEntity, editClass: Binding<TimeSlot?>, addTaskForClass: Binding<ClassEntity?>) {
        self.classEntity = classEntity

        self._editClass = editClass
        self._addTaskForClass = addTaskForClass
    }
    var body: some View {
        VStack{
            let timeSlotSet = classEntity.timeSlot

            Text("Entries")
                .font(.headline.weight(.bold))
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            if let timeSlotArrayUnsorted = timeSlotSet?.allObjects as? [TimeSlot] {
                // Sorting the array by the .due property
                let timeSlotArrayUnsorted = timeSlotArrayUnsorted.sorted { (task1, task2) -> Bool in
                    guard let due1 = task1.timestamp, let due2 = task2.timestamp else {
                        return false
                    }
                    return due1 < due2
                }

                // Now you can use tasksArraySorted
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: 700))], spacing: 10) {
                    ForEach(timeSlotArrayUnsorted, id: \.self) { timeSlot in
                        EntryBlock(timeSlot: timeSlot, shownTimeSlot: $editClass, viewTimeSlot: .constant(nil), classForTask: $addTaskForClass, shareTimeSlot: .constant(nil), editMode: .constant(false), imageMode: true)
                    }
                }
            }
        }.frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .top)
    }
}
