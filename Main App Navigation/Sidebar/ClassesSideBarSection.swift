//
//  ClassesSideBarSection.swift
//  KyoNeo
//
//  Created by Aether on 29/04/2024.
//

import SwiftUI

struct ClassSection: View {

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ClassEntity.pinned, ascending: false),
            NSSortDescriptor(keyPath: \ClassEntity.name, ascending: true)
        ]
    ) var classes: FetchedResults<ClassEntity>

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.editMode) private var editMode

    @State var deleteClass: ClassEntity? = nil

    @Binding var showCreate: Bool
    @Binding var editClass: ClassEntity?

    @State var deleteAlert: Bool = false

    @FetchRequest(sortDescriptors: []) var timeSlots: FetchedResults<TimeSlot>

    @Environment(\.colorScheme) var colorScheme

    @AppStorage("classesSectionSidebar-isExpanded") var isExpandedSave: Bool = false
    @State var isExpanded: Bool = false

    var body: some View{
        Section(isExpanded: $isExpanded) {
            ForEach(classes, id: \.id){ item in

                NavigationLink {
                    ClassDetail(item: item)
                } label: {

                    Label(item.name ?? "", systemImage: item.icon ?? "square")
                    Spacer()

                    if item.pinned{
                        Image(systemName: "pin")
                            .opacity(0.5)
                            .transition(.blur.animation(.smooth))
                    }
                }
                .swipeActions(edge: .leading, content: {
                    Button {
                        withAnimation(.smooth(duration: 0.35)){
                            item.pinned.toggle()

                            do{
                                try viewContext.save()
                                print("save!!")
                            } catch {
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
                        }
                    } label: {
                        Image(systemName: item.pinned ? "pin.slash" : "pin")
                    }
                    .tint(Color(hex: item.color1 ?? ""))
                })
                .swipeActions(){
                                        Button {
                                            editClass = item
                                        } label: {
                                           Image(systemName: "pencil")

                                        }
                                        .tint(Color.getAdjustedBGColor(color: Color(hex: item.color1 ?? ""), colorScheme: colorScheme))


                    Button {

                        deleteClass = item
                        deleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)

                }
                .tint(Color(hex: item.color1 ?? ""))



            }

            .onDelete { IndexSet in
                if let first = IndexSet.first{
                    deleteClass = classes[first]
                    deleteAlert = true
                }
                else{
                    print("fail")
                }
            }
//            Button(action: {
//
//            }, label: {
//                Divider()
//                Label("Add", systemImage: "plus")
//            })

            //        .sheet(item: $editClass) { Item in
            //            NavigationStack{
            ////                    ClassComposer(entity: Item)
            ////                        .presentationCornerRadius(25)
            //            }
            //            .id(Item.id)
            //        }
            .alert("Are you sure?", isPresented: $deleteAlert) {
                Button(role: .destructive) {
                    for timeSlot in timeSlots{
                        if timeSlot.classEntity == deleteClass{
                                                                                                      viewContext.delete(timeSlot)
                                                                                                  }

                                                                                              }
                    if let deleteClass{
                        viewContext.delete(deleteClass)
                    }

                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                } label: {
                    Text("Delete Class & Related Items")
                }


//                Button(role: .destructive) {
//
//                } label: {
//                    Text("Delete Class & Related Items")
//                }

                Button(role: .cancel) {

                } label: {
                    Text("Cancel")
                }


            } message: {
                Text("Delete \(deleteClass?.name ?? "untitled")? Deleting related items will remove associated entries and tasks")
            }

//            Button(action: {
//                withAnimation(.smooth){
//                    // Toggle between active and inactive edit modes
//                    if editMode?.wrappedValue.isEditing ?? false {
//                        editMode?.wrappedValue = .inactive
//                    } else {
//                        editMode?.wrappedValue = .active
//                    }
//                }
//                        }) {
//                            VStack{
//                                Divider()
//
//                                Label(editMode?.wrappedValue.isEditing ?? false ? "Done" : "Edit", systemImage: "pencil")
//                                    .fontWeight(.semibold)
//                                    .hoverEffect()
//                            }
//                        }

        } header: {
            HStack(spacing: 10){
                Button {
                                    showCreate.toggle()
                                } label: {
                                    Image(systemName: "plus")
                                }
                                .hoverEffect()
                                .fontWeight(.semibold)

                Text(VariableDataNames().classesName())
            }

        }
        .onChangeOf(isExpanded) { newValue in
            isExpandedSave = newValue
        }
        .onAppear {
            isExpanded = isExpandedSave
        }

    }
}
