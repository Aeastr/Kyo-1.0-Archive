//
//  TeachersSidebarSection.swift
//  KyoNeo
//
//  Created by Aether on 22/04/2024.
//

import SwiftUI

struct TeachersSidebarSection: View {

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: []) var teachers: FetchedResults<TeacherEntity>
    @State var actionsAlert: Bool = false
    @State var deleteAlert: Bool = false
    @State var selectedTeacher: TeacherEntity? = nil


    @State var isRenameAlertPresented: Bool = false
    @State var showCreateAlert: Bool = false


    @State var teacherName: String = ""
    @AppStorage("TeachersSidebarSection-isExpanded") var isExpandedSave: Bool = false
    @State var isExpanded: Bool = false

    var body: some View{
        Section(isExpanded: $isExpanded) {
            ForEach(teachers, id: \.id){ item in

                Button(action: {
                    actionsAlert.toggle()
                }, label: {
                    Label(item.name ?? "", systemImage: "person")
                })
                .swipeActions(){
                                //                    Button {
                                //                        test = true
                                //                    } label: {
                                //                       Image(systemName: "pencil")
                                //                    }
                                //                    .tint(Color(hex: item.color1 ?? ""))


                                Button {
                                    deleteAlert = true
                                    selectedTeacher = item
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .tint(.red)

                            }


            }
            .onDelete { IndexSet in
                        if let first = IndexSet.first{
                            selectedTeacher = teachers[first]
                            deleteAlert = true
                        }
                        else{
                            print("fail")
                        }
                    }

        } header: {
            HStack(spacing: 10){

                Button {
                    showCreateAlert.toggle()
                } label: {
                    Image(systemName: "plus")
                }
                .hoverEffect()
                .fontWeight(.semibold)

                Text("Teachers")


            }
            .alert("\(selectedTeacher?.name ?? "No Name")", isPresented: $actionsAlert) {
                                    Button("Rename", action: {isRenameAlertPresented.toggle()})
                                    Button("Delete", role: .destructive, action: {
                                        deleteAlert.toggle()

                                    })
                                    Button("Cancel", role: .cancel, action: {})
                                }

        }

        .alert("Are you sure?", isPresented: $deleteAlert) {
                    Button(role: .destructive) {
                        delete()
                    } label: {
                        Text("Delete")
                    }


//                    Button(role: .destructive) {
//
//                    } label: {
//                        Text("Delete Teacher & Related Items")
//                    }

                    Button(role: .cancel) {

                    } label: {
                        Text("Cancel")
                    }


                } message: {
                    Text("Delete \(selectedTeacher?.name ?? "untitled")?")
                }
                .alert("Teacher", isPresented: $isRenameAlertPresented) {
                                                TextField("Enter Teacher name", text: $teacherName)
                                                Button("Update",action: {
                                                    selectedTeacher?.name = teacherName

                                                    do {
                                                        try viewContext.save()
                                                    } catch {
                                                        let nsError = error as NSError
                                                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                                    }

                                                    teacherName = ""
                                                })
                                    Button("Cancel", role: .cancel) { }

                                            }
                .alert("Teacher", isPresented: $showCreateAlert) {
                                                TextField("Enter Teacher name", text: $teacherName)
                                                Button("Add",action: {
                                                    let newTeacher = TeacherEntity(context: viewContext)
                                                    newTeacher.id = UUID()
                                                    newTeacher.name = teacherName

                                                    do {
                                                        try viewContext.save()
                                                    } catch {
                                                        let nsError = error as NSError
                                                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                                    }
                                                })
                                    Button("Cancel", role: .cancel) { }

                                            }
                .onChangeOf(isExpanded) { newValue in
                    isExpandedSave = newValue
                }
                .onAppear {
                    isExpanded = isExpandedSave
                }
    }

    func delete(){
        if let selectedTeacher {
                                    viewContext.delete(selectedTeacher)

                                    do{
                                        try viewContext.save()
                                        print("save!!")
                                    } catch {
                                        let nsError = error as NSError
                                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                    }
                                }
    }
}
